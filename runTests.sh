#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# Created by Alexandre GAUTHIER-FOICHAT
# contact: immarespond at gmail dot com

#WARNING: Make sure that the NatronRenderer binary has access to the OpenColorIO-Configs otherwise images written may have
#a different color-space of their reference.
#The warning "Attempt to read an OpenColorIO configuration but the configuration directory..." will be printed
#when the OpenColorIO-Configs could not be found.

TEST_DIRS="TestFrameBlend TestRetimeTransform TestTimeBlur TestTilePyPlug"

if [ $# != 1 ]; then
	echo "Usage: $0 <absolute path to NatronRenderer binary>"
	echo "Or $0 clean to remove any output images generated."
	exit 1
fi


RENDERER="$1"
if [ "$1" = "clean" ]; then
	for t in $TEST_DIRS; do
		cd $t
		rm *output*.* &> /dev/null
		rm *comp*.*  &> /dev/null
		rm *.autosave  &> /dev/null
		rm *.lock  &> /dev/null
		cd ..
	done
	exit 0
fi

TMP_SCRIPT="tmpScript.py"
WRITER_PLUGINID="fr.inria.openfx.WriteOIIO"
WRITER_NODE_NAME="__script_write_node__"
DEFAULT_QUALITY="10"


for t in $TEST_DIRS; do
	cd $t

    echo "===================$t========================"
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
    IMAGES_FILE_EXT=$(echo $CONF | awk '{print $5;}')
    QUALITY=$(echo $CONF | awk '{print $6;}')
    if [[ -z $QUALITY ]]; then
        QUALITY=$DEFAULT_QUALITY
    fi
	touch $TMP_SCRIPT
    echo "import sys" > $TMP_SCRIPT
	echo "import NatronEngine" > $TMP_SCRIPT

#Create the write node
	echo "writer = app.createNode(\"$WRITER_PLUGINID\")" >> $TMP_SCRIPT
    echo "if not writer.setScriptName(\"$WRITER_NODE_NAME\"):" >> $TMP_SCRIPT
    echo "    raise NameError(\"Could not set writer script-name to $WRITER_NODE_NAME, aborting\")" >> $TMP_SCRIPT
    echo "    sys.exit(1)" >> $TMP_SCRIPT
    echo "#We must do this to copy the parameters attributes of the node to \"writer\"" >> $TMP_SCRIPT
    echo "writer = app.$WRITER_NODE_NAME" >> $TMP_SCRIPT
	echo "inputNode = app.$OUTPUTNODE" >> $TMP_SCRIPT
	echo "writer.connectInput(0, inputNode)" >> $TMP_SCRIPT
	
#Set the output filename
	echo "writer.filename.set(\"[Project]/output#.$IMAGES_FILE_EXT\")" >> $TMP_SCRIPT

#Set manual frame range
	echo "writer.frameRange.set(2)" >> $TMP_SCRIPT
	echo "writer.firstFrame.set($FIRST_FRAME)" >> $TMP_SCRIPT
	echo "writer.lastFrame.set($LAST_FRAME)" >> $TMP_SCRIPT
	
#Set compression to none
	echo "writer.quality.set($QUALITY)" >> $TMP_SCRIPT
	

#Start rendering, silent stdout
#Note that we append the current directory to the NATRON_PLUGIN_PATH so it finds any PyPlug or script in there
	FAIL=$(env=NATRON_PLUGIN_PATH=$CWD $RENDERER -w $WRITER_NODE_NAME -l $CWD/$TMP_SCRIPT $NATRONPROJ > /dev/null)
    if [ "$FAIL" = "1" ]; then
        rm ofxTestLog.txt &> /dev/null
        rm $TMP_SCRIPT
        exit 1
    fi

    rm ofxTestLog.txt &> /dev/null

#compare with ImageMagick
	for i in $(seq $FIRST_FRAME $LAST_FRAME); do
		compare -metric AE reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT &> res
        PIXELS_COUNT="$(cat res)"
        rm res

		if [ "$PIXELS_COUNT" != "0" ]; then
			echo "WARNING: $PIXELS_COUNT pixel(s) different for frame $i in $t"
            FAIL="1"
		fi
#rm output$i.$IMAGES_FILE_EXT > /dev/null
        rm comp$i.$IMAGES_FILE_EXT > /dev/null
	done
    if [ "$FAIL" != "1" ]; then
        echo "Test $t passed."
    fi
    FAIL="0"
	
    rm $TMP_SCRIPT || exit 1
    rm -rf __pycache__ &> /dev/null

	cd ..
done