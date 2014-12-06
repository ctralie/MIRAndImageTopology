#Programmer: Chris Tralie
#Purpose: To use the EchoNest api to get the beats for the Tzanetakis dataset
import requests
import json
import numpy as np
import scipy.io as sio
import os

def getBeats(url, ECHONESTKEY):
	uploadRequestURL = "http://developer.echonest.com/api/v4/track/upload"
	payload = {'format':'json', 'api_key':ECHONESTKEY, 'url':url}
	results = requests.post(uploadRequestURL, payload, timeout = 20)		
	results = results.json()
	if results['response']['status']['code'] == 0:
		trid = results['response']['track']['id']
		results = requests.get("http://developer.echonest.com/api/v4/track/profile?format=json&bucket=audio_summary&api_key=%s&id=%s"%(ECHONESTKEY, trid), timeout = 20)
		results = results.json()
		track = results['response']['track']
		analysis_url = track['audio_summary']['analysis_url']
		r = requests.get(analysis_url)
		results = r.json()
		#bars, track, segments, beats, meta, sections, tatums
		beats = results['beats']
		onsets = []
		durations = []
		for beat in beats:
			onsets.append(beat['start'])
			durations.append(beat['duration'])
		return (onsets, durations)
	else :
		print "ERROR loading information"


if __name__ == '__main__':
	#This code assumes the Tzanetakis dataset has been unextracted
	#and uploaded somewhere.  In this case my site
	baseurl = 'http://people.duke.edu/~cjt16/missing/'
	songs = ['metal.00020', 'pop.00029', 'pop.00065', 'pop.00066', 'reggae.00030', 'reggae.00039', 'reggae.00086']
	fin = open('EchoNestKey.txt')
	ECHONESTKEY = fin.readlines()[0].rstrip('\n')
	fin.close()
	
	for song in songs:
		url = baseurl + song + ".au"
		matFile = "genres/%s/%s.mat"%(song.split('.')[0], song)
		print url
		while True:
			try:
				(onsets, durations) = getBeats(url, ECHONESTKEY)
				print onsets
				break
			except:
				print "TRYING AGAIN"
		onsets = np.array(onsets)
		durations = np.array(durations)
		sio.savemat(matFile, {'onsets':onsets, 'durations':durations})

if __name__ == '__main__2':
	#This code assumes the Tzanetakis dataset has been unextracted
	#and uploaded somewhere.  In this case my site
	baseurl = 'http://people.duke.edu/~cjt16/genres/'
	genres = ['blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock']
	fin = open('EchoNestKey.txt')
	ECHONESTKEY = fin.readlines()[0].rstrip('\n')
	fin.close()
	
	for genre in genres:
		for i in range(100):
			song = "%s/%s.%.5i"%(genre, genre, i)
			url = baseurl + song + ".au"
			matFile = "genres/%s.mat"%song
			if os.path.isfile(matFile):
				print "Skipping %s"%url
			else:
				print url
				while True:
					try:
						(onsets, durations) = getBeats(url, ECHONESTKEY)
						break
					except:
						print "TRYING AGAIN"
				onsets = np.array(onsets)
				durations = np.array(durations)
				sio.savemat(matFile, {'onsets':onsets, 'durations':durations})
