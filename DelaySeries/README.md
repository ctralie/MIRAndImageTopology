MIRAndImageTopology: DelaySeries
===========

This directory contains scripts used to compute the sliding window representation of a sound file, where a set of timbre and pitch features are computed in each window (in place of the straight up signal).

The two following libraries will need to be extracted into this directory in order for the code to work
* http://labrosa.ee.columbia.edu/matlab/chroma-ansyn/
* http://labrosa.ee.columbia.edu/matlab/rastamat/

Here's a description of some important files
* getDelaySeriesFeatures.m: Computes and returns the delay series with the "community accepted" pitch/timbre features.  The comments describe in more detail the inputs/outputs

* doHomology.m: An example of how to use the TDA code with the delay series.  Automatically scales each feature to the range [0, 1] before running the TDA code

* ExtractGenerators.m: An example of how to auralize the generators for each 1D homology class
