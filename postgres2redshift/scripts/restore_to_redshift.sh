#! /bin/bash
# Copy a table into Redshift from S3 file:
  # To test without the data load, add NOLOAD to the copy command.
  # CSV cannot be used with FIXEDWIDTH, REMOVEQUOTES, or ESCAPE.
  # Remove MAXERROR from production. Analysize /tmp/p2r.err for error log
  # NULLify empties: BLANKSASNULL, EMPTYASNULL.

# restore original tables
for table in $TABLES
do
  $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
    "SET search_path TO $TMPSCHEMA;
    copy ${table} from 's3://$S3BUCKET/${table}.txt.gz' \
      CREDENTIALS 'aws_access_key_id=$RSKEY;aws_secret_access_key=$RSSECRET' \
      REGION AS '$S3REGION' \
      CSV DELIMITER '|' IGNOREHEADER 0 ACCEPTINVCHARS TRUNCATECOLUMNS GZIP TRIMBLANKS BLANKSASNULL EMPTYASNULL DATEFORMAT 'auto' ACCEPTANYDATE COMPUPDATE ON MAXERROR 100;" 1>>$STDOUT 2>>$STDERR
done

# restore custom tables
for table in ${CTNAMES[@]}
do
  $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
    "SET search_path TO $TMPSCHEMA;
    copy ${table} from 's3://$S3BUCKET/${table}.txt.gz' \
      CREDENTIALS 'aws_access_key_id=$RSKEY;aws_secret_access_key=$RSSECRET' \
      REGION AS '$S3REGION' \
      CSV DELIMITER '|' IGNOREHEADER 0 ACCEPTINVCHARS TRUNCATECOLUMNS GZIP TRIMBLANKS BLANKSASNULL EMPTYASNULL DATEFORMAT 'auto' ACCEPTANYDATE COMPUPDATE ON MAXERROR 100;" 1>>$STDOUT 2>>$STDERR
done

# Swap temp_schema for production schema
echo DROP $RSSCHEMA AND RENAME $TMPSCHEMA SCHEMA TO $RSSCHEMA
$PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
  "SET search_path TO $RSSCHEMA;
  DROP SCHEMA IF EXISTS $RSSCHEMA CASCADE;
  ALTER SCHEMA $TMPSCHEMA RENAME TO $RSSCHEMA;
  GRANT ALL ON SCHEMA $RSSCHEMA TO $RSUSER;
  GRANT USAGE ON SCHEMA $RSSCHEMA TO $RSUSER;
  GRANT SELECT ON ALL TABLES IN SCHEMA $RSSCHEMA TO $RSUSER;
  COMMENT ON SCHEMA $RSSCHEMA IS 'analytics data schema';" 1>>$STDOUT 2>>$STDERR

$PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c "vacuum; analyze;" 1>>$STDOUT 2>>$STDERR