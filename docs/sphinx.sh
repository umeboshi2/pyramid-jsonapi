#!/bin/bash

# Try to ensure we're in the project 'root' for relative paths etc to work.
cd "$(dirname $0)/.."

PATH=bin/:$PATH
SOURCE=docs/source
TARGET=docs/build

sphinx-apidoc -f -T -e -o ${SOURCE}/apidoc pyramid_jsonapi
# Generate config docs from python method
python -c 'import pyramid_jsonapi.settings as pjs; s = pjs.Settings({}); print(s.sphinx_doc())' >docs/source/apidoc/settings.inc
travis-sphinx --outdir=${TARGET} build --source=${SOURCE}
# Get a pylint badge
wget https://mperlet.de/pybadge/badges/$(pylint pyramid_jsonapi |grep "rated at" |awk '{print $7}' |cut -f 1 -d '/').svg -O ${TARGET}/pylint-badge.svg
# Build docs if this is master branch, and HEAD has a tag associated with it
if [[ $TRAVIS_BRANCH == "master" ]] && git describe --exact-match HEAD; then
  echo "Deploying docs to gh-pages..."
  travis-sphinx --outdir=${TARGET} deploy
fi