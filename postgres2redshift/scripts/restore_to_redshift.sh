#! /bin/bash
# Copy a table into Redshift from S3 file:
  # To test without the data load, add NOLOAD to the copy command.
  # CSV cannot be used with FIXEDWIDTH, REMOVEQUOTES, or ESCAPE.
  # Remove MAXERROR from production. Analysize /tmp/p2r.err for error log
  # NULLify empties: BLANKSASNULL, EMPTYASNULL.

source settings.sh

# restore original tables
for schema in $SCHEMAS
do
  TMPACCTSCHEMA=$schema\_$TMPSCHEMA

  for table in $TABLES
  do
    $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
      "SET search_path TO $TMPACCTSCHEMA;
      copy ${table} from 's3://$S3BUCKET/${schema}-${table}.txt.gz' \
        REGION AS '$S3REGION' \
        CREDENTIALS 'aws_access_key_id=$RSKEY;aws_secret_access_key=$RSSECRET' \
        CSV DELIMITER '|' IGNOREHEADER 0 ACCEPTINVCHARS TRUNCATECOLUMNS GZIP TRIMBLANKS BLANKSASNULL EMPTYASNULL DATEFORMAT 'auto' ACCEPTANYDATE COMPUPDATE ON MAXERROR 100;" 1>>$STDOUT 2>>$STDERR
  done
done

# restore custom tables
for schema in $SCHEMAS
do
  TMPACCTSCHEMA=$schema\_$TMPSCHEMA

  for table in ${CTNAMES[@]}
  do
    $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
      "SET search_path TO $TMPACCTSCHEMA;
      copy ${table} from 's3://$S3BUCKET/${schema}-${table}.txt.gz' \
        REGION AS '$S3REGION' \
        CREDENTIALS 'aws_access_key_id=$RSKEY;aws_secret_access_key=$RSSECRET' \
        CSV DELIMITER '|' IGNOREHEADER 0 ACCEPTINVCHARS TRUNCATECOLUMNS GZIP TRIMBLANKS BLANKSASNULL EMPTYASNULL DATEFORMAT 'auto' ACCEPTANYDATE COMPUPDATE ON MAXERROR 100;" 1>>$STDOUT 2>>$STDERR
  done
done

# Swap temp_schema for production schema
for schema in $SCHEMAS
do
  TMPACCTSCHEMA=$schema\_$TMPSCHEMA
  echo DROP $RSSCHEMA AND RENAME $TMPACCTSCHEMA SCHEMA TO $RSSCHEMA

  $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c \
    "DROP SCHEMA IF EXISTS $schema CASCADE;
    ALTER SCHEMA $TMPACCTSCHEMA RENAME TO $schema;
    SET search_path TO $schema;
    GRANT ALL ON SCHEMA $schema TO $RSUSER;
    GRANT USAGE ON SCHEMA $schema TO $RSUSER;
    GRANT SELECT ON ALL TABLES IN SCHEMA $schema TO $RSUSER;
    COMMENT ON SCHEMA $schema IS 'analytics data schema `date`';" 1>>$STDOUT 2>>$STDERR

  $PGSQL_BIN/psql -h $RSHOST -p $RSHOSTPORT -U $RSADMIN -d $RSNAME -c "vacuum; analyze;" 1>>$STDOUT 2>>$STDERR
done
