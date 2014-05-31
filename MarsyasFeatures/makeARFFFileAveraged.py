import subprocess
import os
import numpy as np
import scipy.io as sio

if __name__ == '__main__':
	genreIndex = open('../MusicDownloader/Music/index.txt', 'r')
	genreNames = [s.rstrip() for s in genreIndex.readlines()]
	genreIndex.close()
	
	arffName = "songs_AllFeaturesAveraged.arff"
	arffAttributesFile = open('attributesAveraged.arff', 'r')
	attributes = [s.rstrip() for s in arffAttributesFile.readlines()]
	arffFile = open(arffName, 'w')
	arffFile.write("@relation %s\n"%arffName)
	for s in attributes:
		arffFile.write("%s\n"%s)
	arffFile.write("@attribute genre {")
	for i in range(0, len(genreNames)):
		arffFile.write("\"%s\""%genreNames[i])
		if i < len(genreNames) - 1:
			arffFile.write(",")
	arffFile.write("}\n")
	arffFile.write("@attribute artist string\n")
	arffFile.write("@attribute album string\n")
	arffFile.write("@attribute title string\n")
	arffFile.write("\n\n@data\n")
	attributes = [a.split("@attribute ")[1] for a in attributes]
	
	os.chdir('../MusicDownloader/Music')
	dirNum = 0
	songsFeatures = np.array([])
	songsInfo = []
	for genre in genreNames:
		songsIndex = open("%i/index.txt"%dirNum, 'r')
		songsLines = songsIndex.readlines()
		songsLines = [s.rstrip() for s in songsLines]
		#This now assumes additional data has been collected from discogs
		for i in range(0, len(songsLines)/6): 
			#filename, song.artist, song.album, song.title
			i1 = i*6
			filename = songsLines[i1]
			artist = songsLines[i1 + 1]
			album = songsLines[i1 + 2]
			title = songsLines[i1 + 3]
			year = songsLines[i1 + 4]
			genres = songsLines[i1 + 5]
			genres = genres.split("[")[1]
			genres = genres.split("]")[0]
			genres = [g.lstrip().rstrip()[2:-1] for g in genres.split(",")]			
			
			#Step 1: Extract .wav file
			wavName = "%s.wav"%(filename.split(".m4a")[0])
			filename = "%i/%s"%(dirNum, filename)
			if not os.path.isfile(filename):
				print "WARNING: %s not found"%filename
				continue
			wavName = "%i/%s"%(dirNum, wavName)
			command = "avconv -i %s -ac 1 %s"%(filename, wavName)
			print command
			subprocess.call(["avconv", "-i", filename, "-ac", "1", wavName])
			#Step 2: Create a collection file with this .wav file
			mfhandle = open('temp.mf', 'w')
			mfhandle.write(wavName)
			mfhandle.close()
			#Step 3: call bextract to extract the features
			# https://github.com/marsyas/marsyas/blob/master/src/apps/bextract/bextract.cpp
			#bextract 0.mf -w out.arff --downsample 2 -fe -sv -mfcc -zcrs -ctd -rlf -flx -sfm -scf -chroma
			subprocess.call(["bextract", "temp.mf", "-w", "temp.arff", "--downsample", "2", "-fe", "-sv", "-mfcc", "-zcrs", "-ctd", "-rlf", "-flx", "-chroma", "-bf"])
			temparffhandle = open('temp.arff', 'r')
			lines = temparffhandle.readlines()[-1]
			fields = lines.split(",")
			fields = fields[0:-1]
			temparffhandle.close()
			#Step 4: Write the features to the ARFF file with all songs
			for field in fields:
				arffFile.write("%s,"%field)
			arffFile.write("\"%s\",\"%s\",\"%s\",\"%s\"\n"%(genre.replace("\"", ""), artist.replace("\"", ""), album.replace("\"", ""), title.replace("\"", "")))
			#Step 5: Concatenate data to the numpy arrays
			featuresArray = np.array([ [float(x) for x in fields] ])
			if np.prod(songsFeatures.shape) == 0:
				songsFeatures = featuresArray
			else:
				songsFeatures = np.concatenate([songsFeatures, featuresArray])
			songsInfo.append({'filename':filename, 'artist':artist, 'album':album, 'title':title, 'year':int(year), 'genres':genres})
			#Step 6: Remove the .wav file to free up space
			if os.path.isfile(wavName):
				os.remove(wavName)
		dirNum = dirNum+1
		#Save the matrix at intermediate steps
		sio.savemat("songs_AllFeaturesAveraged.mat", {'songsFeatures':songsFeatures, 'songsInfo':songsInfo, 'featureNames':attributes})
		songsIndex.close()
	os.chdir('../../MarsyasFeatures')
	sio.savemat("songs_AllFeaturesAveraged.mat", {'songsFeatures':songsFeatures, 'songsInfo':songsInfo, 'featureNames':attributes})
