#!/bin/sh
FONTCONFIG_PATH=/opt/Natron-CY2015/etc/fonts/fonts.conf LD_LIBRARY_PATH=/opt/Natron-CY2015/gcc/lib64:$PATH COMPARE=$(pwd)/compare.bin ./runTests.sh /opt/Natron-CY2015/bin/NatronRenderer
