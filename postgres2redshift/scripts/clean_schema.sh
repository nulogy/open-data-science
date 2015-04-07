#! /bin/bash

# remove any schema* files from the directory
rm -rf $SCHEMADIR/schema*
mkdir -p $SCHEMADIR

# Dump DB's schema
$PGSQL_BIN/pg_dump -h $DBHOST -p $DBHOSTPORT -U $DBOWNER --schema-only --schema=$DBSCHEMA $DBNAME > $SCHEMADIR/schema.sql

##### 1. Cleanup the schema to conform to RedShift syntax

## Only keep CREATE TABLE statements
sed -n '/CREATE TABLE/,/);/p' $SCHEMADIR/schema.sql > $SCHEMADIR/schema_clean.sql

## Append ALTER TABLE statements
sed -n '/ALTER TABLE/,/;/p' $SCHEMADIR/schema.sql >> $SCHEMADIR/schema_clean.sql

## Cleanup ALTER TABLE statements
# Only keep PRIMARY KEYS, FOREIGN KEYS and UNIQUE. Current regex requires that the ALTER TABLE statement spaces two lines
# http://unix.stackexchange.com/questions/26284/how-can-i-use-sed-to-replace-a-multi-line-string
# http://stackoverflow.com/questions/6361312/negative-regex-for-perl-string-pattern-match
perl -0777 -i -pe 's/ALTER TABLE(?!UNIQUE|PRIMARY|FOREIGN).*;//g' $SCHEMADIR/schema_clean.sql

# Remove ONLY statement that is not supported
perl -0777 -i -pe 's/ALTER TABLE ONLY/ALTER TABLE/g' $SCHEMADIR/schema_clean.sql

# Remove CHECK CONSTRAINTS that Redshift doesn't support, along with last comma
perl -0777 -i -pe 's/,\n(\s*CONSTRAINT.*\n)*(?=\)\;)//g' $SCHEMADIR/schema_clean.sql

# Remove iterators on columns
sed -i.bak 's/DEFAULT nextval.*/NOT NULL,/g' $SCHEMADIR/schema_clean.sql

# Remove system DB tables
sed -i.bak '/CREATE TABLE dba_snapshot*/,/);/d' $SCHEMADIR/schema_clean.sql
sed -i.bak '/CREATE TABLE jbpm*/,/);/d' $SCHEMADIR/schema_clean.sql
sed -i.bak '/ALTER TABLE jbpm*/,/;/d' $SCHEMADIR/schema_clean.sql

# Remove unsupported commands and types (json, numeric(45))
sed -i.bak 's/ON DELETE CASCADE//g' $SCHEMADIR/schema_clean.sql
sed -i.bak 's/ON UPDATE CASCADE//g' $SCHEMADIR/schema_clean.sql
sed -i.bak 's/SET default.*//g' $SCHEMADIR/schema_clean.sql
sed -i.bak 's/numeric(45/numeric(37/g' $SCHEMADIR/schema_clean.sql
sed -i.bak 's/json NOT NULL/text NOT NULL/g' $SCHEMADIR/schema_clean.sql
sed -i.bak 's/extensions\.\w*/text/g' $SCRPTDIR/schema_clean.sql

# Replace columns named "open" with "open_date", as "open" is a reserved word. Other Redshift reserved words: time, user
sed -i.bak 's/open character/open_date character/g' $SCHEMADIR/schema_clean.sql

# TEXT type is not supported and auto converted, so need to enforce boundless varchar instead: http://docs.aws.amazon.com/redshift/latest/dg/r_Character_types.html
# Also, remove all NOT NULL constraints on varchar/text types that break import due to collision with Redshift's BLANKSASNULL AND EMPTYASNULL copy flags
# Removing NOT NULL on some tables may cause index errors in redshift.err log. If the issue cause problems, then just edit the regex to keep NOT NULL on columns that are supposed to be PRIMARY KEY
sed -i.bak -e 's/\(.*\) \(\btext\b\|\bcharacter varying\b.*\) NOT NULL/\1 \2/' \
      -e 's/\(.*\) \btext\b/\1 varchar(max)/' $SCHEMADIR/schema_clean.sql

# Custom Cleaning (add any regex to clean out other edge cases if your schema fails to build in Redshift)
sed -i.bak '/CREATE TABLE your_unwanted_table_name*/,/);/d' $SCHEMADIR/schema_clean.sql

##### 2. Add sortkeys to table definitions (python script)

$PYTHONBIN $SCRIPTDIR/p2r_add_sortkeys.py -i $SCHEMADIR/schema_clean.sql -o $SCHEMADIR/schema_final.sql

# take a nap for 30 seconds while python script completes (there are better approaches in notes)
sleep 30

##### 3. Add ALTER TABLE statements back to the final schema file

sed -n '/ALTER TABLE/,/;/p' $SCHEMADIR/schema_clean.sql >> $SCHEMADIR/schema_final.sql

##### 4. Restore data into a new schema, instead of nuking current schema

# add search_path to temp_schema
sed -i "1 i SET search_path TO ${TMPSCHEMA};" $SCHEMADIR/schema_final.sql
