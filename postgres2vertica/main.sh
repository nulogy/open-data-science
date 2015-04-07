#!/bin/sh

### LICENSE
  # Author: Vlad Dubovskiy, November 2014, DonorsChoose.org
  # Special thanks to: David Crane for code snippets on parsing command args
  # License: Copyright (c) This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

# Load settings, tables file
source ./settings.sh


########################################
#           Data Dump: Params
########################################

# Open lock file sentinal protection
# This section parses command line arguments when you execute the script with /path/to/p2r_main.sh -h source_db_host_name -p 5432 -U dbuser -d dbname 2>&1 >> /tmp/p2r.log

if [ ! -e $LOCKFILE ]; then
  echo "***********************************"
  echo $$ >$LOCKFILE

PROGNAME=`basename $0`

usage ()
{
  echo "usage:  $PROGNAME [-h hostname] [-n] -d dbname -p dbhostport -U username -f filename" >&2
  echo "        -d dbname      (name of postgres database)" >&2
  echo "        -U dbuser      (name of database schema owner)" >&2
  echo "        -h dbhost      (name of database host server)" >&2
  echo "        -p dbhostport  (number of database host port)" >&2
}

DBHOST=''
DBNAME=''
DBOWNER=''
DBHOSTPORT=''

# Break up command-line options for easy parsing.  Reorders legal
# options in front of --, and all others after.  Note that the
# 2-steps with "$@" is essential to preserve multi-word optargs.
GETOPT=`getopt -n $PROGNAME -o h:d:U:f:T:p:n -- "$@"`
if [ $? != 0 ] ; then usage ; rm $LOCKFILE; exit 1 ; fi
eval set -- "$GETOPT"

while true
do
  case "$1" in
    -\?) usage 2>&1; rm $LOCKFILE; exit 0 ;;
    -h) DBHOST="$2"; shift 2;;
    -d) DBNAME="$2"; shift 2;;
    -U) DBOWNER="$2"; shift 2;;
    -p) DBHOSTPORT="$2"; shift 2;;
    --) shift ; break ;;
    * ) echo "Internal error!" >&2; rm $LOCKFILE; exit 1 ;;
  esac
done

# Script invoked with extra command-line args?
if [ $# -ne "0" ]
then
  echo "$PROGNAME: unrecognized parameter -- $*" >&2
  echo >&2
  usage
  rm $LOCKFILE
  exit 2
fi

# Script invoked without required parameters?
if [ -z "$DBNAME" -o -z "$DBOWNER" ]
then
  REQUIRED=''
  if [ -z "$DBNAME" ] ;    then REQUIRED="$REQUIRED -d"; fi
  if [ -z "$DBOWNER" ] ;    then REQUIRED="$REQUIRED -U"; fi
  echo "$PROGNAME: missing required parameter(s) --" $REQUIRED >&2
  echo >&2
  usage
  rm $LOCKFILE
  exit 3
fi

# Close lock file sentinal protection.
# If you are dumping from hot standby replication server, you can wrap the code here and move removing lockfile right before SHIPPPING TABLES TO S3
# This is here for your convenience, it's not a requirement to have this.
  rm $LOCKFILE
else
  echo "  +------------------------------------"
  echo -n "  | "
  date
  echo "  | critical-section is already running"
  echo "  +------------------------------------"
fi

message() {
  echo $1
  date
}

run_script() {
  message "$2 - STARTING"
  source ./scripts/$1
  message "$2 - COMPLETE"
}


########################################
#           Begin Data Dump
########################################
run_script dump_tables.sh "DUMPING TABLES"

########################################
#          SHIP TABLES TO S3
########################################
run_script ship_to_vertica.sh "SHIP TO VERTICA"

########################################
#       Get and clean schema
########################################
run_script clean_schema.sh "GET/CLEAN DB SCHEMA"

########################################
#     Create Schema in Vertica
########################################
run_script create_schema.sh "CREATE SCHEMA IN VERTICA"

########################################
#        Restore in Vertica
########################################
run_script restore_to_vertica.sh "RESTORE TABLES IN VERTICA"

message "BULK REFRESH COMPLETE"
echo "***********************************"


########################################
#        COPY Error Management
########################################

# table.columnx has a wrong date format error:
  # solution: DATEFORMAT 'auto' ACCEPTANYDATE options, which NULLs any unrecognized date formats

# Query to check errors in Vertica
  # select starttime, filename, line_number, colname, position, raw_line, raw_field_value, err_code, err_reason
  # from stl_load_errors
  # where filename like ('%table_name%')
  # order by starttime DESC
  # limit 110;

########################################
#        Future Improvements
########################################

  # replace wait with proper PIDs: http://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
  # Iterative refresh: incremental inserts (say, every hour) instead of dumping the entire schema or individual tables. Remember to vacuum; analyze; afterwards
