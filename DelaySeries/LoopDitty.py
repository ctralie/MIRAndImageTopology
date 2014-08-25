#Based off of http://wiki.wxpython.org/GLCanvas
#Lots of help from http://wiki.wxpython.org/Getting%20Started
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
from OpenGL.arrays import vbo
from OpenGL.GL import shaders
import wx
from wx import glcanvas

from Cameras3D import *
from sys import exit, argv
import random
import numpy as np
import scipy.io as sio
from pylab import cm
import os
import subprocess
import math
import time
from DelaySeries import *
import pygame.mixer
import time

DEFAULT_SIZE = wx.Size(1200, 800)
DEFAULT_POS = wx.Point(10, 10)
MAXPOINTS = -1

def saveImageGL(mvcanvas, filename):
	view = glGetIntegerv(GL_VIEWPORT)
	img = wx.EmptyImage(view[2], view[3] )
	pixels = glReadPixels(0, 0, view[2], view[3], GL_RGB,
		             GL_UNSIGNED_BYTE)
	img.SetData( pixels )
	img = img.Mirror(False)
	img.SaveFile(filename, wx.BITMAP_TYPE_PNG)



def doPCA(DelaySeries, ncomponents = 3):
	DelaySeries = DelaySeries - np.min(DelaySeries, 0)
	DelaySeries = DelaySeries/np.max(DelaySeries, 0)
	X = DelaySeries - np.tile(np.mean(DelaySeries, 0), (DelaySeries.shape[0], 1))
	X[np.isinf(X)] = 0
	X[np.isnan(X)] = 0
	D = (X.T).dot(X)
	(lam, eigvecs) = linalg.eig(D)
	eigvecs = eigvecs[:, 0:ncomponents]
	Y = X.dot(eigvecs)
	return Y

#http://zetcode.com/wxpython/dialogs/
class DelaySeriesParamsDialog(wx.Dialog):
	def __init__(self, *args, **kw):
		super(DelaySeriesParamsDialog, self).__init__(*args, **kw)
		#Remember parameters from last time
		self.hopSizeDef = args[0].hopSize
		self.skipSizeDef = args[0].skipSize
		self.windowSizeDef = args[0].windowSize
		self.Fs = args[0].Fs
		self.filename = args[0].filename
		self.InitUI()
		self.SetSize((250, 200))
		self.SetTitle("Delay Series Parameters")


	def InitUI(self):
		pnl = wx.Panel(self)
		vbox = wx.BoxSizer(wx.VERTICAL)

		sb = wx.StaticBox(pnl, label='Parameters')
		sbs = wx.StaticBoxSizer(sb, orient=wx.VERTICAL)
		
		sbs.Add(wx.StaticText(pnl, label = self.filename))
		sbs.Add(wx.StaticText(pnl, label = "Sample Rate: %i"%self.Fs))

		hbox1 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox1.Add(wx.StaticText(pnl, label='Hop Size'))
		self.hopSize = wx.TextCtrl(pnl)
		self.hopSize.SetValue("%i"%self.hopSizeDef)
		hbox1.Add(self.hopSize, flag=wx.LEFT, border=5)
		sbs.Add(hbox1)

		hbox2 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox2.Add(wx.StaticText(pnl, label='Skip Size'))
		self.skipSize = wx.TextCtrl(pnl)
		self.skipSize.SetValue("%i"%self.skipSizeDef)
		hbox2.Add(self.skipSize, flag=wx.LEFT, border=5)
		sbs.Add(hbox2)
		
		hbox3 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox3.Add(wx.StaticText(pnl, label='Window Size'))
		self.windowSize = wx.TextCtrl(pnl)
		self.windowSize.SetValue("%i"%self.windowSizeDef)
		hbox3.Add(self.windowSize, flag=wx.LEFT, border=5)
		sbs.Add(hbox3)

		pnl.SetSizer(sbs)

		hboxexit = wx.BoxSizer(wx.HORIZONTAL)
		okButton = wx.Button(self, label='Ok')
		closeButton = wx.Button(self, label='Close')
		hboxexit.Add(okButton)
		hboxexit.Add(closeButton, flag=wx.LEFT, border=5)

		vbox.Add(pnl, proportion=1, 
		flag=wx.ALL|wx.EXPAND, border=5)
		vbox.Add(hboxexit, 
		flag=wx.ALIGN_CENTER|wx.TOP|wx.BOTTOM, border=10)

		self.SetSizer(vbox)

		okButton.Bind(wx.EVT_BUTTON, self.OnClose)
		closeButton.Bind(wx.EVT_BUTTON, self.OnClose)


	def OnClose(self, e):
		self.hopSize = int(self.hopSize.GetValue())
		self.skipSize = int(self.skipSize.GetValue())
		self.windowSize = int(self.windowSize.GetValue())
		self.Destroy()


class LoopDittyCanvas(glcanvas.GLCanvas):
	def __init__(self, parent):
		attribs = (glcanvas.WX_GL_RGBA, glcanvas.WX_GL_DOUBLEBUFFER, glcanvas.WX_GL_DEPTH_SIZE, 24)
		glcanvas.GLCanvas.__init__(self, parent, -1, attribList = attribs)	
		self.context = glcanvas.GLContext(self)
		
		self.parent = parent
		#Camera state variables
		self.size = self.GetClientSize()
		self.camera = MousePolarCamera(self.size.width, self.size.height)
		
		
		#Main state variables
		self.MousePos = [0, 0]
		self.initiallyResized = False
		
		self.bbox = np.array([ [1, 1, 1], [-1, -1, -1] ])
		random.seed()
		
		#Point cloud and playing information
		self.filename = ""
		self.X = np.array([])
		self.displayCount = 0
		self.SampleDelays = np.array([])
		self.Playing = False
		self.PlayIDX = 0
		
		self.GLinitialized = False
		#GL-related events
		wx.EVT_ERASE_BACKGROUND(self, self.processEraseBackgroundEvent)
		wx.EVT_SIZE(self, self.processSizeEvent)
		wx.EVT_PAINT(self, self.processPaintEvent)
		#Mouse Events
		wx.EVT_LEFT_DOWN(self, self.MouseDown)
		wx.EVT_LEFT_UP(self, self.MouseUp)
		wx.EVT_RIGHT_DOWN(self, self.MouseDown)
		wx.EVT_RIGHT_UP(self, self.MouseUp)
		wx.EVT_MIDDLE_DOWN(self, self.MouseDown)
		wx.EVT_MIDDLE_UP(self, self.MouseUp)
		wx.EVT_MOTION(self, self.MouseMotion)		
		#self.initGL()
	
	
	def processEraseBackgroundEvent(self, event): pass #avoid flashing on MSW.

	def processSizeEvent(self, event):
		self.size = self.GetClientSize()
		self.SetCurrent(self.context)
		glViewport(0, 0, self.size.width, self.size.height)
		if not self.initiallyResized:
			#The canvas gets resized once on initialization so the camera needs
			#to be updated accordingly at that point
			self.camera = MousePolarCamera(self.size.width, self.size.height)
			self.camera.centerOnBBox(self.bbox, math.pi/2, math.pi/2)
			self.initiallyResized = True

	def processPaintEvent(self, event):
		dc = wx.PaintDC(self)
		self.SetCurrent(self.context)
		if not self.GLinitialized:
			self.initGL()
			self.GLinitialized = True
		self.repaint()

	def startAnimation(self, evt):
		if len(self.SampleDelays) > 0:
			print "Playing %s"%self.filename
			self.Playing = True
			self.PlayIDX = 0
			s = pygame.mixer.Sound(self.filename)
			s.play()
			self.startTime = time.time()
			self.Refresh()

	def repaint(self):
		#Set up projection matrix
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		farDist = 3*np.sqrt(np.sum( (self.camera.eye - np.mean(self.bbox, 0))**2 ))
		nearDist = farDist/50.0
		gluPerspective(180.0*self.camera.yfov/np.pi, float(self.size.x)/self.size.y, nearDist, farDist)
		
		#Set up modelview matrix
		self.camera.gotoCameraFrame()	
		glClearColor(0.0, 0.0, 0.0, 0.0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
		
		if len(self.X) > 0:
			glDisable(GL_LIGHTING)
			glColor3f(1, 0, 0)
			glPointSize(3)
			NPoints = self.X.shape[0]
			StartPoint = 0
			EndPoint = self.X.shape[0]-1
			if self.Playing:
				self.endTime = time.time()
				dT = self.endTime - self.startTime
				if dT > self.SampleDelays[self.PlayIDX]:
					self.PlayIDX = self.PlayIDX + 1
					if self.PlayIDX == NPoints - 1:
						self.Playing = False
				EndPoint = self.PlayIDX+1
				if MAXPOINTS != -1:
					StartPoint = max(EndPoint - MAXPOINTS, 0)
				self.Refresh()

			self.vbo.bind()
			glEnableClientState(GL_VERTEX_ARRAY)
			glVertexPointerf( self.vbo )
			
			self.XColorsVBO.bind()
			glEnableClientState(GL_COLOR_ARRAY)
			glColorPointer(3, GL_FLOAT, 0, self.XColorsVBO)
			
			glDrawArrays(GL_LINES, StartPoint, EndPoint - StartPoint + 1)
			glDrawArrays(GL_LINES, StartPoint+1, EndPoint)
			glDrawArrays(GL_POINTS, StartPoint, EndPoint - StartPoint + 1)
			self.XColorsVBO.unbind()
			self.vbo.unbind()
			glDisableClientState(GL_VERTEX_ARRAY)
			glDisableClientState(GL_COLOR_ARRAY)
		self.SwapBuffers()
		self.Refresh()
	
	def initGL(self):		
		glutInit('')
		glEnable(GL_NORMALIZE)
		glEnable(GL_DEPTH_TEST)

	def handleMouseStuff(self, x, y):
		#Invert y from what the window manager says
		y = self.size.height - y
		self.MousePos = [x, y]

	def MouseDown(self, evt):
		x, y = evt.GetPosition()
		self.CaptureMouse()
		self.handleMouseStuff(x, y)
		self.Refresh()
	
	def MouseUp(self, evt):
		x, y = evt.GetPosition()
		self.handleMouseStuff(x, y)
		self.ReleaseMouse()
		self.Refresh()

	def MouseMotion(self, evt):
		x, y = evt.GetPosition()
		[lastX, lastY] = self.MousePos
		self.handleMouseStuff(x, y)
		dX = self.MousePos[0] - lastX
		dY = self.MousePos[1] - lastY
		if evt.Dragging():
			if evt.MiddleIsDown():
				self.camera.translate(dX, dY)
			elif evt.RightIsDown():
				self.camera.zoom(-dY)#Want to zoom in as the mouse goes up
			elif evt.LeftIsDown():
				self.camera.orbitLeftRight(dX)
				self.camera.orbitUpDown(dY)
		self.Refresh()

class LoopDittyFrame(wx.Frame):
	(ID_LOADSONGFILE, ID_SAVESCREENSHOT) = (1, 2)
	
	def setupPosVBO(self):
		idx = np.array([], dtype = 'int32')
		if self.TimbreCheckbox.GetValue():
			idx = np.append(idx, self.TimbreIdx)
		if self.MFCCCheckbox.GetValue():
			idx = np.append(idx, self.MFCCIdx)
		if self.ChromaCheckbox.GetValue():
			idx = np.append(idx, self.ChromaIdx)
		self.glcanvas.X = doPCA(self.DelaySeries[:, idx])
		self.glcanvas.vbo = vbo.VBO(np.array(self.glcanvas.X, dtype='float32'))
	
	def ToggleFeature(self, evt):
		self.setupPosVBO()
		self.glcanvas.Refresh()
	
	def __init__(self, parent, id, title, pos=DEFAULT_POS, size=DEFAULT_SIZE, style=wx.DEFAULT_FRAME_STYLE, name = 'GLWindow'):
		style = style | wx.NO_FULL_REPAINT_ON_RESIZE
		super(LoopDittyFrame, self).__init__(parent, id, title, pos, size, style, name)
		#Initialize the menu
		self.CreateStatusBar()
		
		#Sound variables
		self.soundSamples = None
		self.SampleDelays = None
		pygame.mixer.init()
		self.hopSize = 512
		self.skipSize = 1
		self.windowSize = 43
		self.Fs = 22050
		
		self.size = size
		self.pos = pos
		
		filemenu = wx.Menu()
		menuOpenSong = filemenu.Append(LoopDittyFrame.ID_LOADSONGFILE, "&Load Song File","Load Song File")
		self.Bind(wx.EVT_MENU, self.OnLoadSongFile, menuOpenSong)
		menuSaveScreenshot = filemenu.Append(LoopDittyFrame.ID_SAVESCREENSHOT, "&Save Screenshot", "Save a screenshot of the GL Canvas")
		self.Bind(wx.EVT_MENU, self.OnSaveScreenshot, menuSaveScreenshot)
		menuExit = filemenu.Append(wx.ID_EXIT,"E&xit"," Terminate the program")
		self.Bind(wx.EVT_MENU, self.OnExit, menuExit)
		
		# Creating the menubar.
		menuBar = wx.MenuBar()
		menuBar.Append(filemenu,"&File") # Adding the "filemenu" to the MenuBar
		self.SetMenuBar(menuBar)  # Adding the MenuBar to the Frame content.
		self.glcanvas = LoopDittyCanvas(self)
		
		self.rightPanel = wx.BoxSizer(wx.VERTICAL)
		
		#Buttons to go to a default view
		animatePanel = wx.BoxSizer(wx.VERTICAL)
		self.rightPanel.Add(wx.StaticText(self, label="Animation Options"), 0, wx.EXPAND)
		self.rightPanel.Add(animatePanel, 0, wx.EXPAND)
		playButton = wx.Button(self, -1, "Play")
		self.Bind(wx.EVT_BUTTON, self.glcanvas.startAnimation, playButton)
		animatePanel.Add(playButton, 0, wx.EXPAND)
		#Checkboxes for CAF subsets
		self.TimbreCheckbox = wx.CheckBox(self, label="Timbre")
		self.TimbreCheckbox.SetValue(True)
		self.TimbreCheckbox.Bind(wx.EVT_CHECKBOX, self.ToggleFeature)
		animatePanel.Add(self.TimbreCheckbox)
		self.MFCCCheckbox = wx.CheckBox(self, label="MFCC")
		self.MFCCCheckbox.SetValue(True)
		self.MFCCCheckbox.Bind(wx.EVT_CHECKBOX, self.ToggleFeature)
		animatePanel.Add(self.MFCCCheckbox)
		self.ChromaCheckbox = wx.CheckBox(self, label="Chroma")
		self.ChromaCheckbox.SetValue(True)
		self.ChromaCheckbox.Bind(wx.EVT_CHECKBOX, self.ToggleFeature)
		animatePanel.Add(self.ChromaCheckbox)
		#Song Information
		animatePanel.Add(wx.StaticText(self, label = "Song Information"))
		hbox0 = wx.BoxSizer(wx.HORIZONTAL)
		hbox0.Add(wx.StaticText(self, label = 'Song Name'))
		self.songNameTxt = wx.TextCtrl(self)
		self.songNameTxt.SetValue("None")
		hbox0.Add(self.songNameTxt, flag = wx.LEFT, border = 5)
		animatePanel.Add(hbox0)
		
		hbox1 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox1.Add(wx.StaticText(self, label='Hop Size'))
		self.hopSizeTxt = wx.TextCtrl(self)
		self.hopSizeTxt.SetValue("%i"%self.hopSize)
		hbox1.Add(self.hopSizeTxt, flag=wx.LEFT, border=5)
		animatePanel.Add(hbox1)

		hbox2 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox2.Add(wx.StaticText(self, label='Skip Size'))
		self.skipSizeTxt = wx.TextCtrl(self)
		self.skipSizeTxt.SetValue("%i"%self.skipSize)
		hbox2.Add(self.skipSizeTxt, flag=wx.LEFT, border=5)
		animatePanel.Add(hbox2)
		
		hbox3 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox3.Add(wx.StaticText(self, label='Window Size'))
		self.windowSizeTxt = wx.TextCtrl(self)
		self.windowSizeTxt.SetValue("%i"%self.windowSize)
		hbox3.Add(self.windowSizeTxt, flag=wx.LEFT, border=5)
		animatePanel.Add(hbox3)		
		
		hbox4 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox4.Add(wx.StaticText(self, label='Sample Rate'))
		self.sampleRateTxt = wx.TextCtrl(self)
		self.sampleRateTxt.SetValue("%i"%self.Fs)
		hbox4.Add(self.sampleRateTxt, flag=wx.LEFT, border=5)
		animatePanel.Add(hbox4)				
		
		#Finally add the two main panels to the sizer		
		self.sizer = wx.BoxSizer(wx.HORIZONTAL)
		self.sizer.Add(self.glcanvas, 2, wx.EXPAND)
		self.sizer.Add(self.rightPanel, 0, wx.EXPAND)
		
		self.SetSizer(self.sizer)
		self.Layout()
		self.Show()
	
	def OnLoadSongFile(self, evt):
		dlg = wx.FileDialog(self, "Choose a file", ".", "", "*", wx.OPEN)
		if dlg.ShowModal() == wx.ID_OK:
			filename = dlg.GetFilename()
			dirname = dlg.GetDirectory()
			print "Loading %s...."%filename
			filepath = os.path.join(dirname, filename)
			name, ext = os.path.splitext(filepath)
			#TODO: Replace this ugly subprocess call with some Python
			#library that understand other files
			if ext.upper() != ".WAV":
				command = "avconv -i \"%s\" temp.wav"%filepath
				print command
				if "temp.wav" in set(os.listdir('.')):
					os.remove("temp.wav")
				subprocess.call(["avconv", "-i", filepath, "temp.wav"])
				filepath = "temp.wav"
			s = DelaySeries()
			Fs, X = wavfile.read(filepath)
			self.Fs = Fs
			self.filename = filename
			paramsDlg = DelaySeriesParamsDialog(self)
			paramsDlg.ShowModal()
			paramsDlg.Destroy()
			[self.hopSize, self.skipSize, self.windowSize] = [paramsDlg.hopSize, paramsDlg.skipSize, paramsDlg.windowSize]
			self.soundSamples, self.DelaySeries, self.Fs, self.glcanvas.SampleDelays, self.TimbreIdx, self.MFCCIdx, self.ChromaIdx = s.processFile(filepath, self.hopSize, self.skipSize, self.windowSize)
			self.setupPosVBO()
			self.glcanvas.filename = filepath
			#Setup X colors
			cmConvert = cm.get_cmap('jet')
			self.glcanvas.XColors = cmConvert(np.linspace(0, 1, len(self.glcanvas.SampleDelays) ))[:, 0:3]
			self.glcanvas.XColorsVBO = vbo.VBO(np.array(self.glcanvas.XColors, dtype='float32'))		
			self.glcanvas.camera.centerOnPoints(self.glcanvas.X)
			print "Loaded %s"%filename
			#Update GUI Elements
			self.songNameTxt.SetValue(filename)
			self.hopSizeTxt.SetValue("%i (%g s)"%(self.hopSize, self.hopSize/float(self.Fs)))
			self.skipSizeTxt.SetValue("%i (%g s)"%(self.skipSize, self.skipSize*self.hopSize/float(self.Fs) ))
			self.windowSizeTxt.SetValue("%i (%g s)"%(self.windowSize, self.windowSize*self.hopSize/float(self.Fs) ))
			self.sampleRateTxt.SetValue("%i"%self.Fs)
			self.glcanvas.Refresh()
		dlg.Destroy()
		return

	def OnSaveScreenshot(self, evt):
		dlg = wx.FileDialog(self, "Choose a file", ".", "", "*", wx.SAVE)
		if dlg.ShowModal() == wx.ID_OK:
			filename = dlg.GetFilename()
			dirname = dlg.GetDirectory()
			filepath = os.path.join(dirname, filename)
			saveImageGL(self.glcanvas, filepath)
		dlg.Destroy()
		return

	def OnExit(self, evt):
		self.Close(True)
		return

class LoopDitty(object):
	def __init__(self):
		app = wx.App()
		frame = LoopDittyFrame(None, -1, 'LoopDitty')
		frame.Show(True)
		app.MainLoop()
		app.Destroy()

if __name__ == '__main__':
	app = LoopDitty()
