#!/bin/bash
gitbook build
cp _book/* docs
rm -rf _book/
git add .
git commit -m 'update files'
git push origin master

# git push origin `git subtree split --prefix _book master`:gh-pages --force

# delete branch
# git branch -d <branchname>
# git push origin -d <remote_name> <branchname>