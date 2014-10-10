#!/usr/bin/python

import pygame

pygame.init()

class IdleScreen():
	def __init__(self, screen, bgc = (0, 0, 0)):
		self.screen = screen
		self.bgc = bgc
		self.clock = pygame.time.Clock()

	def run(self):
		screenloop = True
		while screenloop:
			self.clock.tick(40)

			for e in pygame.event.get():
				if e.type == pygame.QUIT:
					screenloop = False

			self.screen.fill(self.bgc)
			pygame.display.flip()

if __name__ == "__main__":
	screen = pygame.display.set_mode((1024, 768), 0, 32)
	pygame.display.set_caption("ZOO")
	idscr = IdleScreen(screen)
	idscr.run()