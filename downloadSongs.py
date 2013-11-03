from ItunesMiner import *
import os
import time
import sys

#EXAMPLE_SONG = "http://a464.phobos.apple.com/us/r1000/086/Music/v4/bf/25/79/bf257908-1cad-fee2-f999-cbeb349905d9/mzaf_8102014064216293679.aac.m4a"
PARENTDIR = "Music"

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
	#Automatically flush output buffer so I can see download progress
	sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
	alreadyDownloaded = set([])
	start = 0
	if len(sys.argv) > 1:
		start = int(sys.argv[1])
	artistsByGenre = {}
	fh = open('MainArtistList.txt', 'r')
	genre = None
	for line in fh:
		splitLine = line.split("==========")
		if len(splitLine) == 3:#This line defines the genre
			genre = splitLine[1].strip()
			artistsByGenre[genre] = []
		else:#The lines below the genre definition hold artist links
			artistsByGenre[genre].append(line.strip())
	fh.close()
	#Sort the genres in alphabetical order and output them to the index file
	#so we know which folder holds which genre
	genresAlphabetical = [a[0] for a in sorted(artistsByGenre.iteritems())]
	genreIndexfh = open("%s/index.txt"%PARENTDIR, 'w')
	for genre in genresAlphabetical:
		genreIndexfh.write("%s\n"%genre)
	genreIndexfh.close()
	
	#Write the genre names to an index file at the root of the music directory
	genreNum = 0
	artistNum = 0
	for genre in genresAlphabetical:
		print "Genre: %s  (%i)"%(genre, len(artistsByGenre[genre]))
		dirPrefix = "%s/%i"%(PARENTDIR, genreNum)
		if not os.path.isdir(dirPrefix):
			os.mkdir(dirPrefix)
		os.chdir(dirPrefix)
		addDownloadedSongs(alreadyDownloaded, 'index.txt')
		for artistURL in artistsByGenre[genre]:
			if artistNum >= start:
				print "Downloading songs from Artist %i: %s"%(artistNum, artistURL)
				artistParser = ArtistParser(artistURL)
				artistParser.feed(readPage(artistURL))
				#Write information about the songs to the index file
				fh = open('index.txt', 'a')
				for song in artistParser.songs:
					filename = song.url.split("/")[-1]
					if filename in alreadyDownloaded:
						print "o",#Print o for already downloaded song
						continue #Don't download this song if it's already been downloaded
					#Download each song
					downloadSong(song)
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
				fh.close()
			print ""#Newline
			artistNum = artistNum + 1
		genreNum = genreNum + 1
		#Go back up to the main directory so a new genre directory can be created/switched to
		os.chdir("../../")
