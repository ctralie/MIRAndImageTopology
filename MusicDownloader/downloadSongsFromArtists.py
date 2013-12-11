from ItunesMiner import *
import os
import time
import sys

def downloadSong(song, filename = None):
	command = "wget %s"%song.url
	if filename:
		command = "wget %s -O %s.m4a"%(song.url, filename)
	(stdin, stdout, stderr) = os.popen3(command)
	#print command
	#Throttle downloads by some amount so Itunes doesn't block me
	time.sleep(2)

def addDownloadedSongs(alreadyDownloaded, indexFilename):
	if not os.path.isfile(indexFilename):
		return
	fh = open(indexFilename, 'r')
	lines = fh.readlines()
	for i in range(0, len(lines), 4):
		alreadyDownloaded.add(lines[i].strip())
	fh.close()

if __name__ == '__main__':
	if len(sys.argv) < 2:
		print "Usage: downloadSongsFromArtists <artistsFile.txt>"
		sys.exit(0)
	
	artistListFile = open(sys.argv[1], 'r')
	lines = artistListFile.readlines()
	artistURLs = []
	folderNames = []
	for i in range(0, len(lines)/2):
		folderNames.append(lines[i*2].rstrip())
		artistURLs.append(lines[i*2+1].rstrip())
	
	for i in range(0, len(artistURLs)):
		#Automatically flush output buffer so I can see download progress
		sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
		alreadyDownloaded = set([])
		baseURL = artistURLs[i]
		folderName = folderNames[i]
		if not os.path.isdir(folderName):
			os.mkdir(folderName)
		os.chdir(folderName)
		addDownloadedSongs(alreadyDownloaded, 'index.txt')
		fh = open('index.txt', 'a')
		trackPage = 1
		while True:
			artistURL = "%s?trackPage=%i#trackPage"%(baseURL, trackPage)
			artistParser = ArtistParser(artistURL)
			artistParser.feed(readPage(artistURL))
			#Go until there are no more song pages
			if len(artistParser.songs) == 0:
				break
			print "\nDownloading %s song page %i"%(folderName, trackPage)
			#Write information about the songs to the index file
			for song in artistParser.songs:
				filename = song.url.split("/")[-1]
				if filename in alreadyDownloaded:
					print "o",#Print o for already downloaded song
					continue #Don't download this song if it's already been downloaded
				#Download each song
				downloadSong(song)
				alreadyDownloaded.add(filename)
				#Write information about each song to a file so it can be labeled later
				#Write four lines for each song
				#FILENAME
				#ARTIST
				#ALBUM
				#TITLE
				try:
					writeString = "%s\n%s\n%s\n%s\n"%(filename, song.artist, song.album, song.title)
					fh.write(writeString)
					print ".",#Print a . for a successful downloaded/indexed song
				except(UnicodeEncodeError):
					print "x",#Print an X for a failed song
					pass
			trackPage = trackPage + 1
		fh.close()
		#Go back up to the main directory so a new artist directory can be created/switched to
		os.chdir("../")
