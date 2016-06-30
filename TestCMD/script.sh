#!/bin/sh
NATRON_BIN="$1"
CWD=`pwd`
NAME=TestCMD
IMAGES_FILE_EXT=jpg

if [ "$NATRON_BIN" = "" ]; then
  echo "Can't find NatronRenderer"
  exit 1
fi
if [ "$COMPARE_BIN" = "" ]; then
  COMPARE_BIN=compare
fi

rm -f "$CWD"/{output*,comp*,res*}

echo "===================$NAME========================"
"$NATRON_BIN" -i ReadOIIO1 "$CWD"/input1.png -w WriteOIIO1 "$CWD"/output1.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp #> /dev/null 2>&1
"$NATRON_BIN" -i ReadOIIO2 "$CWD"/input2.png -w WriteOIIO2 "$CWD"/output2.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp #> /dev/null 2>&1 

for i in $(seq 1 2); do
  "$COMPARE_BIN" -metric AE reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT &> res$i
  PIXELS_COUNT="$(cat res$i)"
  if [ "$PIXELS_COUNT" != "0" ]; then
    echo "WARNING: $PIXELS_COUNT pixel(s) different for test $i in TestCMD"
  else
    echo "Test $i passed for TestCMD"
  fi
done
#rm -f "$CWD"/{output*,comp*,res*}
exit

"$NATRON_BIN" -c "qualityValue=10" -c "app.saveProject(\"$CWD/output.ntp\")" -w DefaultWrite1 -w DefaultWrite2 -o1 "$CWD"/output5.jpg 1-1 -o2 "$CWD"/output6.jpg 1-1 "$CWD"/script02.py #> /dev/null 2>&1

if [ ! -f "$CWD/output3.jpg" ] && [ ! -f "$CWD/output4.jpg" ] && [ ! -f "$CWD/output5.jpg" ] && [ ! -f "$CWD/output6.jpg" ] && [ ! -f "$CWD/output.ntp" ]; then
  echo "WARNING: TestCMD failed test 2"
else
  echo "TestCMD passed test 2"
fi
#rm -f "$CWD"/output*

