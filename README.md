# Natron-Tests
Unit tests of Natron renders based on images diff using ImageMagick.

To successfully run the tests you should have a fully-featured version of Natron (+bundled plug-ins) working as well as ImageMagick installed on your system with the *convert* command in your path.

To run the tests, simply run:

    ./run-tests.sh <NATRON_RENDERER_BINARY_ABSOLUTE_FILE_PATH>

Make sure that Natron is using the version of the plug-ins that you expect (whether they are system-wide or bundled).

Adding a new test
-----------------

Each test is a sub-directory which should contain the following:

- A Natron project highlighting the feature to test. If any input images are to be used, place them next 
to the .ntp file and refer to them correctly in the Reader node using relative paths. 

- A configuration file named "conf" containing the following line:
    - Line 1: the filename of the Natron project.
    - Line 2: the frame-range to test against the reference images. For example if you want to test the project against all reference images going from 1 to 10 (included), use 1 10 
    - Line 3: The script-name of the node in the project which has produced the reference frames.

A correct configuration file could be as such:

    test.ntp
    1 1
    Blur1

- Reference output images must be in the EXR file format without any compression and 32bit floating point data-type. There should be exactly the same amount of reference images than specified in the frame-range of the configuration file. 
    They should be named *reference* in sequence, that is the Write node that produced them should have a filename such as **/path/to/reference#.exr**.
    The Write node that produced them should have had its parameter named "Format type" set to the value "Project format" (the default).

- Optional data can be added in the directory for debugging purposes, like similar projects made on other softwares so that the user can compare the result amongst softwares.


Comparison
-----------

ImageMagick is used internally 