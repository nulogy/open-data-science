#! /bin/bash
# Copy a table into Redshift from S3 file:
  # To test without the data load, add NOLOAD to the copy command.
  # CSV cannot be used with FIXEDWIDTH, REMOVEQUOTES, or ESCAPE.
  # Remove MAXERROR from production. Analysize /tmp/p2r.err for error log
  # NULLify empties: BLANKSASNULL, EMPTYASNULL.

# restore original tables
for table in $TABLES
do
  $VSQL_BIN/vsql -h $VERTICA_HOST -p $VERTICA_PORT -U $VERTICA_USER -d $VERTICA_DB -c \
    "SET search_path TO $TMPSCHEMA;
    copy ${table} FROM '$VERTICA_TMP_DIR/${table}.txt.gz' \
      GZIP DELIMITER '|';" 1>>$STDOUT 2>>$STDERR
done

# restore custom tables
for table in ${CTNAMES[@]}
do
  $VSQL_BIN/vsql -h $VERTICA_HOST -p $VERTICA_PORT -U $VERTICA_USER -d $VERTICA_DB -c \
    "SET search_path TO $TMPSCHEMA;
    copy ${table} FROM '$VERTICA_TMP_DIR/${table}.txt.gz' \
      GZIP DELIMITER '|';" 1>>$STDOUT 2>>$STDERR
done

# Swap temp_schema for production schema
echo DROP $VERTICA_SCHEMA AND RENAME $TMPSCHEMA SCHEMA TO $VERTICA_SCHEMA
$VSQL_BIN/vsql -h $VERTICA_HOST -p $VERTICA_PORT -U $VERTICA_USER -d $VERTICA_DB -c \
  "DROP SCHEMA IF EXISTS $VERTICA_SCHEMA CASCADE;
  ALTER SCHEMA $TMPSCHEMA RENAME TO $VERTICA_SCHEMA;
  SET search_path TO $VERTICA_SCHEMA;
  GRANT ALL ON SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;
  GRANT USAGE ON SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;
  GRANT SELECT ON ALL TABLES IN SCHEMA $VERTICA_SCHEMA TO $VERTICA_USER;
  COMMENT ON SCHEMA $VERTICA_SCHEMA IS 'analytics data schema';" 1>>$STDOUT 2>>$STDERR

# $VSQL_BIN/vsql -h $VERTICA_HOST -p $VERTICA_PORT -U $VERTICA_USER -d $VERTICA_DB -c "vacuum; analyze;" 1>>$STDOUT 2>>$STDERR