#!/bin/sh
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cd "$(dirname "$0")/.." || exit 1

CMD="black"
UPSTREAM_URL="$(git config remote.upstream.url)"
if [ -z "$UPSTREAM_URL" ]
then
    echo "Setting upstream remote"
    git remote add upstream https://github.com/facebookresearch/ClassyVision.git
elif [ ! "$UPSTREAM_URL" == "https://github.com/facebookresearch/ClassyVision.git" ] && \
     [ ! "$UPSTREAM_URL" == "git@github.com:facebookresearch/ClassyVision.git" ]
then
    echo "upstream remote set to $UPSTREAM_URL. Exiting"
    exit 1
fi

# fetch upstream
git fetch upstream

CHANGED_FILES="$(git diff --name-only upstream/master | grep '\.py$' | tr '\n' ' ')"

while getopts bs opt; do
  case $opt in
    s)
      CMD="isort"
      ;;

    b)
      CMD="black"
      ;;

    *)
      CMD="black"
  esac

  done

if [ "$CHANGED_FILES" != "" ]
then
    if [ "$CMD" = "black" ]
    then
        if [ ! "$(black --version)" ]
        then
            echo "Please install black."
            exit 1
        fi
        cmd="black --check $CHANGED_FILES"
    else
        if [ ! "$(isort --version)" ]
        then
            echo "Please install isort."
            exit 1
        fi
        cmd="isort $CHANGED_FILES -c"
    fi
    echo "Running command \"$cmd\""
    ($cmd)
else
    echo "No changes made to any Python files. Nothing to do."
fi

