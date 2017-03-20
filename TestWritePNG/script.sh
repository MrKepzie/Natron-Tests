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
FFMPEG_BIN="$2"
IDIFF_BIN="$3"
CWD="$PWD"
NAME=TestWritePNG
uname="$(uname)"
IMAGES_FILE_EXT=png
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"


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

echo "===================$NAME========================"
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} test.ntp #> /dev/null 2>&1
for i in a8 a16 g8 g16 ga8 ga16 rgb8 rgb16 rgba8 rgba16; do
    FAIL=0
    "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" -fail 0.001 -abs -scale 10 &> res || FAIL=1
    resstatus=$(grep FAILURE res || true)
    x="$NAME/$i"
    if [ "$FAIL" != 0 ] || [ ! -z "$resstatus" ]; then
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x: $(cat res)"
	echo "$x : FAIL" >> $RESULTS
    else
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $x"
	echo "$x : PASS" >> $RESULTS
    fi
done
#  rm -f output* res comp*
