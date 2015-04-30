import sdlx, glx, matrix, vector
import gui, mainmenu, parsers, opengl
import model


sdlx.init()

var phong = initProgram("phong.vert", "phong.frag")
var mat = initMaterial("bmps/metal2.bmp")
var msh = initMesh("models/ship1.obj", phong.handle)


var station = newModel()
station.matrix = station.matrix.translate(vec3(0, 0, -6))
# station.matrix = station.matrix.rotate(60, vec3(0, 0, 1))
station.program = phong
station.material = mat
station.mesh = msh

addDraw(panelsDraw())
mainmenu.init()

sdlx.run()

sdlx.destroy()
