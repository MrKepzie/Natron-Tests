#!/bin/sh
NATRON_BIN="$1"
CWD=`pwd`
NAME=TestCMD

if [ "$NATRON_BIN" = "" ]; then
  echo "Can't find NatronRenderer"
  exit 1
fi

rm -f "$CWD"/output*

echo "===================$NAME========================"
"$NATRON_BIN" -i ReadOIIO1 "$CWD"/input1.png -w WriteOIIO1 "$CWD"/output1.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp > /dev/null 2>&1
"$NATRON_BIN" -i ReadOIIO2 "$CWD"/input2.png -w WriteOIIO2 "$CWD"/output2.jpg 1-1 -s -l "$CWD"/script01.py "$CWD"/test.ntp > /dev/null 2>&1 

if [ ! -f "$CWD/output1.jpg" ] && [ ! -f "$CWD/output1-stats.txt" ] && [ ! -f "$CWD/output2.jpg" ] && [ ! -f "$CWD/output2-stats.txt" ]; then
  echo "WARNING: TestCMD failed test 1"
else
  echo "TestCMD passed test 1"
fi
rm -f "$CWD"/output*

"$NATRON_BIN" -c "app.saveProject(\"$CWD/output.ntp\")" -w DefaultWrite1 -w DefaultWrite2 -o1 "$CWD"/output5.jpg 1-1 -o2 "$CWD"/output6.jpg 1-1 "$CWD"/script02.py > /dev/null 2>&1

if [ ! -f "$CWD/output3.jpg" ] && [ ! -f "$CWD/output4.jpg" ] && [ ! -f "$CWD/output5.jpg" ] && [ ! -f "$CWD/output6.jpg" ] && [ ! -f "$CWD/output.ntp" ]; then
  echo "WARNING: TestCMD failed test 2"
else
  echo "TestCMD passed test 2"
fi
rm -f "$CWD"/output*

