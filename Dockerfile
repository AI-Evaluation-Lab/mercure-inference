FROM continuumio/miniconda3

ADD docker-entrypoint.sh ./
ADD inference.py ./
ADD requirements.txt ./
ADD export.onnx ./
RUN chmod 777 ./docker-entrypoint.sh
RUN pip install -r requirements.txt

CMD ["./docker-entrypoint.sh"]
