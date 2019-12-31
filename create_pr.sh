#!/bin/bash -eux

COUNT=0
while [ $COUNT -le 3 ]; do
  COUNT=$((COUNT+1))
  echo "*** $COUNT"
  git checkout -b pr_$COUNT
  date >> date_$COUNT
  git add date_$COUNT
  git commit -m "done with pr_$COUNT"
  git push
  hub pull-request --no-edit
  git checkout master
  git branch -D pr_$COUNT
done
