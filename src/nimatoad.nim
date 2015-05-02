import sdlx, glx, matrix, vector
import gui, mainmenu, parsers, opengl
import entity, model, ship
import math, camera

sdlx.init()

addDraw(panelsDraw())
mainmenu.init()

sdlx.run()

sdlx.destroy()
