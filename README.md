MIRAndImageTopology

===========

Topological data analysis of musical data inspired by music information retrieval (MIR) features, and topological data analysis of images/video using standard image classification features such as HOG

See README files in subdirectories for more info

* DelaySeries/
Contains scripts to compute the delay series of a music file, where each delay window is summarized in a feature space of timbre/pitch features

* MarsyasFeatures/
Contains scripts for extracting ARFF files using the Marsyas suite (http://sourceforge.net/projects/marsyas/files/) to extract pitch, rhythm, and timbre features

* TDAMex/
Contains my implementation of the sparse column reduction algorithm for computing 0D and 1D persistence diagrams.  The implementation is as a C++ mex file, and it is capable of returning generators for 1D homology classes in cell arrays

* VideoPeriodicities/
Contains scripts for computing features on video streams (e.g. 3D spatiotemporal HOG), which can be used as an embedding space for topology much the same way as the Marsyas features are for music



Work supported in part by NSF Research Training Grant "Structure in Complex Data," NSF-DMS 1045133, an NSF "Big Data" Grant NSF 447491, and an NSF Graduate Research Fellowship
