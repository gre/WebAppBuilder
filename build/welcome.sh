#!/bin/bash
echo "   Welcome to ~ Web App Builder ~ by @greweb";

DEBUG=${DEBUG:-false}

if [ $DEBUG = true ] ; then
  echo "";
  echo "warning: DEBUG = true : no javascript / css will be minified!" >&2;
fi;

echo "";
