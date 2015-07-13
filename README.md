# Natron-Tests
Unit tests of Natron renders based on images diff using ImageMagick.

The initial test suite was written by Alexandre Gauthier-Foichat.

The main-repository for Natron is [here](https://github.com/MrKepzie/Natron).

To successfully run the tests you should have a fully-featured version of Natron (+bundled plug-ins) working as well as ImageMagick installed on your system with the *compare* command in your path.

To run the tests, simply run:

    ./run-tests.sh <NATRON_RENDERER_BINARY_ABSOLUTE_FILE_PATH>

Make sure that Natron is using the version of the plug-ins that you expect (whether they are system-wide or bundled) and that it can have access to the OpenColorIO configuration files. (Should be located in ../Resources relative to the NatronRenderer binary)

Adding a new test
-----------------

Each test is a sub-directory which should contain the following:

- A Natron project highlighting the feature to test. If any input images are to be used, place them next 
to the .ntp file and refer to them correctly in the Reader node using relative paths. 

- A configuration file named "conf" containing the following line:
    - Line 1: the filename of the Natron project.
    - Line 2: the frame-range to test against the reference images. For example if you want to test the project against all reference images going from 1 to 10 (included), use 1 10 
    - Line 3: The script-name of the node in the project which has produced the reference frames.
    - Line 4: The file-extension of the reference images. This should be something that the Write node of Natron can output.
    - Line 5: (optional) The quality level (0-100) of the image to write for compression methods that allow a variable amount of compression. The default value used will be 10.

A correct configuration file could be as such:

    test.ntp
    1 1
    Blur1
    jpg
    10

- Reference output images must be in a lightweight file format (such as jpg) with bad quality compression. We do not really care about the quality since a compression applied on the similar image should yield the same result. Note that output images should tend to be relatively small. There should be exactly the same amount of reference images than specified in the frame-range of the configuration file. 
    They should be named *reference* in sequence, that is the Write node that produced them should have a filename such as **/path/to/reference#.jpg**.
    The Write node that produced them should have had its parameter named "Format type" set to the value "Project format" (the default).

- Optional data can be added in the directory for debugging purposes, like similar projects made on other softwares so that the user can compare the result amongst softwares.

You can submit new tests with a [pull-request](https://github.com/MrKepzie/Natron-Tests/pulls) containing the new test sub-directory. It will be accepted if it is respecting the points above.


Comparison
-----------

ImageMagick is used internally to count different pixels with the following command-line:

    compare -metric AE reference.jpg output.jpg diff.jpg

