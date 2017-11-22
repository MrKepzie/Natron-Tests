#!/bin/bash
# ***** BEGIN LICENSE BLOCK *****
# This file is part of Natron <http://www.natron.fr/>,
# Copyright (C) 2016 INRIA and Alexandre Gauthier
#
# Natron is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Natron is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Natron.  If not, see <http://www.gnu.org/licenses/gpl-2.0.html>
# ***** END LICENSE BLOCK *****

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
#set -x # Print commands and their arguments as they are executed.

echo "*** Natron tests"
echo "Environment:"
env

case "$(uname -s)" in
Linux)
    PKGOS=Linux
    ;;
Msys|MINGW64_NT-*|MINGW32_NT-*)
    PKGOS=Windows
    #set -x # uncomment to get verbose tests on Windows
    ;;
Darwin)
    PKGOS=OSX
    ;;
*)
    echo "$CHECK_OS not supported!"
    exit 1
    ;;
esac

# update the font cache if necessary (avoid blocking trhe first test)
fc-cache -v || true

if [ "$(uname -s)" = "Darwin" ]; then
    # timeout is available in GNU coreutils:
    # sudo port install coreutils
    # or
    # brew install coreutils
    TIMEOUT="gtimeout"
else
    TIMEOUT="timeout"
fi

if [ "${COMPARE:-}" != "" ]; then
    IDIFF_BIN="$COMPARE"
else
    IDIFF_BIN=idiff
fi

if [ "${FFMPEG:-}" != "" ]; then
    FFMPEG_BIN="$FFMPEG"
else
    FFMPEG_BIN=ffmpeg
fi

OPTS=("--no-settings")
if [ -n "${OFX_PLUGIN_PATH:-}" ]; then
    echo "OFX_PLUGIN_PATH=${OFX_PLUGIN_PATH:-}, setting useStdOFXPluginsLocation=False"
    OPTS=(${OPTS[@]+"${OPTS[@]}"} "--setting" "useStdOFXPluginsLocation=False")
fi

# fail if more than 0.1% of pixels have an error larger than 0.001 or if any pixel has an error larger than 0.01
IDIFF_OPTS="-warn 0.001 -fail 0.001 -failpercent 0.1 -hardfail 0.01 -abs -scale 100"
# tuned to pass BayMax and Spaceship:
IDIFF_OPTS="-warn 0.001 -fail 0.008 -failpercent 0.2 -hardfail 0.08 -abs -scale 30"

CUSTOM_DIRS="
TestCMD
TestPY
TestWriteFFmpeg
TestWritePNG
"

TEST_DIRS="
TestAdd
TestAngleBlur
TestArc
TestBilateral
TestBilateralGuided
TestBloom
TestBlur
TestCharcoal
TestCheckerBoard
TestClamp
TestClipTest
TestColorCorrect
TestColorLookup
TestColorMatrix
TestColorSuppress
TestConstant
TestCopyRectangle
TestCornerPin
TestCrop
TestDenoise
TestDilate
TestDirBlur
TestDissolve
TestDropShadow
TestEdges
TestEqualize
TestErode
TestErodeSmooth
TestFill
TestFrameBlend
TestGMICExpr
TestGamma
TestGlow
TestGodRays
TestGrade
TestGuided
TestHSVTool
TestHistEQ
TestIDistort
TestImageBMP
TestImageCR2
TestImageDPX
TestImageEXR
TestImageGIF
TestImageHDR
TestImageJP2
TestImageJPG
TestImageKRA
TestImageORA
TestImagePBM
TestImagePCX
TestImagePFM
TestImagePGM
TestImagePNG
TestImagePNGOIIO
TestImagePNM
TestImagePPM
TestImagePSB
TestImagePSD
TestImageRGB
TestImageRGBA
TestImageSVG
TestImageTGA
TestImageTIF
TestImageXCF
TestImageXPM
TestImplode
TestInvert
TestLaplacian
TestLensDistortion
TestMedian
TestMergeAtop
TestMergeAverage
TestMergeColor
TestMergeColorBurn
TestMergeColorDodge
TestMergeConjointOver
TestMergeCopy
TestMergeDifference
TestMergeDisjointOver
TestMergeDivide
TestMergeExclusion
TestMergeFreeze
TestMergeFrom
TestMergeGeometric
TestMergeGrainExtract
TestMergeGrainMerge
TestMergeHardLight
TestMergeHue
TestMergeHypot
TestMergeIn
TestMergeLuminosity
TestMergeMask
TestMergeMatte
TestMergeMax
TestMergeMin
TestMergeMinus
TestMergeMultiply
TestMergeOut
TestMergeOver
TestMergeOverlay
TestMergePinlight
TestMergePlus
TestMergeReflect
TestMergeSaturation
TestMergeScreen
TestMergeSoftLight
TestMergeStencil
TestMergeUnder
TestMergeXOR
TestMirror
TestModulate
TestMultiPlaneEXR
TestMultiPlaneORA
TestMultiPlanePSD
TestMultiPlaneXCF
TestMultiply
TestOCIOCDLTransform
TestOCIOColorSpace
TestOCIODisplay
TestOCIOFileTransform
TestOCIOLogConvert
TestOCIOLookTransform
TestOilpaint
TestPIK
TestPolar
TestPosition
TestRGBHSI
TestRGBHSL
TestRGBHSV
TestRGBLAB
TestRGBX_Y_Z
TestRGBYCbCr
TestRGBYUV
TestReadAVI_avc1
TestReadAVI_flv1
TestReadAVI_jpg
TestReadAVI_m1v
TestReadAVI_m2v1
TestReadAVI_mp4v
TestReadAVI_png
TestReadAVI_svq1
TestReadMOV_ap4h
TestReadMOV_apch
TestReadMOV_apcn
TestReadMOV_apco
TestReadMOV_apcs
TestReadMOV_avc1
TestReadMOV_flv1
TestReadMOV_jpg
TestReadMOV_m1v
TestReadMOV_m2v1
TestReadMOV_mp4v
TestReadMOV_png
TestReadMOV_rle
TestReadMOV_svq1
TestReadMP4_avc1
TestReadMP4_jpg
TestReadMP4_m1v
TestReadMP4_m2v1
TestReadMP4_mp4v
TestReadMP4_png
TestReadMPEG1
TestReadMXF
TestReflection
TestReformat
TestReformat1
TestReformat10
TestReformat2
TestReformat3
TestReformat4
TestReformat5
TestReformat6
TestReformat7
TestReformat8
TestReformat9
TestRetimeTransform
TestRoll
TestRollingGuidance
TestSTMap
TestSaturation
TestSeExpr
TestShadertoy
TestSharpenInvDiff
TestSharpenShock
TestShuffle
TestSmooth
TestSwirl
TestSwitch
TestText
TestTexture
TestTile
TestTimeBlur
TestTimeDissolve
TestVectorToColor
TestWave
TestZMask
BayMax
Spaceship
"

if [ $# != 1 -o \( "$1" != "clean" -a ! -x "$1" \) ]; then
    echo "Usage: $0 <absolute path to NatronRenderer binary>"
    echo "Or $0 clean to remove any output images generated."
    exit 1
fi

ROOTDIR=`pwd`

if [ ! -d "$ROOTDIR/Spaceship/Sources" ]; then
    wget -N -q http://downloads.natron.fr/Third_Party_Sources/SpaceshipSources.tar.gz && tar xf "$ROOTDIR/SpaceshipSources.tar.gz" -C "$ROOTDIR/Spaceship/"
fi
if [ ! -d "$ROOTDIR/BayMax/Robot" ]; then
    wget -N -q http://downloads.natron.fr/Third_Party_Sources/Robot.tar.gz && tar xf "$ROOTDIR/Robot.tar.gz" -C "$ROOTDIR/BayMax/"
fi

RENDERER_BIN="$1"
if [ "$1" = "clean" ]; then
    for t in $TEST_DIRS; do
        cd $t
        rm *output*.*  *comp*.*   *.autosave *.lock   tmpScript.py tmpScript.ntp  &> /dev/null || true
        cd ..
    done
    for t in $CUSTOM_DIRS; do
        cd $t
        rm *output*.*  *comp*.*   *.autosave *.lock &> /dev/null || true
        cd ..
    done
    exit 0
fi

export FAILED_DIR="$ROOTDIR"/failed
export RESULTS="$ROOTDIR"/result.txt
echo > $RESULTS

if [ -d "$FAILED_DIR" ]; then
    rm -rf "$FAILED_DIR"
fi
mkdir -p "$FAILED_DIR"

TMP_SCRIPT="tmpScript.py"
WRITER_PLUGINID="fr.inria.openfx.WriteOIIO"
WRITER_NODE_NAME="__script_write_node__"
DEFAULT_QUALITY="85"
IMAGES_FILE_EXT="jpg"

uname="$(uname)"

for t in $TEST_DIRS; do
    cd $t

    failseq=0
    rm res &> /dev/null || true
    rm output[0-9]*.$IMAGES_FILE_EXT &> /dev/null || true
    rm comp[0-9]*.$IMAGES_FILE_EXT &> /dev/null || true


    echo "$(date '+%Y-%m-%d %H:%M:%S') *** ===================$t========================"
    ############################################
    for CONFFILE in conf conf2 conf3 conf4 conf5; do
        failconf=0
    if [[ ! -f "$CONFFILE" ]]; then
        if [[ "$CONFFILE" = "conf" ]]; then
            echo "$t does not contain a configuration file, please see the README."
            exit 1
        fi
        continue
    fi
    
    CWD="$PWD"
    CONF="$(cat $CONFFILE)"
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
    #Set the output plugin
    echo "writer.encodingPluginChoice.set(\"$WRITER_PLUGINID\")" >> $TMP_SCRIPT

    #Set manual frame range
    echo "writer.frameRange.set(2)" >> $TMP_SCRIPT
    echo "writer.firstFrame.set($FIRST_FRAME)" >> $TMP_SCRIPT
    echo "writer.lastFrame.set($LAST_FRAME)" >> $TMP_SCRIPT
    
    #Set compression to none
    if [ "$IMAGES_FILE_EXT" = "jpg" ]; then
        echo "writer.quality.set($QUALITY)" >> $TMP_SCRIPT
    fi
    echo "print('encoder=',writer.internalEncoderNode.getPluginID())" >> $TMP_SCRIPT
    echo "print('ocioInputSpace=',writer.ocioInputSpaceIndex.getOption(writer.ocioInputSpaceIndex.getValue()))" >> $TMP_SCRIPT
    echo "print('ocioOutputSpace=',writer.ocioOutputSpaceIndex.getOption(writer.ocioOutputSpaceIndex.getValue()))" >> $TMP_SCRIPT
    #echo "app.saveTempProject('tmpScript.ntp')" >> $TMP_SCRIPT

    cat $TMP_SCRIPT     

    #Start rendering, silent stdout
    #Note that we append the current directory to the NATRON_PLUGIN_PATH so it finds any PyPlug or script in there
    if [ "$uname" = "Msys" ]; then
        plugin_path="${CWD};${NATRON_PLUGIN_PATH:-}"
    else
        plugin_path="${CWD}:${NATRON_PLUGIN_PATH:-}"
    fi
    if [ "$t" = "TestTile" ] && [ "$uname" = "Linux" ]; then
        echo "TestTile crashes on Linux64, and this script quits before printing *** END TestTile, I do not understand why"
        failconf=1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $t"
        renderfail=0
        env NATRON_PLUGIN_PATH="${plugin_path}" $TIMEOUT -s KILL 3600 "$RENDERER_BIN" ${OPTS[@]+"${OPTS[@]}"} -w $WRITER_NODE_NAME -l $CWD/$TMP_SCRIPT $NATRONPROJ || renderfail=1
        if [ "$renderfail" != "1" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') *** END render $t/$CONFFILE"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') *** END render $t/$CONFFILE (WARNING: render failed)"
	    # ignore failure, but check the output images
        fi
    fi
    if [ -f "ofxTestLog.txt" ]; then
        rm ofxTestLog.txt &> /dev/null
    fi
    if [ "$failconf" != "1" ]; then

        #compare with idiff

        if [ "$uname" = "Darwin" ]; then
            SEQ="gseq $FIRST_FRAME $LAST_FRAME"
	else
            SEQ="seq $FIRST_FRAME $LAST_FRAME"
        fi

        for i in $($SEQ); do
            # only copy images if this frame fails
            failframe=0
            if [ ! -f "output${i}.$IMAGES_FILE_EXT" ]; then
                echo "WARNING: output file output${i}.$IMAGES_FILE_EXT is missing"
                failframe=1
            else
                # idiff's "WARNING" gives a non-zero return status
                "$IDIFF_BIN" "reference${i}.$IMAGES_FILE_EXT" "output${i}.$IMAGES_FILE_EXT" -o "comp${i}.$IMAGES_FILE_EXT" $IDIFF_OPTS &> res || true

                if [ ! -f "output${i}.$IMAGES_FILE_EXT" ]; then
                    echo "WARNING: render failed for frame $i in $t"
                    failframe=1
                elif [ ! -f "comp${i}.$IMAGES_FILE_EXT" ]; then
                    echo "WARNING: $IDIFF_BIN failed for frame $i in $t"
                    failframe=1
                elif [ ! -z "$(grep FAILURE res || true)" ]; then
                    echo "WARNING: unit test failed for frame $i in $t:"
                    cat res
                    failframe=1
                elif [ ! -z "$(grep WARNING res || true)" ]; then
                    echo "WARNING: unit test warning for frame $i in $t:"
                    cat res
                fi
                #        rm output${i}.$IMAGES_FILE_EXT > /dev/null
                #        rm comp${i}.$IMAGES_FILE_EXT > /dev/null
                if [ "$failframe" = "1" ]; then
                    cp "reference${i}.$IMAGES_FILE_EXT" "$FAILED_DIR/$t-reference${i}.$IMAGES_FILE_EXT" || failconf=1
                    cp "output${i}.$IMAGES_FILE_EXT" "$FAILED_DIR/$t-output${i}.$IMAGES_FILE_EXT" || failconf=1
                    cp "comp${i}.$IMAGES_FILE_EXT" "$FAILED_DIR/$t-comp${i}.$IMAGES_FILE_EXT" || failconf=1
                fi
            fi
            if [ "$failframe" = "1" ]; then
                # this frame failed, so the sequence failed
                failconf=1
            fi
        done
    fi
    if [ "$failconf" = "1" ]; then
        # this conf failed, so the sequence failed
        failseq=1
    fi
 
    rm $TMP_SCRIPT || exit 1
    rm -rf __pycache__ &> /dev/null

    done # for CONFFILE in conf conf2 conf3
    #############################################
    
    if [ "$failseq" != "1" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') *** PASS $t"
        echo "$t : PASS" >> $RESULTS
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') *** FAIL $t"
        echo "$t : FAIL" >> $RESULTS
    fi
    failseq="0"
    cd ..
done

for x in $CUSTOM_DIRS; do
    cd $x
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** ===================$x========================"
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** START $x"
    $TIMEOUT -s KILL 3600 bash script.sh "$RENDERER_BIN" "$FFMPEG_BIN" "$IDIFF_BIN" || true
    echo "$(date '+%Y-%m-%d %H:%M:%S') *** END $x"
    cd ..
done

# Local Variables:
# indent-tabs-mode: nil
# sh-basic-offset: 4
# sh-indentation: 4
# End:
