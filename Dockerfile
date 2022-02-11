FROM continuumio/miniconda3
ADD docker-entrypoint.sh inference.py requirements.txt export.onnx ./
RUN chmod 777 ./docker-entrypoint.sh && pip install -r requirements.txt
CMD ["./docker-entrypoint.sh"]