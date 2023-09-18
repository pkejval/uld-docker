# uld-docker

This is container containing all required software to run uld-docker with PR https://github.com/setnicka/ulozto-downloader/pull/173 from @filo891 (many thanks!!!!)

# Installation
# Building docker image yourself
- Clone repo
- Run command `docker build --tag uld-docker .`
- Run command `docker run uld-docker "URL"` where URL is download link. Inputting ulozto-downloader arguments directly is not supported. See **Configuration** section below.

In Windows do not forget to change line endings to LF (see: https://stackoverflow.com/a/73028795) in run.sh otherwise you will encounter ```exec /app/run.sh: no such file or directory```

# From dockerhub
- Run command `docker pull pkejval/uld-docker:main`
- Run command `docker run pkejval/uld-docker "URL"` where URL is download link. Inputting ulozto-downloader arguments directly is not supported. See **Configuration** section below.


# Configuration
Because image isn't supporting inputting args directly to `ulozto-downloader` anymore, you can set it by environment variables.

### PARTS=number
How many part split download to.
### INTERVAL=number
How often will script report status to STDOUT in seconds.
### DEBUG=number
If set to 1 then ALL messages from ulozto-downloader will be shown unfiltered. Use only if you are troubleshooting anything.

## Downloading multiple URLs
You can create file called `download.txt` in bind mounted folder `/downloads` and paste URLs to download. Each URL on new line. If `uld-docker` finds this file at startup it will download every URL from this file. 