import subprocess
import os

if __name__ == '__main__':
	arffAttributesFile = open('attributes.arff', 'r')
	attributes = [s.rstrip() for s in arffAttributesFile.readlines()]
	arffFile = open('songs.arff', 'w')
	for s in attributes:
		arffFile.write("%s\n"%s)
	arffFile.write("@attribute genre string\n")
	arffFile.write("@attribute artist string\n")
	arffFile.write("@attribute album string\n")
	arffFile.write("@attribute title string\n")
	arffFile.write("\n\n@data\n")
	
	genreIndex = open('index.txt', 'r')
	dirNum = 0
	for genre in [s.rstrip() for s in genreIndex.readlines()]:
		songsIndex = open("%i/index.txt"%dirNum, 'r')
		songsLines = songsIndex.readlines()
		songsLines = [s.rstrip() for s in songsLines]
		for i in range(0, len(songsLines)/4):
			#filename, song.artist, song.album, song.title
			i1 = i*4
			filename = songsLines[i1]
			artist = songsLines[i1 + 1]
			album = songsLines[i1 + 2]
			title = songsLines[i1 + 3]
			#Step 1: Extract .wav file
			wavName = "%s.wav"%(filename.split(".m4a")[0])
			filename = "%i/%s"%(dirNum, filename)
			wavName = "%i/%s"%(dirNum, wavName)
			command = "avconv -i %s -ac 1 %s"%(filename, wavName)
			print command
			subprocess.call(["avconv", "-i", filename, "-ac", "1", wavName])
			#Step 2: Create a collection file with this .wav file
			mfhandle = open('temp.mf', 'w')
			mfhandle.write(wavName)
			mfhandle.close()
			#Step 3: call bextract to extract the features
			#bextract 0.mf -w out.arff --downsample 2 -fe -sv
			subprocess.call(["bextract", "temp.mf", "-w", "temp.arff", "--downsample", "2", "-fe", "-sv"])
			temparffhandle = open('temp.arff', 'r')
			lines = temparffhandle.readlines()[-1]
			fields = lines.split(",")
			fields = fields[0:-1]
			temparffhandle.close()
			for field in fields:
				arffFile.write("%s,"%field)
			arffFile.write("\"%s\",\"%s\",\"%s\",\"%s\"\n"%(genre.replace("\"", ""), artist.replace("\"", ""), album.replace("\"", ""), title.replace("\"", "")))
			#Step 4: Remove the .wav file to free up space
			os.remove(wavName)
		dirNum = dirNum+1
		songsIndex.close()
	genreIndex.close()
