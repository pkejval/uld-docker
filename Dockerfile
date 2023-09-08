FROM ubuntu:latest
LABEL name="ulozto-streamer"

ENV PYTHONUNBUFFERED=1 \
    TERM=xterm \
    DOWNLOAD_FOLDER=/downloads \
    DATA_FOLDER=/data \
    TEMP_FOLDER=/tmp \
    DEFAULT_PARTS=10 \
    AUTO_DELETE_DOWNLOADS=0

EXPOSE 8000

RUN mkdir /app && mkdir /downloads && mkdir /data
VOLUME ["/downloads", "/data" ]
WORKDIR /app

RUN apt update && \
 apt install -y git tor python3 python3-pip jq wget gzip

RUN git clone --recurse-submodules --depth=1 https://github.com/SpiReCZ/ulozto-streamer.git && \
 cd /app/ulozto-streamer && \
 sed -i 's/\[auto-captcha\]//g' requirements.txt && \
 pip3 install -r requirements.txt && \
 cd ulozto-downloader && \
 sed -i 's/\[auto-captcha\]//g' requirements.txt && \
 pip3 install -r requirements.txt && \
 ln -s uldlib ../uldlib

CMD [ "python3", "/app/ulozto-streamer/ulozto-streamer.py" ]