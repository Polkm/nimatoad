import sdlx, glx, matrix, vector
import gui, mainmenu, parsers, opengl
import entity, model, ship
import math

sdlx.init()

var phong = initProgram("phong.vert", "phong.frag")
var mat = initMaterial("bmps/metal2.bmp")
var msh = initMesh("models/ship1.obj", phong.handle)

var skydome = newModel()
skydome.program = initProgram("phong.vert", "sky.frag")
skydome.mesh = initMesh("models/skydome.obj", phong.handle)
skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
skydome.setScale(vec3(2000))

var station = newShip()
station.setPos(vec3(0, 0, -6))
station.program = phong
station.material = mat
station.mesh = msh

var shp = newShip()
shp.setPos(vec3(0, 3, -12))
shp.program = phong
shp.material = mat
shp.mesh = msh

let rock1Mat = initMaterial("bmps/rock1.bmp")
let rock2Mat = initMaterial("bmps/rock2.bmp")
let astroid1Mesh = initMesh("models/astroid1.obj", phong.handle)
let astroid2Mesh = initMesh("models/astroid2.obj", phong.handle)

for i in 1..50:
  var astroid = newModel()
  astroid.setPos(vec3(random(-100.0..100.0), random(-10.0..10.0), random(-100.0..100.0)))
  astroid.setAngle(vec3(random(0.0..360.0), random(0.0..360.0), random(0.0..360.0)))
  astroid.setScale(vec3(random(0.5..3.0)))
  astroid.program = phong
  astroid.material = rock1Mat
  astroid.mesh = astroid1Mesh



addDraw(panelsDraw())
mainmenu.init()

sdlx.run()

sdlx.destroy()
