#!/bin/bash
read -e -p "Tag: " ver
sed -i -e "s/s\.version = .*/s\.version = "\"$ver\""/g" ParaClient.podspec && rm ParaClient.podspec-e
git add -A && git commit -m "Release $ver."
git tag "$ver"
git push origin master && git push --tags
pod trunk push ParaClient.podspec --allow-warnings
