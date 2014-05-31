MIRAndImageTopology/TDAMex
===========

A C++ implementation of the sparse column reduction algorithm for creating the 0D and 1D persistence diagrams.  It is also used to save the generators for the 1D homology classes

You will need to adjust the path to Matlab in the MAKE file, and then type "make" to compile this.  The matlab file "getGeneratorsFromTDAJar.m" combines my code with the RCA code.  It pairs the birth times of my code with the birth times of the RCA code, and it uses the generators from my code.  I avoid computing the death times in my code, so this is fast

Please see "testHomology.m" and "plotPersistenceGenerators.m" for an example of how to use this code.  Generators are stored in a cell array (since they have variable length)
