FROM ubuntu:latest
LABEL name="ulozto-downloader"
VOLUME app downloads
WORKDIR /app

ENTRYPOINT [ "/app/run.sh" ]

RUN apt update 
RUN apt install -y git tor python3 python3-pip jq wget tar 
RUN apt install -y chromium-browser xvfb libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon-x11-0 libxcomposite-dev libxdamage1 libxrandr2 libgbm-dev libpangocairo-1.0-0 libasound2

RUN wget https://github.com/FlareSolverr/FlareSolverr/releases/download/v3.3.2/flaresolverr_linux_x64.tar.gz
RUN tar xvzf flaresolverr_linux_x64.tar.gz
RUN rm flaresolverr_linux_x64.tar.gz
RUN git clone https://github.com/filo891/ulozto-downloader.git

WORKDIR /app/ulozto-downloader
RUN git checkout remotes/origin/cfsolver-support
RUN sed -i 's/\[auto-captcha\]//g' requirements.txt
RUN pip3 install -r requirements.txt

COPY ./run.sh /app