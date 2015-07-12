#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# Created by Alexandre GAUTHIER-FOICHAT
# contact: immarespond at gmail dot com


if [ $# != 1 ]; then
	echo "Usage: $0 <absolute path to NatronRenderer binary>"
	exit 1
fi


RENDERER="$1"
TMP_SCRIPT="tmpScript.py"
WRITER_PLUGINID="fr.inria.openfx.WriteOIIO"
WRITER_NODE_NAME="__script_write_node__"
IMAGES_FILE_EXT="exr"

TEST_DIRS="TestFrameBlend TestRetimeTransform TestTimeBlur"

for t in $TEST_DIRS; do
	cd $t
	CONFFILE=$(find conf)
	if [[ -z $CONFFILE ]]; then
		echo "$t does not contain a configuration file, please see the README."
		exit 1	
	fi
	
	CWD=${PWD}
	CONF="$(cat conf)"
	NATRONPROJ=$(echo $CONF | awk '{print $1;}')
	NATRONPROJ=$CWD/$NATRONPROJ
	FIRST_FRAME=$(echo $CONF | awk '{print $2;}')
	LAST_FRAME=$(echo $CONF | awk '{print $3;}')
	OUTPUTNODE=$(echo $CONF | awk '{print $4;}')
	touch $TMP_SCRIPT
	echo "import NatronEngine" > $TMP_SCRIPT
	
#Create the write node
	echo "writer = app.createNode(\"$WRITER_PLUGINID\")" >> $TMP_SCRIPT	
	echo "inputNode = app.$OUTPUTNODE" >> $TMP_SCRIPT
	echo "writer.connectInput(0, inputNode)" >> $TMP_SCRIPT
	
	echo "writer.filename.set(\"[Project]/output#.exr\")" >> $TMP_SCRIPT


#Set manual frame range
	echo "writer.frameRange.set(2)" >> $TMP_SCRIPT
	echo "writer.firstFrame.set($FIRST_FRAME)" >> $TMP_SCRIPT
	echo "writer.lastFrame.set($LAST_FRAME)" >> $TMP_SCRIPT
	
#Set compression to none
	echo "writer.compression.set(1)" >> $TMP_SCRIPT
	
	echo "writer.setScriptName(\"$WRITER_NODE_NAME\")" >> $TMP_SCRIPT
	
#Start rendering
	echo "Starting NatronRenderer for $t..."
	$RENDERER -w $WRITER_NODE_NAME $NATRONPROJ || exit 1
	
#compare with ImageMagick
	for i in $(seq $FIRST_FRAME $LAST_FRAME); do
		PIXELS_COUNT=compare -metric AE reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT
		if [ "$PIXELS_COUNT" != "0" ]; then
			echo "WARNING: $PIXELS_COUNT pixel(s) different for frame $i in $t"
		fi
	done
	
	rm $TMP_SCRIPT
	
	cd ..
done