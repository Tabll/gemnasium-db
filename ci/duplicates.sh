#!/bin/sh

find . -name "*.yml" | tr '[:upper:]' '[:lower:]' \
    | tr '_' '-' | sort | uniq -c | awk '{print $1,$2}' | egrep -v "1 .*" && exit 1

exit 0
