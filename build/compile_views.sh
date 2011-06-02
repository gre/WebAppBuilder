#!/bin/bash

SRC_DIR=$1
DIST_DIR=$2
shift
shift

VIEWS=$*

HERE=`dirname $0`
JS_ENGINE=`which node nodejs 2> /dev/null`
TEMPLATER="$JS_ENGINE $HERE/templater.js"

for view in ${VIEWS}; do
  set ${view/=/ }
  if [ $# -gt 1 ] ; then
    to=$1
    shift
    view=$*
  else
    to=$view;
  fi
  to=${to%%:*}
  if [[ $view = *:* ]] ; then
    options=${view#*:}
    view=${view%%:*}
  else
    options=""
  fi
  if [ "$JS_ENGINE" = "" ] ; then
    echo "warning: You must have node installed to use Mustache. Check your PATH." >&2;
    cat ${SRC_DIR}/$view > $DIST_DIR/$to
  else
    errorFile=`mktemp /tmp/compile_views.XXXXXXXXXX`
    $TEMPLATER ${SRC_DIR}/$view $options 1> $DIST_DIR/$to 2> $errorFile
    if [ `cat $errorFile | wc -c` -gt 0 ] ; then
      cat $errorFile >&2;
      exit 1;
    fi;
  fi;
  echo -n "    VIEWS: $DIST_DIR/$to <= $view";
  if ! [ "$JS_ENGINE" = "" ] && ! [ "$options" = "" ] ; then
    echo " with $options";
  else
    echo " (without Mustache)";
  fi;
done;
