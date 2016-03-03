from __future__ import print_function
import NatronEngine

f1 = open('test___02-output.txt','w+')
f2 = open('test___02-output-tmp.txt','w+')

reader = app.createNode("fr.inria.openfx.ReadOIIO")
writer = app.createNode("fr.inria.openfx.WriteOIIO")

reader = app.ReadOIIO1
writer = app.WriteOIIO1
reader.filename.set("input1.png")
writer.filename.set("output#.jpg")

writer.connectInput(0,reader)
writer.formatType.set(0)
writer.frameRange.set(2)
writer.firstFrame.set(1)
writer.lastFrame.set(1)
writer.quality.set(10)

print(str(NatronEngine.natron.getBuildNumber()), file=f2)
print(NatronEngine.natron.getNatronDevelopmentStatus(), file=f2)
print(str(NatronEngine.natron.getNatronVersionEncoded()), file=f2)
print(str(NatronEngine.natron.getNatronVersionMajor()), file=f2)
print(str(NatronEngine.natron.getNatronVersionMinor()), file=f2)
print(str(NatronEngine.natron.getNatronVersionRevision()), file=f2)
print(NatronEngine.natron.getNatronVersionString(), file=f2)
print(str(NatronEngine.natron.getNumCpus()), file=f2)
print(NatronEngine.natron.getNatronPath(), file=f2)
print(str(NatronEngine.natron.getNumInstances()), file=f2)
#print(NatronEngine.natron.getInstance(), file=f2)
print(str(NatronEngine.natron.isBackground()), file=f2)
print(str(NatronEngine.natron.is64Bit), file=f2)
print(str(NatronEngine.natron.isLinux), file=f2)
print(str(NatronEngine.natron.isMacOSX), file=f2)
print(str(NatronEngine.natron.isUnix), file=f2)
print(str(NatronEngine.natron.isWindows), file=f2)

f2.close()
with open('test___02-output-tmp.txt') as f:
	numsum=sum(1 for _ in f)
print(numsum, file=f1)

