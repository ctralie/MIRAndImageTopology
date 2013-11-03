from ItunesMiner import *
import os
import time

def downloadSong(filename, song):
	command = "wget %s -O %s.m4a"%(song.url, filename)
	(stdin, stdout, stderr) = os.popen3(command)
	print command
	#Throttle downloads by some amount so Itunes doesn't block me
	time.sleep(2)

if __name__ == '__main__':
	artistsByGenre = {}
	fh = open('MainArtistList.txt', 'r')
	genre = None
	for line in fh:
		splitLine = line.split("==========")
		if len(splitLine) == 3:
			genre = splitLine[1]
			artistsByGenre[genre] = []
		else:
			artistsByGenre[genre].append(line.strip())
	fh.close()
	for genre in artistsByGenre:
		print "Genre: %s  (%i)"%(genre, len(artistsByGenre[genre]))
		for artist in artistsByGenre[genre]:
			print artist
