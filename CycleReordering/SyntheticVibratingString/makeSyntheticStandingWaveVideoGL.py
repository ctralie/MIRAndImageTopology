#Create a synthetic standing wave video using PyOpenGL
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *
from OpenGL.arrays import vbo
from OpenGL.GL import shaders
import wx
from wx import glcanvas

from sys import exit, argv
import numpy as np
import matplotlib.pyplot as plt
import scipy.io as sio
import scipy.spatial as spatial
from pylab import cm
import os
import math
import time

DEFAULT_SIZE = wx.Size(400, 200)
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


class LoopDittyCanvas(glcanvas.GLCanvas):
    def __init__(self, parent):
        attribs = (glcanvas.WX_GL_RGBA, glcanvas.WX_GL_DOUBLEBUFFER, glcanvas.WX_GL_DEPTH_SIZE, 24)
        glcanvas.GLCanvas.__init__(self, parent, -1, attribList = attribs)    
        self.context = glcanvas.GLContext(self)
        
        self.parent = parent
        #Camera state variables
        self.size = self.GetClientSize()

        self.DrawEdges = True
        
        #Animation state variables
        self.tidx = 0
        self.Playing = False
        
        #Vibrating string variables
        NHarmonics = 10
        NSamples = 1000
        Amplitude = 1
        self.x = np.linspace(-1, 1, NSamples)
        #y holds the wave at its full extension
        y = np.zeros(NSamples)
        for h in range(1, NHarmonics+1):
            y = y + (1/np.exp(h))*np.sin(np.pi*h*(self.x+1)/2);
        self.y = Amplitude*y
        NPeriods = 50
        SamplesPerPeriod = 10
        self.t = np.linspace(0, 2*np.pi*NPeriods, NPeriods*SamplesPerPeriod)
        
        self.GLinitialized = False
        #GL-related events
        wx.EVT_ERASE_BACKGROUND(self, self.processEraseBackgroundEvent)
        wx.EVT_SIZE(self, self.processSizeEvent)
        wx.EVT_PAINT(self, self.processPaintEvent)    

    
    def processEraseBackgroundEvent(self, event): pass #avoid flashing on MSW.

    def processSizeEvent(self, event):
        self.size = self.GetClientSize()
        self.SetCurrent(self.context)
        glViewport(0, 0, self.size.width, self.size.height)


    def processPaintEvent(self, event):
        dc = wx.PaintDC(self)
        self.SetCurrent(self.context)
        if not self.GLinitialized:
            self.initGL()
            self.GLinitialized = True
        self.repaint()
    
    def startAnimation(self, evt):
        self.tidx = 0
        self.Playing = True
        self.Refresh()

    def repaint(self):
        #Set up modelview matrix
        glClearColor(1.0, 1.0, 1.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        glDisable(GL_LIGHTING)
        glColor3f(0, 0, 0)
        glLineWidth(2)
        
        wave = np.cos(self.t[self.tidx])*self.y
        
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()

        #Do this the slow way without vertex buffers because I'm lazy
        glBegin(GL_LINES)
        for i in range(wave.size - 1):
            glVertex2f(self.x[i], wave[i])
            glVertex2f(self.x[i+1], wave[i+1])
        glEnd()
        self.SwapBuffers()
        if self.Playing:
            saveImageGL(self, "%i.png"%self.tidx)
            self.tidx += 1
            self.Refresh()
    
    def initGL(self):        
        glutInit('')
        glEnable(GL_NORMALIZE)
        glEnable(GL_DEPTH_TEST)

class LoopDittyFrame(wx.Frame):
    def __init__(self, parent, id, title, pos=DEFAULT_POS, size=DEFAULT_SIZE, style=wx.DEFAULT_FRAME_STYLE, name = 'GLWindow'):
        style = style | wx.NO_FULL_REPAINT_ON_RESIZE
        super(LoopDittyFrame, self).__init__(parent, id, title, pos, size, style, name)
        #Initialize the menu
        self.CreateStatusBar()
        
        self.size = size
        self.pos = pos
        
        self.glcanvas = LoopDittyCanvas(self)
        glCanvasSizer = wx.BoxSizer(wx.VERTICAL)
        glCanvasSizer.Add(self.glcanvas, 2, wx.EXPAND)
        
        self.rightPanel = wx.BoxSizer(wx.VERTICAL)
        
        #Buttons to go to a default view
        animatePanel = wx.BoxSizer(wx.VERTICAL)
        self.rightPanel.Add(wx.StaticText(self, label="Animation Options"), 0, wx.EXPAND)
        self.rightPanel.Add(animatePanel, 0, wx.EXPAND)
        playButton = wx.Button(self, -1, "Play")
        self.Bind(wx.EVT_BUTTON, self.glcanvas.startAnimation, playButton)
        animatePanel.Add(playButton, 0, wx.EXPAND)
        
        #Finally add the two main panels to the sizer
        self.sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.sizer.Add(glCanvasSizer, 2, wx.EXPAND)
        self.sizer.Add(self.rightPanel, 0, wx.EXPAND)
        
        self.SetSizer(self.sizer)
        self.Layout()
        self.Show()

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
