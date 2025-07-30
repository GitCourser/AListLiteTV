#!/bin/bash

GIT_REPO="GitCourser/AlistLite"

function to_int() {
    echo $(echo "$1" | grep -oE '[0-9]+' | tr -d '\n')
}

function get_latest_version() {
    echo $(curl -s "https://api.github.com/repos/$GIT_REPO/releases/latest" | jq -r '.tag_name')
}

LATEST_VER=""
for index in $(seq 5)
do
    echo "Try to get latest version, index=$index"
    LATEST_VER=$(get_latest_version)
    if [ -z "$LATEST_VER" ]; then
      if [ "$index" -ge 5 ]; then
        echo "Failed to get latest version, exit"
        exit 1
      fi
      echo "Failed to get latest version, sleep 15s and retry"
      sleep 15
    else
      break
    fi

done

LATEST_VER_INT=$(to_int "$LATEST_VER")
echo "Latest AlistLite version $LATEST_VER ${LATEST_VER_INT}"
echo "alist_version=$LATEST_VER" >> "$GITHUB_ENV"

VER=$(cat "$VERSION_FILE")
VER_INT=$(to_int $VER)
echo "Current AlistLite version: $VER ${VER_INT}"

if [ "$VER_INT" -ge "$LATEST_VER_INT" ]; then
    echo "Current >= Latest"
    echo "alist_update=0" >> "$GITHUB_ENV"
else
    echo "Current < Latest"
    echo "alist_update=1" >> "$GITHUB_ENV"
fi
