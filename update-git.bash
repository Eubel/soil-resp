#!/bin/bash
git pull origin master # get newest branch
git add .
git commit -m "$(date)"
git push origin
read
