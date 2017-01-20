#!/bin/sh
NATRON_BIN="$1"
FFMPEG_BIN="$2"
COMPARE_BIN="$3"
CWD=`pwd`
NAME=TestWritePNG
IMAGES_FILE_EXT=png
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$NATRON_BIN" = "" ] && [ "$FFMPEG_BIN" = "" ] && [ "$COMPARE_BIN" = "" ]; then
  echo "Can't find required apps"
  exit 1
fi

echo "===================$NAME========================"
"$NATRON_BIN" test.ntp #> /dev/null 2>&1
for i in a8 a16 g8 g16 ga8 ga16 rgb8 rgb16 rgba8 rgba16; do
    "$COMPARE_BIN" -metric AE reference${i}.${IMAGES_FILE_EXT} output${i}.${IMAGES_FILE_EXT} comp$i.${IMAGES_FILE_EXT} &> res
    PIXELS_COUNT="$(cat res)"
    if [ "$PIXELS_COUNT" != "0" ]; then
	echo "WARNING: $PIXELS_COUNT pixel(s) different for $i"
	TEST_FAIL=$((TEST_FAIL+1))
    else
	echo "$i passed"
	TEST_PASS=$((TEST_PASS+1))
    fi
done
if [ "$TEST_FAIL" = 0 ] && [ "$TEST_PASS" = "$LAST_FRAME" ]; then
    echo "$x : PASS" >> $RESULTS
else
    echo "$x : FAIL" >> $RESULTS
fi
#  rm -f output* res comp*
