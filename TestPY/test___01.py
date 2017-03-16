from __future__ import print_function
import NatronEngine

f1 = open('test___01-output.txt','w+')

reader = app.createNode("fr.inria.openfx.ReadOIIO")
writer = app.createNode("fr.inria.openfx.WriteOIIO")
blur = app.createNode("net.sf.cimg.CImgBlur")

reader = app.Read1
writer = app.Write1
blur = app.BlurCImg1
print(blur.getScriptName(), file=f1)

reader.filename.set("input1.png")
writer.filename.set("output#.jpg")

writer.connectInput(0,blur)
writer.formatType.set(0)
writer.frameRange.set(2)
writer.firstFrame.set(1)
writer.lastFrame.set(1)
writer.quality.set(10)

if blur.canConnectInput(0,reader):
        print("can connect", file=f1)

blur.connectInput(0,reader)
blur.size.setValueAtTime(0,1)
blur.size.setValueAtTime(10,2)
blur.size.setValueAtTime(20,3)
blur.size.set(30,30,4)

print(blur.size.getDefaultValue(), file=f1)
print(blur.size.get().x, file=f1)
print(blur.size.get().y, file=f1)
print(blur.size.getValue(), file=f1)
print(blur.size.get(2).x, file=f1)
print(blur.size.get(2).y, file=f1)
print(blur.size.get(3).x, file=f1)
print(blur.size.get(3).y, file=f1)
print(blur.size.get(4).x, file=f1)
print(blur.size.get(4).y, file=f1)
print(blur.size.get(5).x, file=f1)
print(blur.size.get(5).y, file=f1)
print(blur.size.getValueAtTime(1), file=f1)
print(blur.size.getValueAtTime(2), file=f1)
print(blur.size.getValueAtTime(3), file=f1)
print(blur.size.getValueAtTime(4), file=f1)
print(blur.size.getValueAtTime(5), file=f1)

availLay = str(blur.getAvailableLayers(-1))
if availLay:
        print ("getAvailableLayers", file=f1)

if blur.addUserPlane("MyLayer",["R", "G", "B", "A"]):
        print("added user plane", file=f1)

print(str(blur.getBitDepth()), file=f1)

getCol=str(blur.getColor())
if getCol:
        print("getColor", file=f1)

print(str(blur.getCurrentTime()), file=f1)
print(str(blur.getFrameRate()), file=f1)

getIn = blur.getInput(0)
print(str(getIn.getLabel()), file=f1)
print(str(blur.getInputLabel(0)), file=f1)
print(str(blur.getMaxInputCount()), file=f1)

sizeParam = blur.getParam("size")
print(str(sizeParam.getCanAnimate()), file=f1)
print(str(sizeParam.getEvaluateOnChange()), file=f1)
print(str(sizeParam.getHelp()), file=f1)
print(str(sizeParam.getIsAnimationEnabled()), file=f1)
print(str(sizeParam.getIsEnabled(0.0)), file=f1)
print(str(sizeParam.getIsPersistent()), file=f1)
print(str(sizeParam.getIsVisible()), file=f1)
print(str(sizeParam.getNumDimensions()), file=f1)
print(str(sizeParam.getScriptName()), file=f1)
print(str(sizeParam.getTypeName()), file=f1)

