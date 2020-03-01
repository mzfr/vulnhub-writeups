#!/bin/bash

blogfile="/home/mzfr/dev/mzfr.github.io/vulnhub.md"
#Find the changes made to the Readme.md file
changes=$(git diff | sed -n '/^+/p' | tail -n 1 | tr -d '+')

#Find the line number in which changes had to be added
line=$(grep -n "__Note__" $blogfile | cut -d: -f1)

lineNumber=$(($line-1))

#Adding the line to blog file.
sed -i "${lineNumber}i $changes" $blogfile
