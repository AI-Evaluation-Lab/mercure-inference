import numpy as np
import onnxruntime as rt
import pydicom
from pydicom.uid import generate_uid
from PIL import Image, ImageOps
import scipy.ndimage
import sys, os, json
from pathlib import Path


def process_image(file, in_folder, out_folder, series_uid, settings):    
    # Compose the filename of the output DICOM file using the new series UID
    out_filename = series_uid + "#" + file.split("#", 1)[1]
    dcm_file_out = Path(out_folder) / out_filename

    # Read the source DICOM slice
    dcm_file_in = Path(in_folder) / file
    dcm = pydicom.dcmread(dcm_file_in)

    # Normalize input image
    dcmpixel = dcm.pixel_array
    dcmpixel = ( 1.0 / dcmpixel.max() * (dcmpixel - dcmpixel.min()) )

    # Ensure that the input image has square size
    if (dcmpixel.shape[0] != dcmpixel.shape[1]):
        print("Error: Width and height are not equal. Not supported by this module")
        return False

    # Scale input to 288 pixels, as needed by the DL model
    inference_zoom = 288/float(dcmpixel.shape[0])
    scl_dcmpixel = scipy.ndimage.zoom(dcmpixel, inference_zoom, order=3)

    # Shape data for running inference
    scl_dcmpixel=np.dstack([scl_dcmpixel]*3)
    scl_dcmpixel=np.rollaxis(scl_dcmpixel,2)
    scl_dcmpixel=scl_dcmpixel.astype(np.float32)
    scl_dcmpixel=np.expand_dims(scl_dcmpixel, axis=0)

    # Execute the inference via ONNX Runtime
    model = rt.InferenceSession('export.onnx')
    input_name = model.get_inputs()[0].name
    outputs = model.run(None, {input_name: scl_dcmpixel})

    # Get segmentation mask and scale back to original resolution
    mask=outputs[0]
    binary_mask = np.where(mask[0,0,:,:] > 0.5, 0, 255).astype(np.ubyte)
    scl_mask = scipy.ndimage.zoom(binary_mask, 1/inference_zoom, order=3)

    # Colorize segmantation mask
    mask_image = Image.fromarray(scl_mask)
    mask_image = ImageOps.colorize(mask_image, black="black", white=settings["color"])

    # Normalize the background (input) image
    background = 255 * ( 1.0 / dcmpixel.max() * (dcmpixel - dcmpixel.min()) )
    background = background.astype(np.ubyte)
    background_image = Image.fromarray(background).convert("RGB")

    # Blend the two images
    final_image = Image.blend(mask_image, background_image, settings["transparency"])
    final_array = np.array(final_image).astype(np.uint8) 

    # Write the final image back to a new DICOM (color) image 
    dcm.SeriesInstanceUID = series_uid
    dcm.SOPInstanceUID = generate_uid()
    dcm.SeriesNumber = dcm.SeriesNumber + settings["series_offset"]
    dcm.file_meta.TransferSyntaxUID = pydicom.uid.ExplicitVRLittleEndian
    dcm.Rows = final_image.height
    dcm.Columns = final_image.width
    dcm.PhotometricInterpretation = "RGB"
    dcm.SamplesPerPixel = 3
    dcm.BitsStored = 8
    dcm.BitsAllocated = 8
    dcm.HighBit = 7
    dcm.PixelRepresentation = 0
    dcm.PixelData = final_array.tobytes()
    dcm.SeriesDescription = "SEG(" + dcm.SeriesDescription + ")"
    dcm.save_as(dcm_file_out)  
    return True


def main(args=sys.argv[1:]):
    print("")
    print("AI-based prostate-segmentation example for mercure")
    print("--------------------------------------------------")
    print("")

    # Check if the input and output folders are provided as arguments
    if len(sys.argv) < 3:
        print("Error: Missing arguments!")
        print("Usage: inference.py [input-folder] [output-folder]")
        sys.exit(1)

    # Check if the input and output folders actually exist
    in_folder = sys.argv[1]
    out_folder = sys.argv[2]
    if not Path(in_folder).exists() or not Path(out_folder).exists():
        print("IN/OUT paths do not exist")
        sys.exit(1)

    # Load the task.json file, containing the settings for the processing module
    try:
        with open(Path(in_folder) / "task.json", "r") as json_file:
            task = json.load(json_file)
    except Exception:
        print("Error: Task file task.json not found")
        sys.exit(1)

    # Create default values for all module settings
    settings = {"color": "red", "transparency": 0.75, "series_offset": 1000}

    # Overwrite default values with settings from the task file (if present)
    if task.get("process", ""):
        settings.update(task["process"].get("settings", {}))

    # Collect all DICOM series in the input folder. By convention, DICOM files provided by
    # mercure have the format [series_UID]#[file_UID].dcm. Thus, by splitting the file
    # name at the "#" character, the series UID can be obtained
    series = {}
    for entry in os.scandir(in_folder):
        if entry.name.endswith(".dcm") and not entry.is_dir():
            # Get the Series UID from the file name
            seriesString = entry.name.split("#", 1)[0]
            # If this is the first image of the series, create new file list for the series
            if not seriesString in series.keys():
                series[seriesString] = []
            # Add the current file to the file list
            series[seriesString].append(entry.name)

    # Now loop over all series found
    for item in series:
        # Create a new series UID, which will be used for the modified DICOM series (to avoid
        # collision with the original series)
        print("Processing series " + item)
        series_uid = generate_uid()
        # Now loop over all slices of the current series and call the processing function
        for image_filename in series[item]:
            print("Processing slice " + image_filename)            
            process_image(image_filename, in_folder, out_folder, series_uid, settings)


if __name__ == "__main__":
    main()
