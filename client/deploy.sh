#!/bin/bash
coffee --bare --compile  static/
mkdir tmp
cp index.html tmp/
cp static/ tmp/ -r
cd tmp
git init
git remote add origin git@github.com:zoorilla/zoorilla.github.io.git
git add .
git commit -a -m "Initial commit"
git push origin master:gh-pages --force
cd ..
rm tmp -rf