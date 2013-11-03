from ItunesMiner import *

if __name__ == '__main__':
	fh = open('MainGenreList.txt', 'r')
	genreURLs = fh.readlines()
	fh.close()
	
	artistsByGenre = {}
	artistByURL = {}
	for genreURL in genreURLs:
		print "Reading genre URL %s"%genreURL
		artistListParser = ArtistListParser() 
		artistListParser.feed(readPage(genreURL))
		#a = artistParser.pickRandomArtists(20)
		artists = artistListParser.pickAllArtists()
		for artist in artists:
			[artistName, artistURL] = artist
			print "%i different genres so far"%len(artistsByGenre)
			print "Reading %s"%artistName
			if not (artistURL in artistByURL):
				artistParser = ArtistParser(artistURL)
				artistParser.feed(readPage(artistURL))
				print "Genre: %s, len(songs) = %i\n"%(artistParser.genre, len(artistParser.songs))
				if artistParser.genre and len(artistParser.songs) > 0:
					genre = artistParser.genre
					if not (genre in artistsByGenre):
						artistsByGenre[genre] = []
					artistsByGenre[genre].append(artistParser)
					artistByURL[artistURL] = artistParser		
		fh = open('MainArtistList.txt', 'w')
		for genre in artistsByGenre:
			fh.write("========== %s ==========\n"%genre)
			for a in artistsByGenre[genre]:
				fh.write("%s\n"%a.URL)
		fh.close()					
#		except(UnicodeDecodeError):
#			print "Failed on %s"%genreURL