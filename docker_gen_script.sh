#!/bin/bash

# remove all generated HTML
#for file in $(ls /tmp/report/html | grep -v readme.md); do rm -rf  $file; done

# Remove directories from source - all previously processed sources are in dirs
# all new sources are still in files in report/src
#for file in $(ls /tmp/report/src/*/ | grep -v readme.md); do rm -rf  $file; done

for file in /tmp/report/src/*.sql; do
  IFS="." read -a array <<< "$(basename "$file")"
  targetDir="/tmp/report/src/${array[0]}/${array[2]}/"
  targetFile="${array[1]}.sql"
  mkdir -p "${targetDir}"
  mv $file "${targetDir}${targetFile}"
done

if [ -f  /tmp/report/lcov.info ]; then
  echo "Generating lcov report"
  genhtml -s -o /tmp/report/html --function-coverage --branch-coverage --legend -p /tmp/report/src /tmp/report/lcov.info
else
  echo "report/lcov.info not found"
  echo "na te klavesnici se nepise zase tak spatne, jak to na prvni pohled vypada"
fi
