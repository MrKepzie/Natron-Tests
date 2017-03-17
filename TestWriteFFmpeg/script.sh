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

if [ "$(uname -s)" = "Darwin" ]; then
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
  echo "$(date '+%Y-%m-%d %H:%M:%S') *** END $t"
  for i in $($SEQ); do
      FAIL=0
      "$COMPARE_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" -scale 10 &> res
      if [ $? != 0 ]; then
	  FAIL=1
      fi
      resstatus=$(cat res | grep FAILURE)
      
      #        rm res
      
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
