#!/bin/bash

OUT_INTERVAL=${INTERVAL:-10}
DEFAULT_PARTS=${PARTS:-20}
DEBUG=${DEBUG:-0}

[[ $DEBUG == 1 ]] && echo "Debug enabled!"

trap exit_script SIGTERM
trap exit_script SIGINT

function exit_script() {
    echo "Stopping script"
    exit 0
}

function run_uld() {
    [[ $1 != http* ]] && echo "Skipping invalid URL $1" && return
    echo Starting ulozto-downloader for "$1"
    echo ""

    LAST_OUTPUT=0

    (
    python3 /app/ulozto-downloader/ulozto-downloader.py --frontend JSON --auto-captcha --parts "$PARTS" --output "/downloads" "$1"
    ) | while read -r OUTPUT
    do
        [[ $DEBUG == 1 ]] && echo "$OUTPUT"

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

    echo $(date "+%D %T") - Done downloading "$URL"
}

echo ""
echo Starting FlareSolverr
echo ""

/app/flaresolverr/flaresolverr >/dev/null &

if [[ -z "$1" ]] && [[ -f "/downloads/download.txt" ]]; then
    echo ""
    echo "Downloading links from /downloads/download.txt"

    for URL in $(cat /downloads/download.txt)
    do
        PARTS=$DEFAULT_PARTS
        LINE=$(echo "$URL" | cut -d ";" -f 1)
        [[ "$LINE" == PARTS=* ]] && eval "$LINE" && echo -n "Set $LINE for " && URL=$(echo "$URL" | cut -d ";" -f 2) && echo "$URL"
        run_uld "$URL"
    done
else
    run_uld "$1"
fi

exit 0
