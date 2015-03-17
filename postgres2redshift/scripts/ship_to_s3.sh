#! /bin/bash

# ship original tables
for table in $TABLES
do
  s3cmd put $DATADIR/${table}.txt.gz s3://$S3BUCKET/ --force 1>>$STDOUT 2>>$STDERR
done

# ship custom tables
for table in ${CTNAMES[@]}
do
  s3cmd put $DATADIR/${table}.txt.gz s3://$S3BUCKET/ --force 1>>$STDOUT 2>>$STDERR
done
