#! /bin/bash

# ship original tables
for schema in $SCHEMAS
do
  for table in $TABLES
  do
    s3cmd put $DATADIR/${schema}-${table}.txt.gz s3://$S3BUCKET/ --force 1>>$STDOUT 2>>$STDERR
  done
done

# ship custom tables
for schema in $SCHEMAS
do
  for table in ${CTNAMES[@]}
  do
    s3cmd put $DATADIR/${schema}-${table}.txt.gz s3://$S3BUCKET/ --force 1>>$STDOUT 2>>$STDERR
  done
done