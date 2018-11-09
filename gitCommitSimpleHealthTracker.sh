#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "will change to dir $DIR"

cd $DIR


if [ "$1" = "" ]; then
	echo "Must supply message for commit ! "
	exit 1
fi

git pull
git add .
git commit -m "$1"
git push


