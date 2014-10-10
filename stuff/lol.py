#!/usr/bin/env python

from freenect import sync_get_depth as get_depth #Uses freenect to get depth information from the Kinect
import numpy as np #Imports NumPy
import cv,cv2 #Uses both of cv and cv2
import pygame #Uses pygame
import sys
import socket


smoothing = 5
constList = lambda length, val: [val for _ in range(length)] #Gives a list of size length filled with the variable val. length is a list and val is dynamic

"""
This class is a less extensive form of regionprops() developed by MATLAB. It finds properties of contours and sets them to fields
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
            if abs(cv.ContourArea(cs)) > 2000: #Filters out contours smaller than 2000 pixels in area
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


def in_hull(p, hull):
    """
    Test if points in `p` are in `hull`

    `p` should be a `NxK` coordinates of `N` points in `K` dimension
    `hull` is either a scipy.spatial.Delaunay object or the `MxK` array of the 
    coordinates of `M` points in `K`dimension for which a Delaunay triangulation
    will be computed
    """
    from scipy.spatial import Delaunay
    if not isinstance(hull,Delaunay):
        hull = Delaunay(hull)

    return hull.find_simplex(p)>=0


s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('', 5005))
s.setblocking(0)
data =''
address = ''

def hand_tracker():
    (depth,_) = get_depth()
    centroidList = list() #Initiate centroid list
    #RGB Color tuples
    BLACK = (0,0,0)
    RED = (255,0,0)
    GREEN = (0,255,0)
    PURPLE = (255,0,255)
    BLUE = (0,0,255)
    WHITE = (255,255,255)
    YELLOW = (255,255,0)
    pygame.init() #Initiates pygame
    xSize,ySize = 1024,768 #Sets size of window
    WIDTH,HEIGHT = xSize,ySize
    screen = pygame.display.set_mode((xSize,ySize),pygame.RESIZABLE) #creates main surface
    screenFlipped = pygame.display.set_mode((xSize,ySize),pygame.RESIZABLE) #creates surface that will be flipped (mirror display)
    screen.fill(BLACK) #Make the window black
    done = False #Iterator boolean --> Tells programw when to terminate


    # HOLY COW!!
    scale = 1.0
    imgCow = pygame.image.load('../graphics/' +sys.argv[1]+'.png')
    cowW, cowH = imgCow.get_size()
    imgCow = pygame.transform.scale(imgCow, (int(cowW * scale), int(cowH * scale)))
    smoothVector = list()
    maxCont = (0, 1000)

    
    while not done:
        try:
            data,address = s.recvfrom(10000)
            print "recv:", data, " from:", address
            if data == "ping":
                s.sendto("ready", address)
            if 'ksicht' in data:
                print "Menim ksicht"
                imgCow = pygame.image.load('../graphics/' + data.replace('ksicht:', ''))
                cowW, cowH = imgCow.get_size()
                imgCow = pygame.transform.scale(imgCow, (int(cowW * scale), int(cowH * scale)))
            if 'zbran' in data:
                print "Menim zbran"
            if ";" in data:
                # Suradnice
                try:
                    x,y,z = data.split(';')
                    print x, " ", y, " ", z
                except Exception as e:
                    print "Suradnice: ", e

        except Exception as e:
            pass

        screen.fill(BLACK) #Make the window black
        (depth,_) = get_depth() #Get the depth from the kinect
        depth = depth.astype(np.float32) #Convert the depth to a 32 bit float
        _,depthThresh = cv2.threshold(depth, 650, 255, cv2.THRESH_BINARY_INV) #Threshold the depth for a binary image. Thresholded at 600 arbitary units
        _,back = cv2.threshold(depth, 900, 255, cv2.THRESH_BINARY_INV) #Threshold the background in order to have an outlined background and segmented foreground
        blobData = BlobAnalysis(depthThresh) #Creates blobData object using BlobAnalysis class
        blobDataBack = BlobAnalysis(back) #Creates blobDataBack object using BlobAnalysis class

        # Boundaries
        hullBound = []
        for i in range(blobData.counter):
            hullLeft = 1000
            hullRight = 0
            for x,y in blobData.cHull[i]:
                if x < hullLeft:
                    hullLeft = x
                if x > hullRight:
                    hullRight = x
            hullBound.append([hullRight, hullLeft])


        tempCont = []
        for cont in blobDataBack.contours: #Iterates through contours in the background
            pygame.draw.lines(screen,YELLOW,True,cont,3) #Colors the binary boundaries of the background yellow

            for xcont,ycont in cont:
                valid = True
                for bound in hullBound:
                    if xcont <= bound[0] and xcont >= bound[1]:
                        # in Hull boundaries
                        valid = False
                if valid:
                    tempCont.append([xcont, ycont])




        maxCont = (0, 1000)

        #print tempCont
        for coords in tempCont:
            #print coords
            if coords[1] < maxCont[1]:
                maxCont = coords

        smoothVector.append(maxCont)
        if len(smoothVector) > smoothing:
            smoothVector.pop(0)

        mean = [0, 0]
        for val in smoothVector:
            mean[0] = mean[0]+val[0]
            mean[1] = mean[1]+val[1]

        mean[0]=int(mean[0]/len(smoothVector))
        mean[1]=int(mean[1]/len(smoothVector))

        xcord = mean[0] - (imgCow.get_rect().size[0]/2)
        ycord = mean[1] - (imgCow.get_rect().size[1]/2)

        # Hlava?
        screen.blit(imgCow, (xcord, ycord+65))

        for i in range(blobData.counter): #Iterate from 0 to the number of blobs minus 1

            #pygame.draw.circle(screen,BLUE,blobData.centroid[i],10) #Draws a blue circle at each centroid

            centroidList.append(blobData.centroid[i]) #Adds the centroid tuple to the centroidList --> used for drawing
            #pygame.draw.lines(screen,RED,True,blobData.cHull[i],3) #Draws the convex hull for each blob
            pygame.draw.lines(screen,GREEN,True,blobData.contours[i],3) #Draws the contour of each blob
            mostLeft = (xSize, 0)
            mostRight = (0, 0)

            # Body ruky
            for tips in blobData.cHull[i]: #Iterates through the verticies of the convex hull for each blob
                #pygame.draw.circle(screen,PURPLE,tips,5) #Draws the vertices purple

                if tips[0] < mostLeft[0]:
                    mostLeft = tips
                if tips[0] > mostRight[0]:
                    mostRight = tips

            # Centrum ruky
            pygame.draw.circle(screen,WHITE,blobData.centroid[i],30)

        pygame.display.set_caption('ZOO') #Makes the caption of the pygame screen 'Kinect Tracking'
        del depth #Deletes depth --> opencv memory issue
        screenFlipped = pygame.transform.flip(screen,1,0) #Flips the screen so that it is a mirror display
        screen.blit(screenFlipped,(0,0)) #Updates the main screen --> screen
        pygame.display.flip() #Updates everything on the window

        for e in pygame.event.get(): #Itertates through current events
            if e.type is pygame.QUIT: #If the close button is pressed, the while loop ends
                done = True

try: #Kinect may not be plugged in --> weird erros
    #hand_tracker()
    pass
except: #Lets the libfreenect errors be shown instead of python ones
    pass

hand_tracker()
