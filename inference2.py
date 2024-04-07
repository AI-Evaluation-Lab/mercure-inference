import numpy as np
import onnxruntime as rt
import pydicom
from pydicom.uid import generate_uid
from PIL import Image, ImageDraw
import scipy.ndimage
import sys, os, json
from pathlib import Path
import torch
from torchvision import transforms


# Load the model from the ONNX file
model = rt.InferenceSession('export.onnx')
input_name = model.get_inputs()[0].name


t = torch.nn.Sequential(
    transforms.Resize((512, 512)),
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
)
scripted_transforms = torch.jit.script(t)

def process_image(file, in_folder, out_folder, series_uid, settings):    
    # Compose the filename of the output DICOM file using the new series UID
    out_filename = series_uid + "#" + file.split("#", 1)[1]
    dcm_file_out = Path(out_folder) / out_filename

    # Read the source DICOM slice
    dcm_file_in = Path(in_folder) / file
    dcm = pydicom.dcmread(dcm_file_in)


    input = preprocess(dcm)
    input = scripted_transforms(input).cpu().numpy()

    # Execute the inference via ONNX Runtime
    outputs = model.run(None, {input_name: input})

    outputs = np.argmax(outputs[0])

    text = "Positive" if outputs == 1 else "Negative"

    # Normalize the background (input) image
    dcmpixel = dcm.pixel_array
    background = 255 * ( 1.0 / dcmpixel.max() * (dcmpixel - dcmpixel.min()) )
    background = background.astype(np.ubyte)
    background_image = Image.fromarray(background).convert("RGB")

    overlay_image = overlay_text_on_dicom(file, text)
    # overlay_image = ImageOps.colorize(overlay_image, black="black", white='yellow')


    # Blend the two images
    final_image = Image.blend(overlay_image, background_image, settings["transparency"])
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
    print("AI based Intercranial Hemorrhage Detection from CT Head without contrast")
    print("----------------------------------------------------------")
    print("")

    # Check if the input and output folders are provided as arguments
    if len(sys.argv) < 3:
        print("Error: Missing arguments!")
        print("Usage: inference2.py [input-folder] [output-folder]")
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
    settings = {"color": "yellow", "transparency": 0.75, "series_offset": 1000}

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



def get_first_of_dicom_field_as_int(x):
    if type(x) == pydicom.multival.MultiValue:
        return int(x[0])
    return int(x)

def window_image(img, window_center, window_width, intercept, slope):
    """
    Get windowed image from dicom

    Inputs:
        - original image
        - window_center
        - window_width
        - intercept
        - slope
    """
    img = img * slope + intercept
    img_min = window_center - window_width // 2
    img_max = window_center + window_width // 2
    img[img < img_min] = img_min
    img[img > img_max] = img_max
    return img


def overlay_text_on_dicom(image_path, text):
    # Load the DICOM image
    ds = pydicom.dcmread(image_path)

    # Apply VOI LUT to get the actual pixel data
    pixel_data = np.zeros((512,512))

    # Create a PIL image from the pixel data
    img = Image.fromarray(pixel_data)

    # Draw text on the image
    draw = ImageDraw.Draw(img)
    draw.text((10, 10), text, fill="red")

    # Save the modified image back to DICOM format
    img_array = np.array(img)
    ds.PixelData = img_array.tobytes()
    # ds.save_as(image_path.replace('.dcm', '_overlay.dcm'))

    return Image.fromarray(ds.pixel_array).convert("RGB")

def preprocess(dcm):

    metadata = {
        "intercept": dcm.RescaleIntercept,
        "slope": dcm.RescaleSlope,
    }

    images = []
    for window_center, window_width in [[40, 80], [80, 200], [600, 2800]]:
        metadata["window_center"] = window_center
        metadata["window_width"] = window_width
        metadata = {k: get_first_of_dicom_field_as_int(v) for k, v in metadata.items()}
        # print("Shp:", img_dicom.pixel_array.shape)
        img = window_image(dcm.pixel_array, **metadata)
        images.append(img)

    stacked = np.stack(images).astype(np.float32)
    stacked = stacked[:,:,:,np.newaxis]
    stacked = np.transpose(stacked, (3, 0, 1, 2))
    return torch.from_numpy(stacked)

if __name__ == "__main__":
    main()
