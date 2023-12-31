#!/bin/bash

OUT_INTERVAL=${INTERVAL:-10}
DEFAULT_PARTS=${PARTS:-20}
DEBUG=${DEBUG:-0}
ENFORCE_TOR=${ENFORCE_TOR:-0}

if [[ $ENFORCE_TOR -gt 0 ]]; then
    ENFORCE_TOR=" --enforce-tor "
else
    ENFORCE_TOR=""
fi

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
    python3 /app/ulozto-downloader/ulozto-downloader.py $ENFORCE_TOR --yes --frontend JSON --auto-captcha --parts "$PARTS" --output "/downloads" "$1"
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

    echo "$(date "+%D %T")" - Done downloading "$URL"
}

function run_flaresolverr() {
    echo ""
    echo Starting FlareSolverr and waiting to its startup
    echo ""
    STARTED=0
    TRIES=60

    if [[ $DEBUG == 1 ]]; then
        /app/flaresolverr/flaresolverr &
    else
        /app/flaresolverr/flaresolverr >/dev/null &
    fi

    until [[ $STARTED -eq 1 ]]
    do
        wget -q --spider http://0.0.0.0:8191/health
        if [[ $? -eq 0 ]]; then
            STARTED=1
        else
            [[ $DEBUG == 1 ]] && echo Flaresolverr still not ready! Waiting 1 second more. $TRIES tries remaining before exit.
            sleep 1
        fi

        ((TRIES--))
        [[ $TRIES -lt 1 ]] && echo "Couldn't start Flaresolverr! Exiting script!" && exit 2
    done
}

function test_avx() {
    lscpu | grep avx
    [[ $? -ne 0 ]] && echo "******* ERROR ******" && echo "Your CPU doesn't support AVX instructions needed for tensorflow to run! Sorry your CPU cannot run this container!" && echo "******* ERROR ******" && exit 5
}

test_avx
run_flaresolverr

if [[ -z "$1" ]] && [[ -f "/downloads/download.txt" ]]; then
    echo ""
    echo "Downloading links from /downloads/download.txt"

    for URL in $(< /downloads/download.txt)
    do
        PARTS=$DEFAULT_PARTS
        LINE=$(echo "$URL" | cut -d ";" -f 1)
        [[ "$LINE" == PARTS=* ]] && eval "$LINE" && echo -n "Set $LINE for " && URL=$(echo "$URL" | cut -d ";" -f 2) && echo "$URL"
        run_uld "$URL"
    done
else
    PARTS=$DEFAULT_PARTS
    run_uld "$1"
fi

exit 0
