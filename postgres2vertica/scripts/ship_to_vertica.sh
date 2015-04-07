#! /bin/bash
ssh -i $VERTICA_KEYFILE $VERTICA_SSH_USER@$VERTICA_SSH_HOST "mkdir -p $VERTICA_TMP_DIR" 1>>$STDOUT 2>>$STDERR

# ship original tables
for table in $TABLES
do
  scp -i $VERTICA_KEYFILE $DATADIR/${table}.txt.gz $VERTICA_SSH_USER@$VERTICA_SSH_HOST:$VERTICA_TMP_DIR/ 1>>$STDOUT 2>>$STDERR
done

# ship custom tables
for table in ${CTNAMES[@]}
do
  scp -i $VERTICA_KEYFILE $DATADIR/${table}.txt.gz $VERTICA_SSH_USER@$VERTICA_SSH_HOST:$VERTICA_TMP_DIR/ 1>>$STDOUT 2>>$STDERR
done
