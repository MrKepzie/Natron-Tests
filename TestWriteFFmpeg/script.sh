#!/bin/sh
NATRON_BIN="$1"
FFMPEG_BIN="$2"
COMPARE_BIN="$3"
CWD=`pwd`
NAME=TestWriteFFMpeg
IMAGES_FILE_EXT=jpg
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$PKGOS" = "OSX" ]; then
    # timeout is available in GNU coreutils:
    # sudo port install coreutils
    # or
    # brew install coreutils
    TIMEOUT="gtimeout"
else
    TIMEOUT="timeout"
fi

if [ "$NATRON_BIN" = "" ] && [ "$FFMPEG_BIN" = "" ] && [ "$COMPARE_BIN" = "" ]; then
  echo "Can't find required apps"
  exit 1
fi

echo "===================$NAME========================"
for x in $FORMATS/*; do
  cd $x
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $x"
  FORMAT=`cat format`
  rm -f output* res comp*
  $TIMEOUT 1800 "$NATRON_BIN" test.ntp #> /dev/null 2>&1
  if [ -f "output.$FORMAT" ]; then
    set -x
    $TIMEOUT 1800 "$FFMPEG_BIN" -i "output.$FORMAT" "output%1d.$IMAGES_FILE_EXT" #> /dev/null 2>&1
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
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** END $t"
  for i in $($SEQ); do
    "$COMPARE_BIN" -metric AE reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT &> res
    PIXELS_COUNT="$(cat res)"
    if [ "$PIXELS_COUNT" != "0" ]; then
      echo "WARNING: $PIXELS_COUNT pixel(s) different for frame $i in $x"
      TEST_FAIL=$((TEST_FAIL+1))
    else
      echo "Frame $i passed for $x"
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
