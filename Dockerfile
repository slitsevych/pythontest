FROM alpine:latest
COPY . src/
RUN apk add --update --no-cache curl jq python3 py3-pip && \
    pip3 install --upgrade pip && \
    pip3 install -r /src/requirements.txt
CMD ["python3","/src/app.py"]
