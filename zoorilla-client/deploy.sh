#!/bin/bash
# GitHub deploy script
# author: Ondrej Sika

GITHUB_REPO="git@github.com:zoorilla/zoorilla.github.io.git"

sh build.sh

gittmp="tmpgit$RANDOM$RANDOM"

git --git-dir=$gittmp --work-tree="." init
git --git-dir=$gittmp --work-tree="." remote add origin $GITHUB_REPO
git --git-dir=$gittmp --work-tree="." add .
git --git-dir=$gittmp --work-tree="." commit -a -m "Automatic build"
git --git-dir=$gittmp push origin master --force
git --git-dir=$gittmp push origin master:gh-pages --force

rm $gittmp -rf

