#!/bin/bash

SRC_DIR=$1
DIST_DIR=$2
shift
shift

RESOURCES=$*

for f in ${RESOURCES}; do
  set ${f/=/ };
  if [ $# -gt 1 ] ; then
    to=$1;
    from=$2;
  else
    to=$1;
    from=$1;
  fi
	cp -r $SRC_DIR/$from $DIST_DIR/$to;
  if [ $? = 0 ] ; then
    echo "RESOURCES: $DIST_DIR/$to <= $from";
  else
    echo "   ERROR: unable to copy resource $DIST_DIR/$to";
    exit 1;
  fi;
done;
