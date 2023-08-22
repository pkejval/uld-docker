# uld-docker

This is container containing all required software to run ulozto-downloader with PR https://github.com/setnicka/ulozto-downloader/pull/173 from @filo891 (many thanks!!!!)

# Installation
- Clone repo
- Run command "docker build --tag ulozto-downloader ."
- Run command "docker run ulozto-downloader args" where args are ulozto-downloader arguments. Hardcoded arguments are "--enforce-tor" and "--auto-captcha" right now.
