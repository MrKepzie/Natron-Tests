#!/bin/sh
export FONTCONFIG_PATH=/opt/Natron-CY2015/etc/fonts/fonts.conf 
export LD_LIBRARY_PATH=/opt/Natron-CY2015/gcc/lib64:/opt/Natron-CY2015/lib:/opt/Natron-CY2015/ffmpeg-gpl/lib
export PATH=/opt/Natron-CY2015/bin:$PATH

if [ ! -L /usr/OFX/Plugins ]; then
  ln -sf /opt/Natron-CY2015/Plugins /usr/OFX/Plugins
fi

COMPARE=`pwd`/compare.bin ./runTests.sh /opt/Natron-CY2015/bin/NatronRenderer
