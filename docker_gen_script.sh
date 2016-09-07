#/bin/bash

# linux/mac
if [ -f  report/lcov.info ]
then
echo "Gen lcov report"
X1=`pwd`
# sed -e 's#\.#'$X1'#' lcov.info > lcov.info
genhtml -s -o $X1/report/html --function-coverage --branch-coverage report/lcov.info
else
echo "report/lcov.info not found"
fi
