MIRAndImageTopology: MusicDownloader
===========

This directory contains scripts used to mine data from ITunes.  First edit the file "MainGenreList.txt" if you would like to download songs from genres that are not represented in that file.  To add a genre, add a line with the link to that genre on the ITunes web site.  For example, for rock, the link is
https://itunes.apple.com/us/genre/music-rock/id21

Once the genre list is setup, run the script "getMainArtistList.py".  This will create a file "MainArtistList.txt" which contains all of the artists that will be downloaded.  At this point, you have one of two choices to download the songs listed in the file one by one

1) Run "downloadSongs.py".  This will populate the directory "Music" with 30 second clips downloaded from all of the artists in "MainArtistList.txt", separated into each directory by the genre label provided on the ITunes web site

2) Run "downloadSongsDiscogs.py".  This does the same as in #1 but it also cross-references each song with the discogs web site
http://www.discogs.com/
to get the year that each song was released, and a list of genres (this list is often a superset of what's provided on ITunes since it allows more than one genre to be listed).  For this to work, you will need to install the discogs client
https://github.com/discogs/discogs_client

NOTE: Both downloadsongs.py and downloadSongsDiscogs.py can be stopped and restarted, and they will attempt to pick up where they left off.  This is in case the internet connection is interrupted or something else happens.  The program draws outputs a "." for every successfully downloaded song, a "o" for every song that is skipped because it has already been downloaded, a "x" for each failed song (usually because it has a strange name), and a "*" for each song that was not found in the discogs database (when using the downloadSongsDiscogs program).  I've noticed that after I restart, there are often a lot of new songs downloaded even for artists that have already completely finished on a previous run of the program.  I have to conclude this must be either due to randomization of the list of top 25 songs on the ITunes page for each artist, or something is making their rankings change almost real time.
