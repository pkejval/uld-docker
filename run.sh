#!/bin/bash

function exit_script(){
  echo "Caught SIGTERM"
  exit 0
}

trap exit_script SIGTERM

echo ""
echo Starting FlareSolverr
echo ""

/app/flaresolverr/flaresolverr >/dev/null &

echo ""
echo Starting ulozto-downloader
echo ""

if [[ -f "/app/download.txt" ]]; then
    python3 /app/ulozto-downloader/ulozto-downloader.py --auto-captcha --enforce-tor --output "/downloads" "$1"
else
    python3 /app/ulozto-downloader/ulozto-downloader.py --auto-captcha --enforce-tor --output "/downloads" "$1"
fi

exit 0