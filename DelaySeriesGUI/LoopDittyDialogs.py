import wx

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

class DensityThresholdDialog(wx.Dialog):
	def __init__(self, *args, **kw):
		super(DensityThresholdDialog, self).__init__(*args, **kw)
		#Remember parameters from last time
		self.densityNeighborsDef = args[0].densityNeighbors
		self.densityNPointsDef = args[0].densityNPoints
		self.lowDensityDef = args[0].lowDensity
		self.InitUI()
		self.SetSize((250, 200))
		self.SetTitle("Density Thresholding Parameters")

	def InitUI(self):
		pnl = wx.Panel(self)
		vbox = wx.BoxSizer(wx.VERTICAL)

		sb = wx.StaticBox(pnl, label='Parameters')
		sbs = wx.StaticBoxSizer(sb, orient=wx.VERTICAL)

		hbox1 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox1.Add(wx.StaticText(pnl, label='Number of Neighbors'))
		self.densityNeighbors = wx.TextCtrl(pnl)
		self.densityNeighbors.SetValue("%s"%self.densityNeighborsDef)
		hbox1.Add(self.densityNeighbors, flag=wx.LEFT, border=5)
		sbs.Add(hbox1)

		hbox2 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox2.Add(wx.StaticText(pnl, label='Number of Points'))
		self.densityNPoints = wx.TextCtrl(pnl)
		self.densityNPoints.SetValue("%s"%self.densityNPointsDef)
		hbox2.Add(self.densityNPoints, flag=wx.LEFT, border=5)
		sbs.Add(hbox2)

		self.lowDensity = wx.CheckBox(self, label="Low Density")
		self.lowDensity.SetValue(self.lowDensityDef)
		vbox.Add(self.lowDensity)

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
		self.densityNeighbors = int(self.densityNeighbors.GetValue())
		self.densityNPoints = int(self.densityNPoints.GetValue())
		self.lowDensity = self.lowDensity.GetValue()
		self.Destroy()

class HKSDialog(wx.Dialog):
	def __init__(self, *args, **kw):
		super(HKSDialog, self).__init__(*args, **kw)
		#Remember parameters from last time
		self.hksNEigsDef = args[0].hksNEigs
		self.hksTimeDef = args[0].hksTime
		self.InitUI()
		self.SetSize((250, 200))
		self.SetTitle("Heat Kernel Signature Parameters")


	def InitUI(self):
		pnl = wx.Panel(self)
		vbox = wx.BoxSizer(wx.VERTICAL)

		sb = wx.StaticBox(pnl, label='Parameters')
		sbs = wx.StaticBoxSizer(sb, orient=wx.VERTICAL)

		hbox1 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox1.Add(wx.StaticText(pnl, label='Number of Eigenvalues'))
		self.hksNEigs = wx.TextCtrl(pnl)
		self.hksNEigs.SetValue("%i"%self.hksNEigsDef)
		hbox1.Add(self.hksNEigs, flag=wx.LEFT, border=5)
		sbs.Add(hbox1)

		hbox2 = wx.BoxSizer(wx.HORIZONTAL)        
		hbox2.Add(wx.StaticText(pnl, label='Diffusion Time'))
		self.hksTime = wx.TextCtrl(pnl)
		self.hksTime.SetValue("%g"%self.hksTimeDef)
		hbox2.Add(self.hksTime, flag=wx.LEFT, border=5)
		sbs.Add(hbox2)

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
		self.hksNEigs = int(self.hksNEigs.GetValue())
		self.hksTime = float(self.hksTime.GetValue())
		self.Destroy()


