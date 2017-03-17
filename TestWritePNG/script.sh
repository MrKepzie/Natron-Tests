#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -x # Print commands and their arguments as they are executed.

RENDERER_BIN="$1"
FFMPEG_BIN="$2"
IDIFF_BIN="$3"
CWD=`pwd`
NAME=TestWritePNG
IMAGES_FILE_EXT=png
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$RENDERER_BIN" = "" ] && [ "$FFMPEG_BIN" = "" ] && [ "$IDIFF_BIN" = "" ]; then
  echo "Can't find required apps"
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

echo "===================$NAME========================"
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} test.ntp #> /dev/null 2>&1
for i in a8 a16 g8 g16 ga8 ga16 rgb8 rgb16 rgba8 rgba16; do
    FAIL=0
    "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" -fail 0.001 -abs -scale 10 &> res
    if [ $? != 0 ]; then
	FAIL=1
    fi
    resstatus=$(grep FAILURE res || true)
    x=$NAME/$i
    if [ "$FAIL" != 0 ] || [ ! -z "$resstatus" ]; then
        echo "WARNING: unit test failed for frame $i: $(cat res)"
	echo "$x : FAIL" >> $RESULTS
    else
        echo "PASSED: unit test passed for frame $i: $(cat res)"
	echo "$x : PASS" >> $RESULTS
    fi
done
#  rm -f output* res comp*
