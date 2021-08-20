#!/usr/bin/env bash

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" &> /dev/null && pwd )"
previous=$(pwd)

cd $root

# build x86
rm -rf ~/.cache/nim/xue*
nimble build --passC:"'-target x86_64-apple-macos10.8'" --passL:"'-target x86_64-apple-macos10.8'" $@
mv $root/bin/{xue,xue-macosx-amd64}

# build ARM
rm -rf ~/.cache/nim/xue*
nimble build --passC:"'-target arm64-apple-macos11'" --passL:"'-target arm64-apple-macos11'" $@
mv $root/bin/{xue,xue-macosx-arm64}

# build universal
lipo -create -output $root/bin/xue $root/bin/xue-macosx-amd64 $root/bin/xue-macosx-arm64

cd $previous