#!/bin/bash
#
# pocsagSync.sh
#
# John/KI5NYZ 2022
#
# Configuration

time=$(date +"%y%m%d%H%M%S")
prefix="YYYYMMDDHHMMSS"
rubric="216"

#echo "${prefix}${time}"

sudo RemoteCommand 7642 page $rubric "${prefix}${time}"
