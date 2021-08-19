#!/usr/bin/env bash

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" &> /dev/null && pwd )"
rm -rf "$root/.git/hooks"
ln -s "$root/hooks" "$root/.git/hooks"
