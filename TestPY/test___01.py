from __future__ import print_function
import NatronEngine

f1 = open('test___01-output.txt','w+')

reader = app.createNode("fr.inria.openfx.ReadOIIO")
writer = app.createNode("fr.inria.openfx.WriteOIIO")
blur = app.createNode("net.sf.cimg.CImgBlur")

reader = app.ReadOIIO1
writer = app.WriteOIIO1
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

