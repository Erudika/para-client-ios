#!/bin/bash
read -e -p "Tag: " ver
git add -A && git commit -m "Release $ver."
git tag "$ver"
git push origin master && git push --tags
pod trunk push ParaClient.podspec
