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
NAME=TestWriteFFMpeg
uname="$(uname)"
IMAGES_FILE_EXT=jpg
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
for x in $FORMATS/*; do
  if [ ! -f "$x/format" ]; then
      continue
  fi
  cd "$x"
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $x"
  FORMAT="$(cat format)"
  rm -f output* res comp*
  env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} test.ntp #> /dev/null 2>&1
  if [ -f "output.$FORMAT" ]; then
    set -x
    $TIMEOUT -s KILL 1800 "$FFMPEG_BIN" -y -i "output.$FORMAT" "output%1d.$IMAGES_FILE_EXT" </dev/null >/dev/null 2>&1
    set +x
  fi
  if [ -f "last" ]; then
    LAST_FRAME="$(cat last)"
  fi
  TEST_FAIL=0
  TEST_PASS=0
  SEQ="seq $FIRST_FRAME $LAST_FRAME"
  if [ "$uname" = "Darwin" ]; then
    SEQ="jot - $FIRST_FRAME $LAST_FRAME"
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** END $x"
  for i in $($SEQ); do
      FAIL=0
      # idiff's "WARNING" gives a non-zero return status
      "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" $IDIFF_OPTS &> res || true
      if [ ! -f "output${i}.$IMAGES_FILE_EXT" ]; then
          echo "WARNING: render failed for frame $i in $x:"
	  TEST_FAIL=$((TEST_FAIL+1))
      elif [ ! -z "$(grep FAILURE res || true)" ]; then
          echo "WARNING: unit test failed for frame $i in $x:"
	  cat res
	  TEST_FAIL=$((TEST_FAIL+1))
      elif [ ! -z "$(grep WARNING res || true)" ]; then
          echo "WARNING: unit test warning for frame $i in $t:"
          cat res
	  TEST_PASS=$((TEST_PASS+1))
      else
          echo "PASSED: unit test passed for frame $i in $x:"
	  cat res
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
