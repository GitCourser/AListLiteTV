#!/bin/bash

cd ../alistlib || exit

builtAt="$(date +'%F %T %z')"
gitAuthor="Courser"
# version=$(curl -s "https://api.github.com/repos/GitCourser/AlistLite/releases/latest" | jq -r '.tag_name')
version=$(cat ../../alist_version)
webVersion=$(curl -s "https://api.github.com/repos/GitCourser/alist-web/releases/latest" | jq -r '.tag_name')
webVersion=${webVersion:-3.45.0}

echo "backend version: $version"
echo "frontend version: $webVersion"

ldflags="\
-w -s \
-X 'github.com/alist-org/alist/v3/internal/conf.BuiltAt=$builtAt' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitAuthor=$gitAuthor' \
-X 'github.com/alist-org/alist/v3/internal/conf.Version=$version' \
-X 'github.com/alist-org/alist/v3/internal/conf.WebVersion=$webVersion' \
"

if [ "$1" == "debug" ]; then
  gomobile bind -trimpath -ldflags "$ldflags" -v -androidapi 19 -target="android/amd64"
else
  gomobile bind -trimpath -ldflags "$ldflags" -v -androidapi 19
fi

echo "Moving aar and jar files to android/app/libs"
mkdir -p ../../android/app/libs
mv -f ./*.aar ../../android/app/libs
mv -f ./*.jar ../../android/app/libs
