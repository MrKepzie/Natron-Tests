#!/bin/sh
NATRON_BIN="$1"
FFMPEG_BIN="$2"
IDIFF_BIN="$3"
CWD=`pwd`
NAME=TestWritePNG
IMAGES_FILE_EXT=png
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$NATRON_BIN" = "" ] && [ "$FFMPEG_BIN" = "" ] && [ "$IDIFF_BIN" = "" ]; then
  echo "Can't find required apps"
  exit 1
fi

echo "===================$NAME========================"
"$NATRON_BIN" test.ntp #> /dev/null 2>&1
for i in a8 a16 g8 g16 ga8 ga16 rgb8 rgb16 rgba8 rgba16; do
    FAIL=0
    "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" -fail 0.01 -abs -scale 10 &> res
    if [ $? != 0 ]; then
	FAIL=1
    fi
    resstatus=$(cat res | grep FAILURE)
    ok=$? # output status of previous command

    #        rm res
    
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
