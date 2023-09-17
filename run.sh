#!/bin/bash

OUT_INTERVAL=${INTERVAL:-10}
PARTS=${PARTS:-20}
DEBUG=${DEBUG:-0}

if [[ $DEBUG == 1 ]]; then
	echo "Debug enabled!"
fi

trap exit_script SIGTERM
trap exit_script SIGINT

function exit_script() {
  echo "Stopping script"
  exit 0
}

function run_uld() {
    [[ $1 != http* ]] && echo "Error: Invalid URL!" && return
    echo Starting ulozto-downloader for "$1"
    echo ""

    LAST_OUTPUT=0

    (
    python3 /app/ulozto-downloader/ulozto-downloader.py --frontend JSON --auto-captcha --parts "$PARTS" --output "/downloads" "$1"
    ) | while read -r OUTPUT
    do
    	if [[ $DEBUG == 1 ]]; then
    		echo "$OUTPUT"
    	fi

        [[ $OUTPUT != \{* ]] && continue
        
        if [[ $OUTPUT == \{\"tor\":* ]]; then
            MSG=$(jq -r '.tor' <<< "$OUTPUT")

            [[ $MSG =~ "Downloading GeoIP DB:".* ]] && continue

            echo "Tor: $(jq -r '.tor' <<< "$OUTPUT")"
        
        elif [[ $OUTPUT == \{\"captcha\":*\} ]]; then
            echo "Captcha: $(jq -r '.captcha' <<< "$OUTPUT")"

        else
            STATUS=$(jq -r '.status' <<< "$OUTPUT")

            if [[ $STATUS == "initializing" ]]; then
                echo "ulozto-downloader is initializing..."
                continue
            fi

            diff=$(($(date '+%s') - "$LAST_OUTPUT"))
            [[ $diff -lt $OUT_INTERVAL ]] && continue

			mapfile -t arr < <(jq -r '.file, .url, .status, .curr_speed, .downloaded, .size, .percent, .remaining' <<< "$OUTPUT")

            echo ----------
            echo ""
            echo "Timestamp:     $(date "+%D %T")"
            echo ""
            echo "File:          ${arr[0]}"
            echo "URL:           ${arr[1]}"
            echo ""
            echo "Status:        ${arr[2]}"
            echo "Current speed: ${arr[3]}"
            echo "Downloaded:    ${arr[4]} of ${arr[5]} (${arr[6]})"
            echo "Time left:     ${arr[7]}"
            echo ""
            echo ----------

            LAST_OUTPUT=$(date '+%s')
        fi
    done
}

echo ""
echo Starting FlareSolverr
echo ""

/app/flaresolverr/flaresolverr >/dev/null &

if [[ -f "/downloads/download.txt" ]]; then
    echo ""
    echo "Downloading links from /downloads/download.txt"

    while IFS= read -r URL
    do
        run_uld "$URL"
    done < /downloads/download.txt
else
    run_uld "$1"
fi

exit 0
