#!/bin/bash
source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

_COMMIT_HASH=3afe9e57355ab49fb92a0dc231436e583d67d125
files_url=(
	"https://lil.nlp.cornell.edu/resources/NLVR2/train_img.zip train_img.zip"
	"https://lil.nlp.cornell.edu/resources/NLVR2/dev_img.zip dev_img.zip"
	"https://lil.nlp.cornell.edu/resources/NLVR2/test1_img.zip test1_img.zip"
	"https://github.com/lil-lab/nlvr/archive/${_COMMIT_HASH}.zip nlvr.zip")

# These urls require login cookies to download the file
git-annex addurl --fast -c annex.largefiles=anything --raw --batch --with-files <<EOF
$(for file_url in "${files_url[@]}" ; do echo "${file_url}" ; done)
EOF
git-annex get --fast -J8
git-annex migrate --fast -c annex.largefiles=anything *

unzip -o nlvr.zip "nlvr-${_COMMIT_HASH}/nlvr2/data/*"
rm -r data/
mv "nlvr-${_COMMIT_HASH}"/nlvr2/data/ .

[[ -f md5sums ]] && md5sum -c md5sums
[[ -f md5sums ]] || md5sum $(list -- --fast) > md5sums
