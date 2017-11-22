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
# fail if more than 0.1% of pixels have an error larger than 0.001 or if any pixel has an error larger than 0.01
IDIFF_OPTS="-fail 0.001 -failpercent 0.1 -hardfail 0.01 -abs -scale 100"
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
echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $NAME"
renderfail=0
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} test.ntp || renderfail=1
if [ "$renderfail" != "1" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** END render $NAME"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** END render $NAME (WARNING: render failed)"
    # ignore failure, but check the output images
fi
for i in a8 a16 g8 g16 ga8 ga16 rgb8 rgb16 rgba8 rgba16; do
    FAIL=0
    # idiff's "WARNING" gives a non-zero return status
    "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" $IDIFF_OPTS &> res || true
    x="$NAME/$i"
    if [ ! -f "output${i}.$IMAGES_FILE_EXT" ]; then
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x"
	echo "$x : FAIL" >> $RESULTS
    elif [ ! -z "$(grep FAILURE res || true)" ]; then
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x:"
	cat res
	echo "$x : FAIL" >> $RESULTS
    elif [ ! -z "$(grep WARNING res || true)" ]; then
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** WARN $x:"
	cat res
	echo "$x : PASS" >> $RESULTS
    else
	echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $x"
	echo "$x : PASS" >> $RESULTS
    fi
done
#  rm -f output* res comp*
