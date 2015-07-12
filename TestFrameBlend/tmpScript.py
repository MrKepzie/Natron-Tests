import NatronEngine
writer = app.createNode("fr.inria.openfx.WriteOIIO")
inputNode = app.FrameBlend2
writer.connectInput(0, inputNode)
writer.filename.set("[Project]/output#.exr")
writer.frameRange.set(2)
writer.firstFrame.set(4)
writer.lastFrame.set(4)
writer.compression.set(1)
writer.setScriptName("__script_write_node__")
