# uld-docker

This is container containing all required software to run uld-docker with PR https://github.com/setnicka/ulozto-downloader/pull/173 from @filo891 (many thanks!!!!)

# Installation
# Building docker image yourself
- Clone repo
- Run command "docker build --tag uld-docker ."
- Run command "docker run uld-docker args" where args are ulozto-downloader arguments. Hardcoded argument is "--auto-captcha" so there is not need to type it.
In Windows do not forget to change line endings to LF ( see: https://stackoverflow.com/a/73028795) in run.sh otherwise you will encounter ``` exec /app/run.sh: no such file or directory```

# From dockerhub
- Run command "docker pull pkejval/uld-docker:main"
- Run command "docker run pkejval/uld-docker args" where args are ulozto-downloader arguments. Hardcoded argument is "--auto-captcha" so there is not need to type it.
