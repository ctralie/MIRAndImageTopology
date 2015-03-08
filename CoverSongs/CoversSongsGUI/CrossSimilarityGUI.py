import wx
from wx import glcanvas

import matplotlib
from matplotlib import animation
matplotlib.use('WXAgg')
from matplotlib.backends.backend_wxagg import FigureCanvasWxAgg as FigureCanvas
from matplotlib.backends.backend_wx import NavigationToolbar2Wx
from matplotlib.figure import Figure
import wx

import numpy as np
import scipy
import scipy.io as sio
from scipy.io import wavfile

from sys import exit, argv
import os
import math
import time
import threading

import pygame

DEFAULT_SIZE = wx.Size(1000, 1000)
DEFAULT_POS = wx.Point(10, 10)

lock = threading.Lock()

class RedrawThread(threading.Thread):
    def __init__(self, plot):
        threading.Thread.__init__(self)
        self.plot = plot
    def run(self):
    	while True:
			self.plot.draw()
			time.sleep(0.2)

class CrossSimilarityPlot(wx.Panel):
	def __init__(self, parent):
		wx.Panel.__init__(self, parent)
		self.parent = parent
		self.figure = Figure((10.0, 10.0), dpi=100)
		self.axes = self.figure.add_subplot(111)
		self.canvas = FigureCanvas(self, -1, self.figure)
		self.sizer = wx.BoxSizer(wx.VERTICAL)
		self.sizer.Add(self.canvas, 1, wx.LEFT | wx.TOP | wx.GROW)
		self.SetSizer(self.sizer)
		self.Fit()
		self.D = np.array([])
		self.Fs = 44100
		self.songnames = ["", ""]
		self.SampleDelays = [np.array([]), np.array([])]
		
		#Song Playing info
		self.currSong = 0 #Playing the first or second song? (first is along vertical, second is along horizontal)
		self.currPos = 0 #Position in the distance matrix
		self.startTime = 0
		self.Playing = False
		
		self.cid = self.canvas.mpl_connect('button_press_event', self.OnClick)
		#self.drawThread = RedrawThread(self)
		#self.drawThread.start()

	def updateInfo(self, D, Fs, songfilename1, songfilename2, SampleDelays1, SampleDelays2):
		self.D = D
		self.Fs = Fs
		self.songnames = [songfilename1, songfilename2]
		self.SampleDelays = [SampleDelays1, SampleDelays2]
		self.currSong = 0
		self.currPos = -1
		self.startTime = 0
		pygame.mixer.init(frequency=self.Fs)
		pygame.mixer.music.load(songfilename1)
		self.draw()

	def draw(self):
		if len(self.D) == 0:
			return
		thisTime = self.startTime + float(pygame.mixer.music.get_pos()) / 1000.0
		thisPos = self.currPos
		while self.SampleDelays[self.currSong][thisPos] < thisTime:
			thisPos = thisPos + 1
			if thisPos == len(self.SampleDelays[self.currSong]) - 1:
				break
		
		if thisPos != self.currPos:
			self.currPos = thisPos
			self.axes.clear()
			self.axes.imshow(self.D)
			self.axes.hold(True)
			#Plot current marker in song
			if self.currSong == 0:
				#Horizontal line for first song
				self.axes.plot([0, self.D.shape[1]], [self.currPos, self.currPos], 'r')
			else:
				#Vertical line for second song
				self.axes.plot([self.currPos, self.currPos], [0, self.D.shape[0]], 'r')
		self.canvas.draw()
		#wx.PostEvent(self, self.canvas.draw)
	
	def OnClick(self, evt):
		if len(self.D) == 0:
			return
		thisSong = 0
		if evt.button == 1: #TODO: Magic number?
			thisSong = 0
		else:
			thisSong = 1
		if not (thisSong == self.currSong):
			self.currSong = thisSong
			pygame.mixer.init(frequency=self.Fs)
			pygame.mixer.music.load(self.songnames[self.currSong])
		idx = [0, 0]
		idx[0] = int(math.floor(evt.ydata))
		idx[1] = int(math.floor(evt.xdata))
		print "Jumping to %g seconds in %s"%(self.SampleDelays[self.currSong][idx[self.currSong]], self.songnames[self.currSong])
		self.startTime = self.SampleDelays[self.currSong][idx[self.currSong]]
		pygame.mixer.music.play(0, self.startTime)
		self.currPos = idx[self.currSong]
		self.draw()

	def OnPlayButton(self, evt):
		if len(self.SampleDelays[0]) == 0:
			return
		self.Playing = True
		if self.currPos == -1:
			self.currPos = 0
		self.startTime = self.SampleDelays[self.currSong][self.currPos]
		pygame.mixer.music.play(0, self.startTime)
		self.draw()
	
	def OnPauseButton(self, evt):
		self.Playing = False
		pygame.mixer.music.stop()
		self.draw()

class CrossSimilaritysFrame(wx.Frame):
	(ID_LOADMATRIX) = (1)
	
	def __init__(self, parent, id, title, pos=DEFAULT_POS, size=DEFAULT_SIZE, style=wx.DEFAULT_FRAME_STYLE, name = 'GLWindow'):
		style = style | wx.NO_FULL_REPAINT_ON_RESIZE
		super(CrossSimilaritysFrame, self).__init__(parent, id, title, pos, size, style, name)
		#Initialize the menu
		self.CreateStatusBar()
		
		#Sound variables
		self.Fs = 22050
		
		self.size = size
		self.pos = pos
		
		filemenu = wx.Menu()
		menuLoadMatrix = filemenu.Append(CrossSimilaritysFrame.ID_LOADMATRIX, "&Load Dissimilarity Matrix","Load Dissimilarity Matrix")
		self.Bind(wx.EVT_MENU, self.OnLoadMatrix, menuLoadMatrix)
		
		# Creating the menubar.
		menuBar = wx.MenuBar()
		menuBar.Append(filemenu,"&File") # Adding the "filemenu" to the MenuBar
		self.SetMenuBar(menuBar)  # Adding the MenuBar to the Frame content.

		#The numpy plot that will store the dissimilarity matrix
		self.CSPlot = CrossSimilarityPlot(self)

		#The play/pause buttons		
		buttonRow = wx.BoxSizer(wx.HORIZONTAL)
		playButton = wx.Button(self, label = 'PLAY')
		playButton.Bind(wx.EVT_BUTTON, self.CSPlot.OnPlayButton)
		pauseButton = wx.Button(self, label = 'PAUSE')
		pauseButton.Bind(wx.EVT_BUTTON, self.CSPlot.OnPauseButton)
		buttonRow.Add(playButton, 0, wx.EXPAND)
		buttonRow.Add(pauseButton, 0, wx.EXPAND)		

		self.sizer = wx.BoxSizer(wx.VERTICAL)
		self.sizer.Add(buttonRow, 0, wx.EXPAND)
		self.sizer.Add(self.CSPlot, 0, wx.GROW)
		
		self.SetSizer(self.sizer)
		self.Layout()
		self.Show()

	def OnLoadMatrix(self, evt):
	    #Fields: D, Fs, soundfilename1, soundfilename2, SampleDelays1, SampleDelays2
		dlg = wx.FileDialog(self, "Choose a file", ".", "", "*", wx.OPEN)
		if dlg.ShowModal() == wx.ID_OK:
			filename = dlg.GetFilename()
			dirname = dlg.GetDirectory()
			print "Loading %s...."%filename
			filepath = os.path.join(dirname, filename)
			data = sio.loadmat(filepath)
			D = data['D']
			Fs = data['Fs'].flatten()[0]
			#The sound files need to be in the same directory
			songfilename1 = str(data['songfilename1'][0])
			songfilename2 = str(data['songfilename2'][0])
			SampleDelays1 = data['SampleDelays1'].flatten()
			SampleDelays2 = data['SampleDelays2'].flatten()
			self.CSPlot.updateInfo(D, Fs, songfilename1, songfilename2, SampleDelays1, SampleDelays2)
		dlg.Destroy()
		return

if __name__ == "__main__":
	pygame.init()
	app = wx.App()
	frame = CrossSimilaritysFrame(None, -1, 'Cross Similarity GUI')
	frame.Show(True)
	app.MainLoop()
	app.Destroy()
