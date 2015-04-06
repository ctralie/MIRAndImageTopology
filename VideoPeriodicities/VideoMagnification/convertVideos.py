import os

HTML_STR = """
<table border = "1">
<tr><td><h2><a href = '{0}'>{0}</a></h2></td></tr>
<tr><td> DESCRIPTION </td></tr>
<tr><td>
<video controls>
  <source src='{0}' type="video/ogg">
Your browser does not support the video tag.
</video>
</td></tr>
</table><BR><BR>
"""

if __name__ == '__main__':
	files = os.listdir('.')
	thisFiles = {}
	for f in files:
		parts = os.path.splitext(f)
		if parts[-1] == '.avi':
			thisFiles[os.path.getmtime(f)] = f
	
	for key in sorted(thisFiles):
		f = thisFiles[key]
		parts = os.path.splitext(f)
		fnew = "%s.ogg"%parts[0]
		os.popen3("avconv -i %s -b 30000k %s"%(f, fnew))
		print str.format(HTML_STR, fnew)
	

