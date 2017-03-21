#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
#set -x # Print commands and their arguments as they are executed.

if [ $# != 3 ]; then
    echo "Usage: $0 <absolute path to NatronRenderer binary> <ffmpeg binary> <idiff binary>"
    exit 1
fi

if ! type "$1" > /dev/null; then
    echo "Error: $1 is not executable or is not in PATH"
    exit 1
fi
if ! type "$2" > /dev/null; then
    echo "Error: $2 is not executable or is not in PATH"
    exit 1
fi
if ! type "$3" > /dev/null; then
    echo "Error: $3 is not executable or is not in PATH"
    exit 1
fi

RENDERER_BIN="$1"
CWD="$PWD"
NAME=TestPY
uname="$(uname)"

if [ "$uname" = "Darwin" ]; then
    # timeout is available in GNU coreutils:
    # sudo port install coreutils
    # or
    # brew install coreutils
    TIMEOUT="gtimeout"
else
    TIMEOUT="timeout"
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

rm -f *output* res &> /dev/null || true

echo "===================$NAME========================"
for i in "$CWD"/test___*.py; do
    SCRIPT=`echo $i | sed 's/___/ /g;s/.py//g' | awk '{print $2}'`
    if [ "$SCRIPT" != "" ]; then
	FAIL=0
	DIFF1=
	env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} "$CWD"/test___$SCRIPT.py &> res || FAIL=1
	x="$NAME/$SCRIPT"
	# option -w: ignore whitespace (and windows line endings)
	if [ ! -f "$CWD/test___$SCRIPT-output.txt" ]; then
	    DIFF1="Failed (no output)"
	else
	    DIFF1="$(diff -w $CWD/test___$SCRIPT-reference.txt $CWD/test___$SCRIPT-output.txt)"
	fi
	if [ "$FAIL" != 0 ]; then
	    DIFF1="$DIFF1 $(cat res)"
	fi
	if [ "$DIFF1" != "" ]; then
	    echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x: $DIFF1"
	    echo "$x : FAIL" >> $RESULTS
	    echo "$DIFF1"
	else
	    echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $x"
	    echo "$x : PASS" >> $RESULTS
	fi
    fi
done

rm -f *output* res &> /dev/null || true

