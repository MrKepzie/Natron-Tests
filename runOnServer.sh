#!/bin/sh
PID=$$

# make kill bot
KILLSCRIPT="/tmp/killbot$$.sh"
cat << 'EOF' > "$KILLSCRIPT"
#!/bin/sh
PARENT=$1
sleep 45m
if [ "$PARENT" = "" ]; then
  exit 1
fi
PIDS=`ps aux|awk '{print $2}'|grep $PARENT`
if [ "$PIDS" = "$PARENT" ]; then
  kill -9 $PARENT
fi
EOF
chmod +x $KILLSCRIPT

export FONTCONFIG_PATH=/opt/Natron-CY2015/etc/fonts/fonts.conf 
export LD_LIBRARY_PATH=/opt/Natron-CY2015/gcc/lib64:/opt/Natron-CY2015/lib:/opt/Natron-CY2015/ffmpeg-gpl/lib:/opt/Natron-CY2015/magick7/lib
export PATH=/opt/Natron-CY2015/bin:$PATH
mkdir -p ~/.cache/INRIA/Natron/{ViewerCache,DiskCache} /usr/OFX

if [ ! -L /usr/OFX/Plugins ]; then
  ln -sf /opt/Natron-CY2015/OFX/Plugins /usr/OFX/Plugins
fi
if [ ! -L /opt/OFX/Natron-CY2015/Plugins/PyPlugs ]; then
  ln -sf /opt/Natron-CY2015/PyPlugs /opt/Natron-CY2015/OFX/Plugins/PyPlugs
fi

"$KILLSCRIPT" $PID &
KILLBOT=$!

#date
FFMPEG="/opt/Natron-CY2015/ffmpeg-gpl/bin/ffmpeg" COMPARE=`pwd`/compare.bin ./runTests.sh /home/olear/Work/build-Project-VFX-Debug/Renderer/NatronRenderer
#date
echo "DONE"

kill -9 $KILLBOT
rm -f $KILLSCRIPT || true
