#! /bin/bash

message "CREATE NEW TEMP SCHEMA"
$PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
  "CREATE SCHEMA $TMPSCHEMA;
  SET search_path TO $TMPSCHEMA;
  GRANT ALL ON SCHEMA $TMPSCHEMA TO $RSUSER;
  GRANT USAGE ON SCHEMA $TMPSCHEMA TO $RSUSER;
  GRANT SELECT ON ALL TABLES IN SCHEMA $TMPSCHEMA TO $RSUSER;
  COMMENT ON SCHEMA $TMPSCHEMA IS 'temporary refresh schema';" 1>>$STDOUT 2>>$STDERR

##### 5. Load schema file into TMPSCHEMA
$PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -f $SCRPTDIR/schema_final.sql 1>>$STDOUT 2>>$STDERR