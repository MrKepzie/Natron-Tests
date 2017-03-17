#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -x # Print commands and their arguments as they are executed.

if [ $# != 3 ] || [ ! -x "$1" ] || [ ! -x "$2" ] || [ ! -x "$3" ]; then
    echo "Usage: $0 <absolute path to NatronRenderer binary> <ffmpeg binary> <idiff binary>"
    exit 1
fi

RENDERER_BIN="$1"
CWD=`pwd`
NAME=TestPY

if [ "$RENDERER_BIN" = "" ] || [ ! -x "$RENDERER_BIN" ]; then
  echo "Can't find NatronRenderer"
  exit 1
fi

OPTS=("--no-settings")
if [ -n "${OFX_PLUGIN_PATH:-}" ]; then
    echo "OFX_PLUGIN_PATH=${OFX_PLUGIN_PATH:-}, setting useStdOFXPluginsLocation=False"
    OPTS=(${OPTS[@]+"${OPTS[@]}"} "--setting" "useStdOFXPluginsLocation=False")
fi
if [ "$uname" = "Msys" ]; then
    plugin_path="${CWD};${NATRON_PLUGIN_PATH:-}"
else
    plugin_path="${CWD}:${NATRON_PLUGIN_PATH:-}"
fi

rm -f "$CWD"/*output*

echo "===================$NAME========================"
for i in "$CWD"/test___*.py; do
  SCRIPT=`echo $i | sed 's/___/ /g;s/.py//g' | awk '{print $2}'`
  if [ "$SCRIPT" != "" ]; then
      env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} "$CWD"/test___$SCRIPT.py #> /dev/null 2>&1
    # option -w: ignore whitespace (and windows line endings)
    DIFF1=`diff -w $CWD/test___$SCRIPT-reference.txt $CWD/test___$SCRIPT-output.txt`
    if [ ! -f "$CWD/test___$SCRIPT-output.txt" ]; then
      DIFF1="Failed (no output)"
    fi
    if [ "$DIFF1" != "" ]; then
      echo "WARNING: test $SCRIPT failed in TestPY"
      echo "TestPY_$SCRIPT : FAIL" >> $RESULTS
      echo "$DIFF1"
    else
      echo "TestPY passed test $SCRIPT"
      echo "TestPY_$SCRIPT : PASS" >> $RESULTS
    fi
fi
done

rm -f "$CWD"/*output*

