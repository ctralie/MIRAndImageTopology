import urllib
from HTMLParser import HTMLParser
import random

MAIN_GENRE_PAGE = "https://itunes.apple.com/us/genre/music/id34"
EXAMPLE_SUBGENRE_PAGE = "https://itunes.apple.com/us/genre/music-hip-hop-rap/id18"
#EXAMPLE_SUBGENRE_PAGE = "https://itunes.apple.com/us/genre/music-hip-hop-rap-hip-hop/id1073"

def getAttrDict(attrs):
	attrDict = {}
	for attr in attrs:
		attrDict[attr[0]] = attr[1]	
	return attrDict

#Finds all of the main genres on ITunes
class MainGenreParser(HTMLParser):
	def __init__(self):
		HTMLParser.__init__(self)
		self.genres = []
	
	def handle_starttag(self, tag, attrs):
		#<ul class="list top-level-subgenres">
		if tag == "a" and len(attrs) > 0:
			attrDict = getAttrDict(attrs)
			if "title" in attrDict and "class" in attrDict:
				self.genres.append( (attrDict["title"].split('- Music Downloads on iTunes')[0], attrDict["href"]) )


#Retrieves a random list of artists within a genre
class ArtistListParser(HTMLParser):
	(IDLE, READING, DATAWAITING, FINISHING, FINISHINGDATAWAITING, FINISHED) = (0, 1, 2, 3, 4, 5)	
	def __init__(self):
		HTMLParser.__init__(self)
		self.state = ArtistListParser.IDLE
		self.artists = []
	
	def handle_starttag(self, tag, attrs):
		attrDict = getAttrDict(attrs)
		if tag == "div" and self.state != ArtistListParser.FINISHED:
			if "class" in attrDict:
				cls = attrDict["class"]
				if cls == "column first":
					self.state = ArtistListParser.READING
				elif cls == "column last":
					self.state = ArtistListParser.FINISHING
		elif tag == "a":
			if self.state == ArtistListParser.READING:
				self.artists.append( ["dummy", attrDict["href"]] )
				self.state = ArtistListParser.DATAWAITING
			elif self.state == ArtistListParser.FINISHING:
				self.artists.append( ["dummy", attrDict["href"]] )
				self.state = ArtistListParser.FINISHINGDATAWAITING
	
	def handle_data(self, data):
		if self.state == ArtistListParser.DATAWAITING:
			if len(self.artists) > 0:
				self.artists[-1][0] = data
			self.state = ArtistListParser.READING
		if self.state == ArtistListParser.FINISHINGDATAWAITING:
			if len(self.artists) > 0:
				self.artists[-1][0] = data
			self.state = ArtistListParser.FINISHING
	
	def handle_endtag(self, tag):
		if tag == "ul":
			if self.state == ArtistListParser.FINISHING:
				self.state = ArtistListParser.FINISHED
	
	def pickRandomArtists(self, num):
		N = len(self.artists)
		if num > N:
			return self.artists
		return [ self.artists[i] for i in random.sample(set(range(N)),  num) ]
	
	def pickAllArtists(self):
		return self.artists	

class Song(object):
	def __init__(self, title, artist, album, url, genre = None):
		self.title = title
		self.artist = artist
		self.album = album
		self.url = url
		self.genre = genre

#Retrieves the genre and list of top songs for an artist (if available)
class ArtistParser(HTMLParser):
	(WAITING, READINGH5DATA, WAITINGFORGENRE, READINGGENRE, DONE) = (0, 1, 2, 3, 4)
	def __init__(self, URL):
		HTMLParser.__init__(self)
		self.genre = None
		self.songs = []
		self.URL = URL
		self.state = ArtistParser.WAITING
		
	def handle_starttag(self, tag, attrs):
		if tag == "tr":
			attrDict = getAttrDict(attrs)
			if 'audio-preview-url' in attrDict:
				fields = ['preview-album', 'preview-artist', 'preview-title']
				title = attrDict['preview-title']
				artist = attrDict['preview-artist']
				album = attrDict['preview-album']
				url = attrDict['audio-preview-url']
				song = Song(title, artist, album, url)
				self.songs.append(song)
		elif tag == 'h5':
			self.state = ArtistParser.READINGH5DATA
		elif tag == "a":
			attrDict = getAttrDict(attrs)
			if 'href' in attrDict:
				if attrDict['href'].rfind('/genre/') > 0:
					if self.state == ArtistParser.WAITINGFORGENRE:
						self.state = ArtistParser.READINGGENRE

	def handle_data(self, data):
		if self.state == ArtistParser.READINGH5DATA:
			if data == "Genre":
				self.state = ArtistParser.WAITINGFORGENRE
			else:
				self.state = ArtistParser.WAITING
		elif self.state == ArtistParser.READINGGENRE:
			self.genre = data
			self.state = ArtistParser.DONE
				
	def updateSongGenres(self):
		for song in self.songs:
			song.genre = self.genre


def readPage(URL):
	connection = urllib.urlopen(URL)
	encoding = connection.headers.getparam('charset')
	if encoding:
		page = connection.read().decode(encoding)
		connection.close()
		return page
	return ""
