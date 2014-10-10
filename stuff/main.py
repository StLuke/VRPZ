#!/usr/bin/python

import pygame

pygame.init()

class IdleScreen():
	def __init__(self, screen):
		self.screen = screen
		self.scrWidth = self.screen.get_rect().width
		self.scrHeight = self.screen.get_rect().height
		self.bgColor = (0, 0, 0)
		self.bgImage = pygame.image.load("mainbg.jpg").convert()
		self.clock = pygame.time.Clock()
		self.font = pygame.font.SysFont("Comic Sans MS", 50)
		self.fontColor = (255, 255, 255)
		self.menuItems = ("New game", "Exit")

	def drawMenu(self):
		self.items = []

		for index, item in enumerate(self.menuItems):
			label = self.font.render(item, 1, self.fontColor)
			width = label.get_rect().width
			height = label.get_rect().height + 30
			posx = (self.scrWidth / 2) - (width / 2)
			totalHeight  = len(self.menuItems) * height
			posy = (self.scrHeight / 2) - (totalHeight / 2) + (index * height)

			if self.isMouseSelected((posx, posy), pygame.mouse.get_pos(), width, height):
				label = self.font.render(item, 1, (255, 0, 0))
			else:
				label = self.font.render(item, 1, self.fontColor)

			self.screen.blit(label, (posx, posy))

	def isMouseSelected(self, (itemx, itemy), (mousex, mousey), w, h):
		if(mousex >= itemx and mousex <= itemx + w) and \
			(mousey >= itemy and mousey <= itemy + h):
				return True
		
		return False

	def run(self):
		screenloop = True
		while screenloop:
			self.clock.tick(40)

			for e in pygame.event.get():
				if e.type == pygame.QUIT:
					screenloop = False

			#self.screen.fill(self.bgColor)
			self.screen.blit(self.bgImage, (0, 0))
			# Draw menu
			self.drawMenu()
			pygame.display.flip()


class MenuItem(pygame.font.Font):
	def __init__(self, arg):
		super(MenuItem, self).__init__()
		self.arg = arg
		
if __name__ == "__main__":
	screen = pygame.display.set_mode((1024, 768), 0, 32)
	pygame.display.set_caption("ZOO")
	idscr = IdleScreen(screen)
	idscr.run()