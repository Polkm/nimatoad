import sdlx, glx, matrix, vector
import gui, mainmenu, parsers, opengl
import ship, entity
import model

sdlx.init()

var phong = initProgram("phong.vert", "phong.frag")
var mat = initMaterial("bmps/metal2.bmp")
var msh = initMesh("models/ship1.obj", phong.handle)

var station = newShip()
station.setPos(vec3(0, 0, -6))
station.program = phong
station.material = mat
station.mesh = msh

addDraw(panelsDraw())
#mainmenu.init()

sdlx.run()

sdlx.destroy()
