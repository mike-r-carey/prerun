#!/usr/bin/env bash

###
# Prints the help message.
##
function prerun.help() {
  echo "Usage: prerun CMD"
  echo ""
  echo "Commands:"
  echo "  help   Prints the help message"
  echo "  dir    Prints the directory where prerun scripts are stored"
  echo "  list   Lists the prerun scripts that are known"
  echo "  load   Adds aliases for each of the prerun scripts"
  echo ""
}

###
# Prints the directory where prerun scripts are stored.
##
function prerun.dir() {
  echo "${PRERUN_DIRECTORY:-$HOME/.prerun}"
}

###
# Lists the prerun scripts that are known.
##
function prerun.list() {
  local pre="$( prerun.dir )"

  if [ -d "$pre" ]; then
    for i in "$pre"/*; do
      if [ ! -f "$i" ]; then
        continue
      fi

      echo "$( basename "$i" )"
    done
  fi
}

###
# Prints aliases for each of the prerun scripts
##
function prerun.hook() {
  local pre="$( prerun.dir )"

  for cmd in $( prerun.list ); do
      echo alias $cmd="'[ -z \"\${PRERUN_DISABLE:-}\" ] && [ -f \"$pre/$cmd\" ] && source \"$pre/$cmd\"; $cmd'"
  done
}

###
# Runs the eval for all of the aliases (Can only be used when ${BASH_SOURCE[0]} != $0)
##
function prerun.load() {
  eval $( prerun.hook )
}

###
# The main function which proxies the command to the proper function.
##
function prerun() {
  local cmd="${1:-help}"
  shift

  prerun.$cmd "${@:-}"
  return $?
}

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
  export -f prerun \
            prerun.help \
            prerun.dir \
            prerun.list \
            prerun.load
else
  prerun "${@:-}"
  exit $?
fi

# envrun
