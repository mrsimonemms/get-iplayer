#!/bin/sh

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

update_version() {
  NEW_VERSION=$(sed -e "s/v/${replace}/g" <<< ${TRAVIS_TAG})

  rm ./VERSION || true
  echo "${NEW_VERSION}" > ./VERSION
  git add ./VERSION
  git commit --message "${NEW_VERSION}"
}

upload_files() {
  git remote add origin-version https://${GH_TOKEN}@${GH_URL} > /dev/null 2>&1
  git push --quiet --set-upstream origin-version master
}

setup_git
update_version
upload_files
