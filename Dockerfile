FROM ubuntu:latest
LABEL name="ulozto-downloader"
RUN mkdir /app && mkdir /downloads
VOLUME /downloads
WORKDIR /app

RUN apt update && \
 apt install -y git tor python3 python3-pip jq wget gzip && \
 apt install -y chromium-browser xvfb libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon-x11-0 libxcomposite-dev libxdamage1 libxrandr2 libgbm-dev libpangocairo-1.0-0 libasound2

RUN wget https://github.com/FlareSolverr/FlareSolverr/releases/latest/download/flaresolverr_linux_x64.tar.gz && \
 tar xvzf flaresolverr_linux_x64.tar.gz && \
 rm flaresolverr_linux_x64.tar.gz

RUN git clone https://github.com/filo891/ulozto-downloader.git && \
 cd /app/ulozto-downloader && \
 git checkout remotes/origin/cfsolver-support && \
 sed -i 's/\[auto-captcha\]//g' requirements.txt && \
 pip3 install -r requirements.txt

RUN wget https://raw.githubusercontent.com/torproject/tor/main/src/config/geoip -O /app/geoip.db && \
 wget https://raw.githubusercontent.com/torproject/tor/main/src/config/geoip6 -O /app/geoip6.db

COPY ./run.sh /app
RUN chmod 755 /app/run.sh
ENTRYPOINT [ "/app/run.sh" ]
