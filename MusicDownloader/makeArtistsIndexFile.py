import subprocess
import os
import numpy as np
import scipy.io as sio
import pickle

if __name__ == '__main__':
	artistsFile = open('artistsFile.txt', 'r')	

	lines = artistsFile.readlines()
	artistsFile.close()
	allArtists = []
	artistURLs = []
	folderNames = []
	for i in range(0, len(lines)/2):
		folderNames.append(lines[i*2].rstrip())
		artistURLs.append(lines[i*2+1].rstrip())

	for folderName in folderNames:
		songsInfo = []
		print "Reading directory %s..."%folderName
		songsIndex = open("%s/index.txt"%folderName, 'r')
		songsLines = songsIndex.readlines()
		songsLines = [s.rstrip() for s in songsLines]
		#This now assumes additional data has been collected from discogs
		for i in range(0, len(songsLines)/4):
			#filename, song.artist, song.album, song.title
			i1 = i*4
			filename = songsLines[i1]
			artist = songsLines[i1 + 1]
			album = songsLines[i1 + 2]
			title = songsLines[i1 + 3]
			filepath = "%s/%s"%(folderName, filename)
			songsInfo.append({'filepath':"%s"%filepath, 'artist':artist, 'album':album, 'title':title})
		allArtists.append(songsInfo)
			
	sio.savemat("index.mat", {'allArtists':allArtists, 'artistNames':folderNames})

