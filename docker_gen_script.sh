#/bin/bash

if [ -f  lcov.info ]
then
echo "Gen lcov report"
cp lcov.info tmp_lcov.info
tr -d '\r' <tmp_lcov.info > lcov.info
X1=`pwd`
sed -e 's#\.#'$X1'#' lcov.info > lcov_.info
genhtml -s -o $X1 --function-coverage --branch-coverage lcov_.info
else
echo "Not lcov.info at directory"
fi 