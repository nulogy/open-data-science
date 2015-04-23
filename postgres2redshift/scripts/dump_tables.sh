#! /bin/bash

# dumping original tables
for schema in $SCHEMAS
do
  for table in $TABLES
  do
    $PGSQL_BIN/psql -h $DBHOST -p $DBHOSTPORT -U $DBOWNER -d $DBNAME -c \
      "\copy ${schema}.${table} TO STDOUT (FORMAT csv, DELIMITER '|', HEADER 0)" \
      | gzip > $DATADIR/${schema}-${table}.txt.gz
  done
done

# dumping custom tables
for (( i = 0 ; i < ${#CTSQL[@]} ; i++ ))
do
  $PGSQL_BIN/psql -h $DBHOST -p $DBHOSTPORT -U $DBOWNER -d $DBNAME -c \
    "\copy ( ${CTSQL[$i]} ) TO STDOUT (FORMAT csv, DELIMITER '|', HEADER 0)" \
    | gzip > $DATADIR/${CTNAMES[$i]}.txt.gz
done

