import NatronEngine

reader1 = app.createNode("fr.inria.openfx.ReadOIIO")
reader2 = app.createNode("fr.inria.openfx.ReadOIIO")
writer1 = app.createNode("fr.inria.openfx.WriteOIIO")
writer2 = app.createNode("fr.inria.openfx.WriteOIIO")
output1 = app.createNode("fr.inria.built-in.Output")
output2 = app.createNode("fr.inria.built-in.Output")

if not reader1:
	raise ValueError("Could not create fr.inria.openfx.ReadOIIO")
	sys.exit(1)
if not reader1.setScriptName("DefaultRead1"):
	raise NameError("Could not set script-name to DefaultRead")
	sys.exit(1)
if not reader2:
        raise ValueError("Could not create fr.inria.openfx.ReadOIIO")
        sys.exit(1)
if not reader2.setScriptName("DefaultRead2"):
        raise NameError("Could not set script-name to DefaultRead")
        sys.exit(1)
if not writer1:
	raise ValueError("Could not create fr.inria.openfx.WriteOIIO")
	sys.exit(1)
if not writer1.setScriptName("DefaultWrite1"):
	raise NameError("Could not set script-name to DefaultWrite")
	sys.exit(1)
if not writer2:
        raise ValueError("Could not create fr.inria.openfx.WriteOIIO")
        sys.exit(1)
if not writer2.setScriptName("DefaultWrite2"):
        raise NameError("Could not set script-name to DefaultWrite")
        sys.exit(1)
if not output1:
	raise ValueError("Could not create fr.inria.built-in.Output")
	sys.exit(1)
if not output2:
	raise ValueError("Could not create fr.inria.built-in.Output")
	sys.exit(1)

reader1 = app.DefaultRead1
reader2 = app.DefaultRead2
writer1 = app.DefaultWrite1
writer2 = app.DefaultWrite2
inputNode1 = app.DefaultRead1
inputNode2 = app.DefaultRead2

reader1.filename.set("input1.png")
reader2.filename.set("input2.png")
writer1.filename.set("output3.jpg")
writer2.filename.set("output4.jpg")

writer1.connectInput(0,inputNode1)
writer1.formatType.set(0)
writer1.frameRange.set(2)
writer1.firstFrame.set(1)
writer1.lastFrame.set(1)
writer1.quality.set(qualityValue)

writer2.connectInput(0,inputNode2)
writer2.formatType.set(0)
writer2.frameRange.set(2)
writer2.firstFrame.set(1)
writer2.lastFrame.set(1)
writer2.quality.set(qualityValue)

output1.connectInput(0,inputNode1)
output2.connectInput(0,inputNode2)

