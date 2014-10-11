from freenect import sync_get_depth as get_depth #Uses freenect to get depth information from the Kinect
import numpy as np #Imports NumPy
import cv,cv2 #Uses both of cv and cv2
import pygame #Uses pygame
import sys
import time
import random
import os

#The libaries below are used for mouse manipulation
from Xlib import X, display
import Xlib.XK
import Xlib.error
import Xlib.ext.xtest

constList = lambda length, val: [val for _ in range(length)] #Gives a list of size length filled with the variable val. length is a list and val is dynamic

class BouncingSprite(pygame.sprite.Sprite):
	def __init__(self, image, scrWidth, scrHeight, speed=[2,2]):
		pygame.sprite.Sprite.__init__(self)
		self.speed = speed
		self.image = pygame.image.load(image)
		self.rect = self.image.get_rect()
		self.rect.move_ip(random.randint(0, scrWidth - self.rect.width), random.randint(0, scrHeight - self.rect.height))
		self.scrWidth = scrWidth
		self.scrHeight = scrHeight

	def update(self):
		if (self.rect.x < 0) or (self.rect.x > self.scrWidth - self.rect.width):
			self.speed[0] *= -1
		if (self.rect.y < 0) or (self.rect.y > self.scrHeight - self.rect.height):
			self.speed[1] *= -1

		self.rect.x = self.rect.x + self.speed[0]
		self.rect.y = self.rect.y + self.speed[1]

	def draw(self, screen):
		screen.blit(self.image, self.rect)

class MenuItem(pygame.font.Font):
	def __init__(self, name, xpos, ypos, width, height, font, fontColor):
		self.name = name
		self.xpos = xpos
		self.ypos = ypos
		self.width = width
		self.height = height
		self.font = font
		self.fontColor = fontColor
		self.label = pygame.transform.flip(self.font.render(self.name, 1, self.fontColor), 1, 0)
		self.itemImage = pygame.image.load("../graphics/menuico.png").convert()
		self.itemImage.set_colorkey((255, 255, 255))

	def getName(self):
		return self.name

	def getXPos(self):
		return self.xpos

	def getYPos(self):
		return self.ypos

	def changeColor(self, color):
		self.fontColor = color
		self.label = self.font.render(self.name, 1, color)

	def isMouseSelect(self, (xpos, ypos)):
		if(xpos >= self.xpos and xpos <= self.xpos + self.width) and \
			(ypos >= self.ypos and ypos <= self.ypos + self.height):
				return True
		
		return False

	def applyFocus(self, screen):
		self.label = pygame.transform.flip(self.font.render(self.name, 1, (255, 0, 0)), 1, 0)
		self.label = pygame.transform.smoothscale(self.label, (self.width + 25, self.height + 25))
		screen.blit(self.itemImage, (self.xpos - 70, self.ypos + 25))

	def removeFocus(self):
		self.label = pygame.transform.flip(self.font.render(self.name, 1, self.fontColor), 1, 0)
		self.label = pygame.transform.smoothscale(self.label, (self.width, self.height))

class IdleScreen():
	def __init__(self, screen):
		pygame.init()
		self.screen = screen
		self.scrWidth = self.screen.get_rect().width
		self.scrHeight = self.screen.get_rect().height
		self.bgColor = (0, 0, 0)
		self.bgImage = pygame.transform.flip(pygame.image.load("../graphics/mainbg.jpg").convert(), 1, 0)
		self.clock = pygame.time.Clock()
		self.font = pygame.font.SysFont("LDFComicSans", 60)
		self.fontColor = (255, 255, 255)
		self.menuItems = list()
		self.itemNames = ("New game", "Quit")
		self.menuFuncs = {  "New game" : self.startNewGame,
							"Quit" : sys.exit}
		self.animalImgs = []
		self.animalPictures = ["bison.png", "elephant.png", "giraffe.png", "goat.png", "lion.png",
								"monkey.png", "sheep.png"]

	def buildMenu(self):
		self.items = []

		for index, item in enumerate(self.itemNames):
			label = pygame.transform.flip(self.font.render(item, 1, self.fontColor), 1, 0)
			#abel = self.font.render(item, 1, self.fontColor)
			width = label.get_rect().width
			height = label.get_rect().height + 30
			posx = (self.scrWidth / 2) - (width / 2)
			totalHeight  = len(self.itemNames) * height
			posy = (self.scrHeight / 2) - (totalHeight / 2) + (index * height)

			mi = MenuItem(item, posx, posy, width, height, self.font, self.fontColor)
			self.menuItems.append(mi)

	def startNewGame(self):
		sys.exit(1)

	def run(self):
		screenloop = True
		(depth,_) = get_depth()
		cHullAreaCache = constList(5,12000) #Blank cache list for convex hull area
		areaRatioCache = constList(5,1) #Blank cache list for the area ratio of contour area to convex hull area
		centroidList = list() #Initiate centroid list
		#RGB Color tuples
		BLACK = (0,0,0)
		RED = (255,0,0)
		GREEN = (0,255,0)
		PURPLE = (255,0,255)
		BLUE = (0,0,255)
		WHITE = (255,255,255)
		YELLOW = (255,255,0)
		screenFlipped = pygame.display.set_mode((self.scrWidth, self.scrHeight), 0, 32)
		done = False #Iterator boolean --> Tells programw when to terminate
		dummy = False #Very important bool for mouse manipulation
		self.buildMenu()

		while screenloop:
			self.clock.tick(30)
			(depth,_) = get_depth() #Get the depth from the kinect 
			old_depth = depth
			depth = cv2.resize(old_depth, (1024, 768))
			depth = depth.astype(np.float32) #Convert the depth to a 32 bit float
			_,depthThresh = cv2.threshold(depth, 600, 255, cv2.THRESH_BINARY_INV) #Threshold the depth for a binary image. Thresholded at 600 arbitary units
			_,back = cv2.threshold(depth, 900, 255, cv2.THRESH_BINARY_INV) #Threshold the background in order to have an outlined background and segmented foreground
			blobData = BlobAnalysis(depthThresh) #Creates blobData object using BlobAnalysis class
			blobDataBack = BlobAnalysis(back) #Creates blobDataBack object using BlobAnalysis class
			
			mpos = pygame.mouse.get_pos() 

			for e in pygame.event.get():
				if e.type == pygame.QUIT:
					screenloop = False
				elif e.type == pygame.MOUSEBUTTONDOWN:
					for item in self.menuItems:
						if item.isMouseSelect(mpos):
							screenloop = self.menuFuncs[item.name]()
							break;

			self.screen.blit(self.bgImage, (0, 0))
			self.floatingPicture()

			for item in self.menuItems:
				if item.isMouseSelect(mpos):
					item.applyFocus(self.screen)
				else:
					item.removeFocus()

				self.screen.blit(item.label, (item.xpos, item.ypos))

			"""
			maxTip = [0, 1000]
			
			for cont in blobDataBack.contours: #Iterates through contours in the background
				pygame.draw.lines(screen,YELLOW,True,cont,3) #Colors the binary boundaries of the background yellow
			for i in range(blobData.counter): #Iterate from 0 to the number of blobs minus 1
				pygame.draw.circle(screen,BLUE,blobData.centroid[i],10) #Draws a blue circle at each centroid
				centroidList.append(blobData.centroid[i]) #Adds the centroid tuple to the centroidList --> used for drawing
				pygame.draw.lines(screen,RED,True,blobData.cHull[i],3) #Draws the convex hull for each blob
				pygame.draw.lines(screen,GREEN,True,blobData.contours[i],3) #Draws the contour of each blob
		
				for tips in blobData.cHull[i]: #Iterates through the verticies of the convex hull for each blob
					if tips[1] < maxTip[1]:
						maxTip = tips
					#pygame.draw.circle(screen,PURPLE,tips,5) #Draws the vertices purple
			"""
			del depth #Deletes depth --> opencv memory issue
			screenFlipped = pygame.transform.flip(screen,1,0) #Flips the screen so that it is a mirror display
			screen.blit(screenFlipped,(0,0)) #Updates the main screen --> screen
			pygame.display.flip() #Updates everything on the window
			
			#Mouse Try statement
			try:
				centroidX = blobData.centroid[0][0]
				centroidY = blobData.centroid[0][1]
				if dummy:
					mousePtr = display.Display().screen().root.query_pointer()._data #Gets current mouse attributes
					#displayRes = display.Display().screen().root.get_geometry()
					dX = centroidX - strX #Finds the change in X
					dY = strY - centroidY #Finds the change in Y
					#print "Display Res ", displayRes
					#print "Centroid Res ", blobData.centroid[0] 
					
					minChange = 6
					if abs(dX) > minChange: #If there was a change in X greater than 1...
						mouseX = mousePtr["root_x"] - 2*dX #New X coordinate of mouse
						if mouseX < 0:
							mouseX = 0
						elif mouseX > self.scrWidth:
							mouseX = self.scrWidth
					if abs(dY) > minChange: #If there was a change in Y greater than 1...
						mouseY = mousePtr["root_y"] - 2*dY #New Y coordinate of mouse
						if mouseY < 0:
							mouseY = 0
						elif mouseY > self.scrHeight:
							mouseY = self.scrHeight
				
					#print "Mouse coords: ", mouseX, mouseY
					#print "maxTip ", maxTip
					move_mouse(mouseX,mouseY) #Moves mouse to new location
					#widthHalf = displayRes.width / 2
					#mouseX = widthHalf - (maxTip[0] - widthHalf) if maxTip[0] > widthHalf else displayRes.width - maxTip[0]
					#mouseY = maxTip[1]
					#move_mouse(mouseX, mouseY)
					strX = centroidX #Makes the new starting X of mouse to current X of newest centroid
					strY = centroidY #Makes the new starting Y of mouse to current Y of newest centroid
					cArea = cacheAppendMean(cHullAreaCache,blobData.cHullArea[0]) #Normalizes (gets rid of noise) in the convex hull area
					areaRatio = cacheAppendMean(areaRatioCache, blobData.contourArea[0]/cArea) #Normalizes the ratio between the contour area and convex hull area
					print cArea, areaRatio, "(Must be: < 1000, > 0.82)"
					if cArea < 25000 and areaRatio > 0.82: #Defines what a click down is. Area must be small and the hand must look like a binary circle (nearly)
						click_down(1)
					else:
						click_up(1)
				else:
					strX = centroidX #Initializes the starting X
					strY = centroidY #Initializes the starting Y
					dummy = True #Lets the function continue to the first part of the if statement
			except: #There may be no centroids and therefore blobData.centroid[0] will be out of range
				dummy = False #Waits for a new starting point

	def floatingPicture(self):
		self.animalAct = None

		if self.animalImgs == []:
			for i in range(0, 3):
				self.animalAct = self.animalPictures.pop(random.randrange(len(self.animalPictures)))
				self.animalImgs.append(BouncingSprite("../graphics/" + self.animalAct, self.scrWidth, self.scrHeight, [3, 3]))
		else:
			for img in self.animalImgs:
				img.update()

		for img in self.animalImgs:
			img.draw(self.screen)

"""
This class is a less extensive form of regionprops() developed by MATLAB. 
It finds properties of contours and sets them to fields
"""
class BlobAnalysis:
	def __init__(self,BW): #Constructor. BW is a binary image in the form of a numpy array
		self.BW = BW
		cs = cv.FindContours(cv.fromarray(self.BW.astype(np.uint8)),cv.CreateMemStorage(),mode = cv.CV_RETR_EXTERNAL) #Finds the contours
		counter = 0
		"""
		These are dynamic lists used to store variables
		"""
		centroid = list()
		cHull = list()
		contours = list()
		cHullArea = list()
		contourArea = list()
		while cs: #Iterate through the CvSeq, cs.
			if abs(cv.ContourArea(cs)) > 5000: #Filters out contours smaller than 2000 pixels in area
				contourArea.append(cv.ContourArea(cs)) #Appends contourArea with newest contour area
				m = cv.Moments(cs) #Finds all of the moments of the filtered contour
				try:
					m10 = int(cv.GetSpatialMoment(m,1,0)) #Spatial moment m10
					m00 = int(cv.GetSpatialMoment(m,0,0)) #Spatial moment m00
					m01 = int(cv.GetSpatialMoment(m,0,1)) #Spatial moment m01
					centroid.append((int(m10/m00), int(m01/m00))) #Appends centroid list with newest coordinates of centroid of contour
					convexHull = cv.ConvexHull2(cs,cv.CreateMemStorage(),return_points=True) #Finds the convex hull of cs in type CvSeq
					cHullArea.append(cv.ContourArea(convexHull)) #Adds the area of the convex hull to cHullArea list
					cHull.append(list(convexHull)) #Adds the list form of the convex hull to cHull list
					contours.append(list(cs)) #Adds the list form of the contour to contours list
					counter += 1 #Adds to the counter to see how many blobs are there
				except:
					pass
			cs = cs.h_next() #Goes to next contour in cs CvSeq
		"""
		Below the variables are made into fields for referencing later
		"""
		self.centroid = centroid
		self.counter = counter
		self.cHull = cHull
		self.contours = contours
		self.cHullArea = cHullArea
		self.contourArea = contourArea

d = display.Display() #Display reference for Xlib manipulation
def move_mouse(x,y):#Moves the mouse to (x,y). x and y are ints
	print "Moving mouse to: ", x, y
	s = d.screen()
	root = s.root
	root.warp_pointer(x,y)
	d.sync()
	
def click_down(button):#Simulates a down click. Button is an int
	print "GOT CLICK DOWN"
	Xlib.ext.xtest.fake_input(d,X.ButtonPress, button)
	d.sync()
	
def click_up(button): #Simulates a up click. Button is an int
	print "GOT CLICK UP"
	Xlib.ext.xtest.fake_input(d,X.ButtonRelease, button)
	d.sync()

"""
The function below is a basic mean filter. It appends a cache list and takes the mean of it.
It is useful for filtering noisy data
cache is a list of floats or ints and val is either a float or an int
it returns the filtered mean
"""
def cacheAppendMean(cache, val):
	cache.append(val)
	del cache[0]
	return np.mean(cache)

"""
This is the GUI that displays the thresholded image with the convex hull and centroids. It uses pygame.
Mouse control is also dictated in this function because the mouse commands are updated as the frame is updated
"""

if __name__ == "__main__":
	screen = pygame.display.set_mode((1024, 768), 0, 32)
	pygame.display.set_caption("ZOO")
	idscr = IdleScreen(screen)
	try: 
		idscr.run()
	except Exception, e:
		print "Something's wrong: %s" % e
		