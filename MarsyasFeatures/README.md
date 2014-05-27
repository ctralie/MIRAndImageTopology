MIRAndImageTopology: MarsyasArff
===========
These scripts extract features using the marsyas music information retrieval suite
http://marsyas.info/
You must first install the marsyas suite.  Directions are as follows:

Marsyas Installation Directions/Tricks
--------------
First download and install the Marsyas suite
http://sourceforge.net/projects/marsyas/files/
with the usual sequence of commands
* cmake .
* make all
* sudo make install

Pay attention to where the shared library libmarsyas.so gets copied.  On my OS it got copied to /usr/local/lib, and it couldn't be found there, so I had to make a symbolic link to /usr/lib

Using scripts
--------------
* Run the script "makeARFFFileAveraged.py" to make an ARFF file of the features averaged over each entire song.  I relied on the ARFF file more towards the beginning of my development when I was checking the features in Weka to make sure they were meaningful.  I updated the program to also save a .mat file, which is more useful for the rest of the TDA stuff
