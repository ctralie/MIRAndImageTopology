import subprocess
import os
from sys import argv, exit

if __name__ == '__main__':
	if len(argv) < 2:
		print "Usage: makeDelayARFFFile <input filename>"
		exit(0)
	
	filename = argv[1]
	filePrefix, fileExtension = os.path.splitext(filename)
	
	#Step 1: Create a collection file with this .wav file
	mfhandle = open('temp.mf', 'w')
	mfhandle.write(filename)
	mfhandle.close()
	#Step 3: call bextract to extract the features
	# https://github.com/marsyas/marsyas/blob/master/src/apps/bextract/bextract.cpp
	#bextract 0.mf -w out.arff --downsample 2 -fe -sv -mfcc -zcrs -ctd -rlf -flx -sfm -scf -chroma
	devnull = open('/dev/null', 'w')
	command = ["bextract", "temp.mf", "-w", "temp.arff", "--downsample", "2", "-fe", "-sv", "-mfcc", "-zcrs", "-ctd", "-rlf", "-flx", "-chroma"]
	subprocess.Popen(command, stdout=devnull)
	temparffhandle = open('temp.arff', 'r')
	lines = temparffhandle.readlines()[-1]
	fields = lines.split(",")
	fields = fields[0:-1]
	for f in fields:
		print "%s "%f,
