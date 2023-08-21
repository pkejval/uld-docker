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

python3 /app/ulozto-downloader/ulozto-downloader.py --auto-captcha --enforce-tor --output "/downloads" "$@"

exit 0