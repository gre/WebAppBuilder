#!/bin/bash

SRC_DIR=$1
DIST_DIR=$2
shift
shift

SCRIPTS=$*

HERE=`dirname $0`
JS_ENGINE=`which node nodejs 2> /dev/null`

DEBUG=${DEBUG:-false}
COMPILER="${JS_ENGINE} $HERE/uglify.js --unsafe"
POST_COMPILER="${JS_ENGINE} $HERE/post-compile.js"

# $1 : if true minify , else don't minify
function minimify_js {
  errorFile=`mktemp /tmp/compile_scripts.XXXXXXXXXX`
  if [ "$1" = "false" ] ; then 
    cat
  else
    if [ "$JS_ENGINE" = "" ] ; then
      echo "   ERROR: You must have node installed to use it. Check your PATH." >&2;
      exit 1;
    fi;
    f=`mktemp /tmp/compile_scripts.XXXXXXXXXX`
    cat > $f
    $COMPILER $f 1> $f.tmp 2> $errorFile
    if [ `cat $errorFile | wc -c` -gt 0 ] ; then
      cat $errorFile >&2;
      exit 1;
    fi;
    $POST_COMPILER $f.tmp > $f
    cat $f
  fi
  exit 0;
}

function setIFS {
  OLDIFS=$IFS;
  IFS=$1;
}

function restoreIFS {
  IFS=$OLDIFS;
}

function scriptName {
  script=$1
  if [ "${script:0:1}" = "!" ] ; then
    script=${script:1};
  fi
  if [[ $1 == http://* ]] ; then
    script=${script##*/}
  fi;
  echo $script
}

last_handle_js=""
function handle_js {
  local minify=false
  local from=$1
  if [ "${from:0:1}" = "!" ] ; then
    if [ $DEBUG = false ] ; then
      minify=true
    fi;
    from=${from:1}
  fi
  if [[ $from == http://* ]]
    then curl -s $from
    else cat ${SRC_DIR}/$from
  fi | minimify_js $minify
  
  if [ $? == 1 ] ; then
    echo "ERROR: Failed for $from" >&2;
    exit 1;
  fi;
  
  if [[ $from == http://* ]]
    then last_handle_js=${from##*/};
    else last_handle_js=$from;
  fi
}

for script in ${SCRIPTS}; do 
  to=""
  tmpf=`mktemp /tmp/compile_scripts.XXXXXXXXXX`
  echo -n "" > $tmpf
  set ${script/=/ }
  if [ $# -gt 1 ] ; then
    to=$1
    script=$2
  else
    to=`scriptName ${script/,*/}`
  fi
  for f in ${script//,/ }; do
    handle_js $f >> $tmpf
    echo "" >> $tmpf
  done;
  
  cat $tmpf > $DIST_DIR/$to
  echo "  SCRIPTS: $DIST_DIR/$to <= $script"
  
done;
