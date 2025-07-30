#!/bin/bash

repo="GitCourser/AlistLite"
# version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name')
version=$(cat ../../alist_version)
echo "AlistLite - ${version}"
wget https://github.com/$repo/archive/refs/tags/$version.tar.gz
tar xzf $version.tar.gz --strip-components=1 -C ..

wget https://github.com/GitCourser/alist-web/releases/latest/download/dist.tar.gz
tar xzf dist.tar.gz
rm -rf ../public/dist/*
mv -f dist/index.html ../public/dist
rm -rf dist

rm *.tar.gz