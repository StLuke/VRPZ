#!/usr/bin/python

import pygame
import sys
import random

pygame.init()

class BouncingSprite(pygame.sprite.Sprite):
	def __init__(self, image, scrWidth, scrHeight, speed=[2,2]):
		pygame.sprite.Sprite.__init__(self)
		self.speed = speed
		self.image = pygame.image.load(image)
		pygame.sprite.LayeredUpdates.move_to_back(self)
		move_to_back(self.image)
		self.rect = self.image.get_rect()
		self.rect.move_ip(random.randint(0, scrWidth - self.rect.x), random.randint(0, scrHeight - self.rect.y))
		self.scrWidth = scrWidth
		self.scrHeight = scrHeight

	def update(self):
		if (self.rect.x < 0) or (self.rect.x > self.scrWidth - self.image.get_rect().width):
			self.speed[0] *= -1
		if (self.rect.y < 0) or (self.rect.y > self.scrHeight - self.image.get_rect().height):
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
		self.label = self.font.render(name, 1, self.fontColor)
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
		self.label = self.font.render(self.name, 1, (255, 0, 0))
		screen.blit(self.itemImage, (self.xpos - 70, self.ypos))

	def removeFocus(self):
		self.label = self.font.render(self.name, 1, self.fontColor)

class IdleScreen():
	def __init__(self, screen):
		self.screen = screen
		self.scrWidth = self.screen.get_rect().width
		self.scrHeight = self.screen.get_rect().height
		self.bgColor = (0, 0, 0)
		self.bgImage = pygame.image.load("../graphics/mainbg.jpg").convert()
		self.clock = pygame.time.Clock()
		self.font = pygame.font.SysFont("Comic Sans MS", 50)
		self.fontColor = (255, 255, 255)
		self.menuItems = list()
		self.itemNames = ("New game", "Quit")
		self.menuFuncs = { 	"New game" : self.startNewGame,
							"Quit" : sys.exit}
		self.animalX = 0
		self.animalY = self.scrHeight - 250
		self.animalAct = None
		self.animalImg = None
		self.animalAngle = 0
		self.animalPictures = ("bison.png", "cow.png", "elephant.png", "giraffe.png", "goat.png", "lion.png",
								"monkey.png", "sheep.png", "vader.png")

	def drawMenu(self):
		self.items = []

		for index, item in enumerate(self.itemNames):
			label = self.font.render(item, 1, self.fontColor)
			width = label.get_rect().width
			height = label.get_rect().height + 30
			posx = (self.scrWidth / 2) - (width / 2)
			totalHeight  = len(self.itemNames) * height
			posy = (self.scrHeight / 2) - (totalHeight / 2) + (index * height)

			mi = MenuItem(item, posx, posy, width, height, self.font, self.fontColor)
			self.menuItems.append(mi)

	def startNewGame(self):
		print "THERE SHOULD BE SOMETHING"

	def run(self):
		screenloop = True
		while screenloop:
			self.clock.tick(30)
			mpos = pygame.mouse.get_pos() 

			self.drawMenu()

			for e in pygame.event.get():
				if e.type == pygame.QUIT:
					screenloop = False
				elif e.type == pygame.MOUSEBUTTONDOWN:
					for item in self.menuItems:
						if item.isMouseSelect(mpos):
							self.menuFuncs[item.name]()
							break;

			self.screen.blit(self.bgImage, (0, 0))

			for item in self.menuItems:
				if item.isMouseSelect(mpos):
					item.applyFocus(self.screen)
				else:
					item.removeFocus()

				self.screen.blit(item.label, (item.xpos, item.ypos))

			self.floatingPicture()
			pygame.display.flip()

	def floatingPicture(self):
		if self.animalImg == None:
			self.animalAct = random.choice(self.animalPictures)
			self.animalImg = BouncingSprite("../graphics/" + self.animalAct, self.scrWidth, self.scrHeight, [5, 5])
			self.animalX = -50;
		else:
			self.animalImg.update()


		self.animalImg.draw(self.screen)


if __name__ == "__main__":
	screen = pygame.display.set_mode((1024, 768), 0, 32)
	pygame.display.set_caption("ZOO")
	idscr = IdleScreen(screen)
	idscr.run()