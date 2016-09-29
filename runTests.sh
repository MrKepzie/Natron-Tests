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

if [ $COMPARE"" != "" ]; then
  COMPARE_BIN="$COMPARE"
else
  COMPARE_BIN=compare
fi

if [ "$FFMPEG" != "" ]; then
  FFMPEG_BIN="$FFMPEG"
else
  FFMPEG_BIN=ffmpeg
fi

CUSTOM_DIRS="
TestCMD
TestPY
TestFFmpeg
"

TEST_DIRS="
Spaceship
BayMax
TestFill
TestImageTIF
TestMergeMinus
TestReadAVI_m1v
TestRGB_HSI
TestImageXCF
TestMergeMultiply
TestReadAVI_m2v1
TestRGB_HSL
TestGamma
TestImageXPM
TestMergeOut
TestReadAVI_mp4v
TestRGB_HSV
TestGMICExpr
TestImplode
TestMergeOver
TestReadAVI_png
TestRGB_LAB
TestGodRays
TestMergeOverlay
TestReadAVI_svq1
TestAdd
TestGrade
TestLaplacian
TestMergePinlight
TestReadAVI_v210
TestRGB_YCbCr
TestAngleBlur
TestGuided
TestLensDistortion
TestMergePlus
TestReadMOV_ap4h
TestRGB_YUV
TestArc
TestHistEQ
TestMedian
TestMergeReflect
TestReadMOV_apch
TestRoll
TestBilateral
TestHSVTool
TestMergeAtop
TestMergeSaturation
TestReadMOV_apcn
TestRollingGuidance
TestImageBMP
TestMergeAverage
TestMergeScreen
TestReadMOV_apco
TestBloom
TestImageCR2
TestMergeColor
TestMergeSoftLight
TestReadMOV_apcs
TestBlur
TestImageDPX
TestMergeColorBurn
TestMergeStencil
TestReadMOV_avc1
TestSharpenInvDiff
TestCharcoal
TestImageEXR
TestMergeColorDodge
TestMergeUnder
TestSharpenShock
TestCheckerBoard
TestImageGIF
TestMergeConjointOver
TestMergeXOR
TestReadMOV_flv1
TestShuffle
TestClamp
TestImageHDR
TestMergeCopy
TestMirror
TestReadMOV_jpg
TestSmooth
TestClipTest
TestImageJP2
TestMergeDifference
TestModulate
TestReadMOV_m1v
TestSwirl
TestImageJPG
TestMergeDisjointOver
TestMultiPlaneEXR
TestReadMOV_m2v1
TestSwitch
TestColorLookup
TestImageKRA
TestMergeDivide
TestMultiPlaneORA
TestReadMOV_mp4v
TestColorMatrix
TestMergeExclusion
TestMultiPlanePSD
TestReadMOV_png
TestTexture
TestColorSuppress
TestImageORA
TestMergeFreeze
TestMultiPlaneXCF
TestReadMOV_rle
TestImagePBM
TestMergeFrom
TestMultiply
TestReadMOV_svq1
TestCopyRectangle
TestImagePCX
TestMergeGeometric
TestOCIOCDLTransform
TestReadMOV_v210
TestCornerPin
TestImagePFM
TestMergeGrainExtract
TestOCIOColorSpace
TestReadMP4_avc1
TestTimeDissolve
TestCrop
TestImagePGM
TestMergeGrainMerge
TestOCIODisplay
TestReadMP4_jpg
TestDenoise
TestImagePNG
TestMergeHardLight
TestOCIOFileTransform
TestReadMP4_m1v
TestVectorToColor
TestDilate
TestImagePNM
TestMergeHue
TestOCIOLogConvert
TestReadMP4_m2v1
TestDirBlur
TestImagePPM
TestMergeHypot
TestOCIOLookTransform
TestReadMP4_mp4v
TestWave
TestDissolve
TestImagePSB
TestMergeIn
TestOilpaint
TestReadMP4_png
TestZMask
TestDropShadow
TestImagePSD
TestMergeLuminosity
TestPolar
TestReadMPEG1
TestEdges
TestImageRGB
TestMergeMask
TestPosition
TestReadMXF
TestEqualize
TestImageRGBA
TestMergeMatte
TestReadAVI_avc1
TestReflection
TestErode
TestImageSVG
TestMergeMax
TestReadAVI_flv1
TestErodeSmooth
TestImageTGA
TestMergeMin
TestReadAVI_jpg
TestRetimeTransform
TestReformat
TestReformat1
TestReformat2
TestReformat3
TestReformat4
TestReformat5
TestReformat6
TestReformat7
TestReformat8
TestReformat9
TestReformat10
TestGlow
"
# TestBilateralGuided

ROOTDIR=`pwd`


if [ ! -d "$ROOTDIR/Spaceship/Sources" ]; then
  wget http://downloads.natron.fr/Third_Party_Sources/SpaceshipSources.tar.gz
  tar xvf "$ROOTDIR/SpaceshipSources.tar.gz" -C "$ROOTDIR/Spaceship/"
fi
if [ ! -d "$ROOTDIR/BayMax/Robot" ]; then
  wget http://downloads.natron.fr/Third_Party_Sources/Robot.tar.gz 
  tar xvf "$ROOTDIR/Robot.tar.gz" -C "$ROOTDIR/BayMax/"
fi

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

export RESULTS="$ROOTDIR"/result.txt
echo > $RESULTS

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
    echo "if not writer:" >> $TMP_SCRIPT
    echo "    raise ValueError(\"Could not create a writer with the following plug-in ID: $WRITER_PLUGINID\")" >> $TMP_SCRIPT
    echo "    sys.exit(1)" >> $TMP_SCRIPT
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

cat $TMP_SCRIPT	

#Start rendering, silent stdout
#Note that we append the current directory to the NATRON_PLUGIN_PATH so it finds any PyPlug or script in there
	env NATRON_PLUGIN_PATH=$CWD "$RENDERER" -w $WRITER_NODE_NAME -l $CWD/$TMP_SCRIPT $NATRONPROJ || FAIL=1
    if [ "$FAIL" = "1" ]; then
        rm ofxTestLog.txt &> /dev/null
        rm $TMP_SCRIPT
        exit 1
    fi

    rm ofxTestLog.txt &> /dev/null

#compare with ImageMagick
	for i in $(seq $FIRST_FRAME $LAST_FRAME); do
		$COMPARE_BIN -metric AE -fuzz 20% reference$i.$IMAGES_FILE_EXT output$i.$IMAGES_FILE_EXT comp$i.$IMAGES_FILE_EXT &> res
        PIXELS_COUNT="$(cat res)"
        rm res

		if [ "$PIXELS_COUNT" != "0" ]; then
			echo "WARNING: $PIXELS_COUNT pixel(s) different for frame $i in $t"
            FAIL="1"
		fi
        rm output$i.$IMAGES_FILE_EXT > /dev/null
        rm comp$i.$IMAGES_FILE_EXT > /dev/null
	done
    if [ "$FAIL" != "1" ]; then
        echo "Test $t passed."
        echo "$t : PASS" >> $RESULTS
    else
        echo "Test $t failed."
        echo "$t : FAIL" >> $RESULTS
    fi
    FAIL="0"
	
    rm $TMP_SCRIPT || exit 1
    rm -rf __pycache__ &> /dev/null

	cd ..
done

for x in $CUSTOM_DIRS; do
  cd $x
    sh script.sh "$RENDERER" "$FFMPEG_BIN" "$COMPARE_BIN"
  cd ..
done

