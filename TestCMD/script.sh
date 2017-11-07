#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -x # Print commands and their arguments as they are executed.

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
NAME=TestCMD
uname="$(uname)"
IMAGES_FILE_EXT=jpg

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

rm -f "$CWD"/{output*,comp*,res*}

echo "===================$NAME========================"
FAIL=0
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} -i ReadOIIO1 "$CWD"/input1.png -w WriteOIIO1 "$CWD"/output1.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp > /dev/null 2>&1 || FAIL=1
if [ $FAIL = 1 ]; then
    echo "$x/WriteOIIO1 : FAIL" >> $RESULTS
else
    echo "$x/WriteOIIO1 : PASS" >> $RESULTS
fi
FAIL=0
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} -i ReadOIIO2 "$CWD"/input2.png -w WriteOIIO2 "$CWD"/output2.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp > /dev/null 2>&1 || FAIL=1
if [ $FAIL = 1 ]; then
    echo "$x/WriteOIIO2 : FAIL" >> $RESULTS
else
    echo "$x/WriteOIIO2 : PASS" >> $RESULTS
fi


for i in 1 2; do
    # idiff's "WARNING" gives a non-zero return status
    "$IDIFF_BIN" "reference$i.$IMAGES_FILE_EXT" "output$i.$IMAGES_FILE_EXT" -o "comp$i.$IMAGES_FILE_EXT" $IDIFF_OPTS &> res || true
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
#rm -f "$CWD"/{output*,comp*,res*}
exit

i=3
x="$NAME/$i"

FAIL=0
env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 1800 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} -c "qualityValue=10" -c "app.saveProject(\"$CWD/output.ntp\")" -w DefaultWrite1 -w DefaultWrite2 -o1 "$CWD"/output5.jpg 1-1 -o2 "$CWD"/output6.jpg 1-1 "$CWD"/script02.py > /dev/null 2>&1 || FAIL=1

if [ $FAIL = 0 ] && [ ! -f "$CWD/output3.jpg" ] && [ ! -f "$CWD/output4.jpg" ] && [ ! -f "$CWD/output5.jpg" ] && [ ! -f "$CWD/output6.jpg" ] && [ ! -f "$CWD/output.ntp" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $x"
      echo "$x : PASS" >> $RESULTS
else
      echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $x"
      echo "$x : FAIL" >> $RESULTS
fi
#rm -f "$CWD"/output*

