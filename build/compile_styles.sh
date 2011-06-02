#!/bin/bash

SRC_DIR=$1
DIST_DIR=$2
shift
shift

STYLES=$*

DEBUG=${DEBUG:-false}
SASS=`which sass`
SASS_AVAILABLE=false
SASS_COMPASS_AVAILABLE=false
echo "" | $SASS -s &> /dev/null && SASS_AVAILABLE=true
echo "" | $SASS -s --compass &> /dev/null && SASS_COMPASS_AVAILABLE=true
if [ $SASS_AVAILABLE = true ] ; then
  SASS=$SASS"  -q -C -s -I"$SRC_DIR;
  if [ $SASS_COMPASS_AVAILABLE = true ] ; then
    SASS=$SASS" --compass";
  fi;
  if [ $DEBUG = false ] ; then
    SASS=$SASS" --style compact";
  fi;
fi;

for style in $STYLES; do
  tmpf=`mktemp /tmp/compile_styles.XXXXXXXXXX`
  echo -n "" > $tmpf
  set ${style/=/ }
  if [ $# -gt 1 ] ; then
    to=$1
    style=$2
  else
    to=${style/,*/};
    if [[ $to == *.sass ]] ; then
      to=${to/.sass/.css}
    fi
  fi
  for f in ${style//,/ }; do
    if [[ $f == *.sass ]] ; then
      if [ $SASS_AVAILABLE = false ] ; then
        echo "   ERROR: You must have sass installed to use it. Check your PATH." >&2;
        exit 1;
      fi;
      cat ${SRC_DIR}/$f | $SASS >> $tmpf || exit 1;
    elif [[ $f == *.css ]] ; then
      cat ${SRC_DIR}/$f >> $tmpf
    else
      echo "Unknown format for style: "$f >&2
      exit 1;
    fi
  done;
  cat $tmpf > $DIST_DIR/$to
  echo "   STYLES: $DIST_DIR/$to <= $style";
done;
