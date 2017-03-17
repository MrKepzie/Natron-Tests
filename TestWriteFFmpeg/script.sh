#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -x # Print commands and their arguments as they are executed.

if [ $# != 3 ] || [ ! -x "$1" ] || [ ! -x "$2" ] || [ ! -x "$3" ]; then
    echo "Usage: $0 <absolute path to NatronRenderer binary> <ffmpeg binary> <idiff binary>"
    exit 1
fi

RENDERER_BIN="$1"
FFMPEG_BIN="$2"
IDIFF_BIN="$3"
CWD=`pwd`
NAME=TestWriteFFMpeg
IMAGES_FILE_EXT=jpg
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$(uname -s)" = "Darwin" ]; then
    # timeout is available in GNU coreutils:
    # sudo port install coreutils
    # or
    # brew install coreutils
    TIMEOUT="gtimeout"
else
    TIMEOUT="timeout"
fi

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
for x in $FORMATS/*; do
  cd $x
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $x"
  FORMAT=`cat format`
  rm -f output* res comp*
  env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} test.ntp #> /dev/null 2>&1
  if [ -f "output.$FORMAT" ]; then
    set -x
    $TIMEOUT 1800 "$FFMPEG_BIN" -y -i "output.$FORMAT" "output%1d.$IMAGES_FILE_EXT" </dev/null >/dev/null 2>&1
    set +x
  fi
  if [ -f "last" ]; then
    LAST_FRAME=`cat last`
  fi
  TEST_FAIL=0
  TEST_PASS=0
  SEQ="seq $FIRST_FRAME $LAST_FRAME"
  if [ `uname` = "Darwin" ]; then
    SEQ="jot - $FIRST_FRAME $LAST_FRAME"
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** END $x"
  for i in $($SEQ); do
      FAIL=0
      "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" -fail 0.001 -abs -scale 10 &> res
      if [ $? != 0 ]; then
	  FAIL=1
      fi
      resstatus=$(grep FAILURE res || true)
      if [ "$FAIL" != 0 ] || [ ! -z "$resstatus" ]; then
          echo "WARNING: unit test failed for frame $i in $x: $(cat res)"
	  TEST_FAIL=$((TEST_FAIL+1))
      else
          echo "PASSED: unit test passed for frame $i in $x: $(cat res)"
	  TEST_PASS=$((TEST_PASS+1))
      fi
  done
  if [ "$TEST_FAIL" = 0 ] && [ "$TEST_PASS" = "$LAST_FRAME" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $x"
    echo "$x : PASS" >> $RESULTS
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x"
    echo "$x : FAIL" >> $RESULTS
  fi
#  rm -f output* res comp*
  cd ..
done
