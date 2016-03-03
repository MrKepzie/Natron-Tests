#!/bin/sh
NATRON_BIN="$1"
FFMPEG_BIN="$2"
CWD=`pwd`
NAME=TestFFMpeg
IMAGES_FILE_EXT=jpg
FIRST_FRAME=1
LAST_FRAME=9
FORMATS="$CWD/formats"

if [ "$NATRON_BIN" = "" ] && [ "$FFMPEG_BIN" = "" ]; then
  echo "Can't find NatronRenderer and/or ffmpeg"
  exit 1
fi

if [ "$COMPARE_BIN" = "" ]; then
  COMPARE_BIN=compare
fi

echo "===================$NAME========================"
for x in $FORMATS/*; do
  cd $x
  rm -f output* res comp*
  "$NATRON_BIN" test.ntp #> /dev/null 2>&1
  if [ -f "output.mov" ]; then
    "$FFMPEG_BIN" -i output.mov output%1d.$IMAGES_FILE_EXT > /dev/null 2>&1
  fi
  for i in $(seq $FIRST_FRAME $LAST_FRAME); do
    "$COMPARE_BIN" -metric AE reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT &> res
    PIXELS_COUNT="$(cat res)"
    if [ "$PIXELS_COUNT" != "0" ]; then
      echo "WARNING: $PIXELS_COUNT pixel(s) different for frame $i in $x"
    else
      echo "Frame $i passed for $x"
    fi
  done
  rm -f output* res comp*
  cd ..
done
