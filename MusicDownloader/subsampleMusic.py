import os
import shutil
import numpy as np
import matplotlib.pyplot as plt
import scipy.io as sio

class Song(object):
	def __init__(self, filename, artist, album, title, year, genres, genreIndex):
		self.filename = filename
		self.artist = artist
		self.album = album
		self.title = title
		self.year = year
		self.genres = genres
		self.genreIndex = genreIndex

if __name__ == '__main__':
	songs = []
	songsByGenre = {}
	songsByArtist = {}
	for i in range(15):
		indexFile = open("Music/%i/index.txt"%i)
		songsLines = indexFile.readlines()
		for k in range(len(songsLines)/6):
			i1 = k*6
			filename = songsLines[i1].strip()
			artist = songsLines[i1 + 1].strip()
			album = songsLines[i1 + 2].strip()
			title = songsLines[i1 + 3].strip()
			year = int(songsLines[i1 + 4])
			genres = songsLines[i1 + 5].strip()
			genres = genres.split("[")[1]
			genres = genres.split("]")[0]
			genres = [g.lstrip().rstrip()[2:-1] for g in genres.split(",")]
			song = Song(filename, artist, album, title, year, genres, i)
			songs.append(song)
			if not artist in songsByArtist:
				songsByArtist[artist] = []
			songsByArtist[artist].append(song)
			if len(genres) == 1: #Only include songs in the count that have a unique genre
				genre = genres[0]
				if not genre in songsByGenre:
					songsByGenre[genre] = []
				songsByGenre[genre].append(song)
	
	fig, ax = plt.subplots()
	counts = [len(songsByGenre[genre]) for genre in songsByGenre]
	genreNames = [genre for genre in songsByGenre]
	rects1 = ax.bar(range(len(songsByGenre)), counts)
	#ax.set_xticklabels(genreNames)
	for i in range(len(genreNames)):
		print "%s: %i"%(genreNames[i], counts[i])
	#plt.show()
	
	#Randomly pick 450 Jazz songs
	indexFile = open("Music/Jazz/index.txt", 'w')
	perm = np.random.permutation(len(songsByGenre['Jazz']))
	for i in range(450):
		song = songsByGenre['Jazz'][perm[i]]
		indexFile.write("%s\n%s\n%s\n%s\n%s\n%s\n"%(song.filename, song.artist, song.album, song.title, song.year, song.genres))
		shutil.copyfile("Music/%i/%s"%(song.genreIndex, song.filename), "Music/Jazz/%s"%song.filename)
	indexFile.close()
	
	#Randomly pick 450 Rock Songs
	indexFile = open("Music/Rock/index.txt", 'w')
	perm = np.random.permutation(len(songsByGenre['Rock']))
	for i in range(450):
		song = songsByGenre['Rock'][perm[i]]
		indexFile.write("%s\n%s\n%s\n%s\n%s\n%s\n"%(song.filename, song.artist, song.album, song.title, song.year, song.genres))
		shutil.copyfile("Music/%i/%s"%(song.genreIndex, song.filename), "Music/Rock/%s"%song.filename)
	indexFile.close()
	
	#Randomly pick 450 HipHop
	indexFile = open("Music/HipHop/index.txt", 'w')
	perm = np.random.permutation(len(songsByGenre['Hip Hop']))
	for i in range(450):
		song = songsByGenre['Hip Hop'][perm[i]]
		indexFile.write("%s\n%s\n%s\n%s\n%s\n%s\n"%(song.filename, song.artist, song.album, song.title, song.year, song.genres))
		shutil.copyfile("Music/%i/%s"%(song.genreIndex, song.filename), "Music/HipHop/%s"%song.filename)
	indexFile.close()	
