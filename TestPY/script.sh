#!/bin/sh
NATRON_BIN="$1"
CWD=`pwd`
NAME=TestPY

if [ "$NATRON_BIN" = "" ]; then
  echo "Can't find NatronRenderer"
  exit 1
fi

rm -f "$CWD"/*output*

echo "===================$NAME========================"
for i in "$CWD"/test___*.py; do
  SCRIPT=`echo $i | sed 's/___/ /g;s/.py//g' | awk '{print $2}'`
  if [ "$SCRIPT" != "" ]; then
    "$NATRON_BIN" "$CWD"/test___$SCRIPT.py > /dev/null 2>&1
    DIFF1=`diff $CWD/test___$SCRIPT-reference.txt $CWD/test___$SCRIPT-output.txt`
    if [ ! -f "$CWD/test___$SCRIPT-output.txt" ]; then
      DIFF1="fail"
    fi
    if [ "$DIFF1" != "" ]; then
      echo "WARNING: test $SCRIPT failed in TestPY"
    else
      echo "TestPY passed test $SCRIPT"
    fi
fi
done

rm -f "$CWD"/*output*

