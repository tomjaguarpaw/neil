#!/bin/sh
# This script is invoked from my Travis commands
# It bootstraps to grab the a binary release and run it
set -e # exit on errors

PACKAGE=$1
if [ -z "$PACKAGE" ]; then
    echo No arguments provided, please pass the project name as the first argument
    exit 1
fi
shift

echo Downloading and running $PACKAGE...
# Don't go for the API since it hits the Appveyor GitHub API limit and fails
RELEASES=$(curl --silent https://github.com/ndmitchell/$PACKAGE/releases)
URL=https://github.com/$(echo $RELEASES | grep -o '\"[^\"]*-x86_64-linux\.tar\.gz\"' | sed s/\"//g | head -n1)
VERSION=$(echo $URL | sed -e 's/.*-\([\.0-9]\+\)-x86_64-linux\.tar\.gz/\1/')

echo URL is $URL
echo SED RESULT is $(sed -e 's/.*-\([\.0-9]\+\)-x86_64-linux\.tar\.gz/\1/' $URL)
echo SED RESULT2 is $(sed -e 's/.*-\([\.0-9]\+\)-x86_64-linux\.tar\.gz/\1/g' $URL)
echo SED RESULT3 is $(sed 's/.*-\([\.0-9]\+\)-x86_64-linux\.tar\.gz/\1/g' $URL)
echo SED RESULT4 is $(sed 's/^.*-\(.+\)-x86_64-linux.tar.gz/\1/g' $URL)
echo VERSION is $VERSION

TEMP=$(mktemp -d .$PACKAGE-XXXXX)

cleanup(){
    rm -r $TEMP
}
trap cleanup EXIT

curl --progress-bar --location -o$TEMP/$PACKAGE.tar.gz $URL
tar -xzf $TEMP/$PACKAGE.tar.gz -C$TEMP
$TEMP/$PACKAGE-$VERSION/$PACKAGE $*
