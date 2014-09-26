XASH
====

XTrace allows you to receive trace() data without having to be in the flash IDE. XTrace wraps around a custom socket server I wrote in java that will accept connections via XMLSocket on port 9994. To easily send trace data to the 'trace server' you can use the custom debug class included with the download. After calling debug.initSocket("127.0.0.1"); all data passed to debug.trace() will be send through a socket and given to the 'trace server'. XTrace will display the data received from the 'trace server' in a floating window as shown below.

The window will automatically fade out of existence when it has not received any trace information for over 30sec, and will appear again when it receives more trace data. Since the 'trace server' is written in java it should work on other platforms (IE Windows & Linux), it would just have to be used from the command line. The download includes a code example showing how to use the debug class in a flash application.
