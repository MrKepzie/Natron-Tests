# -*- coding: utf-8 -*-
#This file was automatically generated by Natron.
#Note that Viewers are never exported

import NatronEngine

def getPluginID():
    return "jclevet.net.tile.001"

def getLabel():
    return "Tile"

def getVersion():
    return 1

def getIconPath():
    return "Py Tile.png"

def getGrouping():
    return "Transform"

def getDescription():
    return "tiles source"

def createInstance(app,group):

    #Create all nodes in the group
    lastNode = app.createNode("fr.inria.built-in.Output", 1, group)
    lastNode.setScriptName("Output1")
    lastNode.setLabel("Output1")
    lastNode.setPosition(740, 358.5)
    lastNode.setSize(104, 36)
    lastNode.setColor(0.6, 0.6, 0.6)
    groupOutput1 = lastNode

    param = lastNode.getParam("Output_layer_name")
    param.setVisible(False)
    del param

    param = lastNode.getParam("highDefUpstream")
    param.setVisible(False)
    del param

    del lastNode



    lastNode = app.createNode("fr.inria.built-in.Input", 1, group)
    lastNode.setScriptName("Input1")
    lastNode.setLabel("Input1")
    lastNode.setPosition(740, 102.5)
    lastNode.setSize(104, 36)
    lastNode.setColor(0.300008, 0.500008, 0.2)
    groupInput1 = lastNode

    param = lastNode.getParam("Output_layer_name")
    param.setVisible(False)
    del param

    param = lastNode.getParam("highDefUpstream")
    param.setVisible(False)
    del param

    del lastNode



    lastNode = app.createNode("net.sf.openfx.STMap", 1, group)
    lastNode.setScriptName("STMap1")
    lastNode.setLabel("STMap1")
    lastNode.setPosition(740, 273.5)
    lastNode.setSize(104, 36)
    lastNode.setColor(0.699992, 0.300008, 0.100008)
    groupSTMap1 = lastNode

    param = lastNode.getParam("wrapU")
    param.setValue(2)
    del param

    param = lastNode.getParam("wrapV")
    param.setValue(2)
    del param

    param = lastNode.getParam("Output_layer_name")
    param.setVisible(False)
    del param

    param = lastNode.getParam("highDefUpstream")
    param.setVisible(False)
    del param

    del lastNode



    lastNode = app.createNode("fr.inria.openfx.SeExpr", 1, group)
    lastNode.setScriptName("SeExpr2")
    lastNode.setLabel("TileUV")
    lastNode.setPosition(507, 252.5)
    lastNode.setSize(128, 78)
    lastNode.setColor(0.300008, 0.500008, 0.2)
    groupSeExpr2 = lastNode

    param = lastNode.getParam("format")
    param.setVisible(False)
    param.setEnabled(False, 0)
    del param

    param = lastNode.getParam("bottomLeft")
    param.setVisible(False)
    param.setEnabled(False, 0)
    param.setEnabled(False, 1)
    del param

    param = lastNode.getParam("size")
    param.setValue(1920, 0)
    param.setValue(1080, 1)
    param.setVisible(False)
    param.setEnabled(False, 0)
    param.setEnabled(False, 1)
    del param

    param = lastNode.getParam("interactive")
    param.setVisible(False)
    param.setEnabled(False, 0)
    del param

    param = lastNode.getParam("doubleParamsNb")
    param.setValue(2, 0)
    del param

    param = lastNode.getParam("x1")
    param.setValue(4, 0)
    del param

    param = lastNode.getParam("x2")
    param.setValue(4, 0)
    del param

    param = lastNode.getParam("x3")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x4")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x5")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x6")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x7")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x8")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x9")
    param.setVisible(False)
    del param

    param = lastNode.getParam("x10")
    param.setVisible(False)
    del param

    param = lastNode.getParam("double2DParamsNb")
    param.setValue(1, 0)
    del param

    param = lastNode.getParam("pos1")
    param.setValue(1, 0)
    param.setValue(1, 1)
    del param

    param = lastNode.getParam("pos2")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos3")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos4")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos5")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos6")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos7")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos8")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos9")
    param.setVisible(False)
    del param

    param = lastNode.getParam("pos10")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color1")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color2")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color3")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color4")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color5")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color6")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color7")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color8")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color9")
    param.setVisible(False)
    del param

    param = lastNode.getParam("color10")
    param.setVisible(False)
    del param

    param = lastNode.getParam("script")
    param.setValue("[u*x1,v*x2,1]")
    del param

    param = lastNode.getParam("alphaScript")
    param.setVisible(False)
    del param

    param = lastNode.getParam("validate")
    param.setVisible(False)
    del param

    param = lastNode.getParam("highDefUpstream")
    param.setVisible(False)
    del param


    #Create the user-parameters
    lastNode.userNatron = lastNode.createPageParam("userNatron", "User")
    param = lastNode.createIntParam("rows", "rows")
    param.setMinimum(1, 0)
    param.setMaximum(10, 0)
    param.setDisplayMinimum(1, 0)
    param.setDisplayMaximum(10, 0)
    param.setDefaultValue(1, 0)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(False)
    param.setAnimationEnabled(True)
    param.setValue(4, 0)
    lastNode.rows = param
    del param

    param = lastNode.createBooleanParam("invRow", "mirror")
    param.setDefaultValue(1)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(True)
    param.setAnimationEnabled(True)
    lastNode.invRow = param
    del param

    param = lastNode.createIntParam("column", "column")
    param.setMinimum(1, 0)
    param.setMaximum(10, 0)
    param.setDisplayMinimum(1, 0)
    param.setDisplayMaximum(10, 0)
    param.setDefaultValue(1, 0)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(False)
    param.setAnimationEnabled(True)
    param.setValue(4, 0)
    lastNode.column = param
    del param

    param = lastNode.createBooleanParam("invCol", "mirror")
    param.setDefaultValue(1)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(True)
    param.setAnimationEnabled(True)
    lastNode.invCol = param
    del param

    #Refresh the GUI with the newly created parameters
    lastNode.refreshUserParamsGUI()
    del lastNode




    #Create the parameters of the group node the same way we did for all internal nodes
    lastNode = group
    param = lastNode.getParam("Output_layer_name")
    param.setVisible(False)
    del param

    param = lastNode.getParam("highDefUpstream")
    param.setVisible(False)
    del param


    #Create the user-parameters
    lastNode.userNatron = lastNode.createPageParam("userNatron", "User")
    param = lastNode.createIntParam("rows", "rows")
    param.setMinimum(1, 0)
    param.setMaximum(10, 0)
    param.setDisplayMinimum(1, 0)
    param.setDisplayMaximum(10, 0)
    param.setDefaultValue(1, 0)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(False)
    param.setAnimationEnabled(True)
    param.setValue(4, 0)
    lastNode.rows = param
    del param

    param = lastNode.createBooleanParam("mirrorRow", "mirror")
    param.setDefaultValue(1)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(True)
    param.setAnimationEnabled(True)
    lastNode.mirrorRow = param
    del param

    param = lastNode.createIntParam("columns", "columns")
    param.setMinimum(1, 0)
    param.setMaximum(10, 0)
    param.setDisplayMinimum(1, 0)
    param.setDisplayMaximum(10, 0)
    param.setDefaultValue(1, 0)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(False)
    param.setAnimationEnabled(True)
    param.setValue(4, 0)
    lastNode.columns = param
    del param

    param = lastNode.createBooleanParam("mirrorCol", "mirror")
    param.setDefaultValue(1)

    #Add the param to the page
    lastNode.userNatron.addParam(param)

    #Set param properties
    param.setHelp("")
    param.setAddNewLine(True)
    param.setAnimationEnabled(True)
    lastNode.mirrorCol = param
    del param

    #Refresh the GUI with the newly created parameters
    lastNode.refreshUserParamsGUI()
    del lastNode

    #Now that all nodes are created we can connect them together, restore expressions
    groupOutput1.connectInput(0, groupSTMap1)

    groupSTMap1.connectInput(0, groupSeExpr2)
    groupSTMap1.connectInput(1, groupInput1)
    param = groupSTMap1.getParam("wrapU")
    param.setExpression("thisGroup.SeExpr2.invRow.get()+1", False, 0)
    del param
    param = groupSTMap1.getParam("wrapV")
    param.setExpression("thisGroup.SeExpr2.invCol.get()+1", False, 0)
    del param

    groupSeExpr2.connectInput(0, groupInput1)
    param = groupSeExpr2.getParam("x1")
    param.setExpression("thisGroup.SeExpr2.rows.get()", False, 0)
    del param
    param = groupSeExpr2.getParam("x2")
    param.setExpression("thisGroup.SeExpr2.column.get()", False, 0)
    del param
    param = groupSeExpr2.getParam("rows")
    param.setExpression("thisGroup.rows.get()", False, 0)
    del param
    param = groupSeExpr2.getParam("invRow")
    param.setExpression("thisGroup.mirrorRow.get()", False, 0)
    del param
    param = groupSeExpr2.getParam("column")
    param.setExpression("thisGroup.columns.get()", False, 0)
    del param
    param = groupSeExpr2.getParam("invCol")
    param.setExpression("thisGroup.mirrorCol.get()", False, 0)
    del param

