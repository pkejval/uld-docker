#!/bin/bash

function exit_script(){
  echo "Caught SIGTERM"
  exit 0
}

trap exit_script SIGTERM

echo ""
echo Starting FlareSolverr

/app/flaresolverr/flaresolverr >/dev/null &

echo Starting ulozto-downloader
echo ""

if [[ -f "/downloads/download.txt" ]]; then
    echo "Downloading links from /downloads/download.txt"
    for URL in $(cat /downloads/download.txt)
    do
        python3 /app/ulozto-downloader/ulozto-downloader.py --auto-captcha --output "/downloads" "$URL"
    done
else
    python3 /app/ulozto-downloader/ulozto-downloader.py --auto-captcha --output "/downloads" "$@"
fi

exit 0