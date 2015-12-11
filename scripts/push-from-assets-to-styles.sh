#!/bin/bash

##############################################
##      CONTINUOUS INTEGRATION SCRIPT
##############################################

# The -e flag causes the script to exit as soon as one command returns a non-zero exit code
# The -v flag makes the shell print all lines in the script before executing them, which helps identify which steps failed.
set -ev

echo TRAVIS_TEST_RESULT : $TRAVIS_TEST_RESULT
echo TRAVIS_PULL_REQUEST = $TRAVIS_PULL_REQUEST

# test if the build is not from a pull request
if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
  echo -e "Starting to update script repository with an assets repository build result\n"

  #copy data we're interested in to other place
  cp -R _site/assets $HOME/assets

  #go to home and setup git
  cd $HOME

  git config --global user.email $GIT_EMAIL
  git config --global user.name $GIT_NAME

  #using token clone gh-pages branch
  # please note that some output is redirected to /dev/null to avoid leaking of decrypted token.
  git clone --branch=gh-pages https://${GH_TOKEN}@github.com/swctasks/styles.git styles
  # > /dev/null

  #go into directory and copy data we're interested in to that directory
  cd styles

  # remove assets from the clone before copying
  rm -rf ./assets

  cp -Rf $HOME/assets .

  #add, commit and push files
  git add -f .
  git commit -m "Travis build $TRAVIS_BUILD_NUMBER from assets repository"
  git push -fq origin gh-pages # > /dev/null

  echo -e "SUCCESS : Assets pushed to style repository\n"
fi
