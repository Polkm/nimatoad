import entity, model, ship
import vector, matrix
import math, glx, camera

var playerShip*: Ship

proc controlInput*(binding, action: string) =
  var dir = vec3(0, 0, 0)

  case binding
  of "forward": playerShip.throttling = action == "start"
  of "back": playerShip.reverse = action == "start"
  of "left": playerShip.lefting = action == "start"
  of "right": playerShip.righting = action == "start"
  of "up": playerShip.upping = action == "start"
  of "down": playerShip.downing = action == "start"


proc init*() =
  var phong = initProgram("phong.vert", "phong.frag")
  var mat = initMaterial("bmps/metal2.bmp")
  var msh = initMesh("models/ship1.obj", phong.handle)

  var skydome = newModel()
  skydome.program = initProgram("phong.vert", "sky.frag")
  skydome.mesh = initMesh("models/skydome.obj", phong.handle)
  skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
  skydome.setScale(vec3(2000))

  var star = newModel()
  star.program = initProgram("phong.vert", "sky.frag")
  star.mesh = initMesh("models/sphere1.obj", phong.handle)
  star.material = initMaterial("bmps/star.bmp", "bmps/star.bmp")
  star.setScale(vec3(20))

  playerShip = newShip()
  playerShip.setPos(vec3(50, 3, -12))
  playerShip.program = phong
  playerShip.material = mat
  playerShip.mesh = msh
  camera.driver = playerShip

  let meshes = @[
    initMesh("models/astroid1.obj", phong.handle),
    initMesh("models/astroid2.obj", phong.handle)
  ]
  let mats = @[
    initMaterial("bmps/rock1.bmp"),
    initMaterial("bmps/rock2.bmp")
  ]

  for i in 1..200:
    var astroid = newModel()
    let theta = random(0.0..(PI * 2))
    let dist = random(40.0..500.0)
    astroid.setPos(vec3(cos(theta) * dist, random(-10.0..10.0), sin(theta) * dist))
    astroid.setAngle(vec3(random(0.0..360.0), random(0.0..360.0), random(0.0..360.0)))
    astroid.setAngleVel(vec3(random(0.0..5.0)))
    astroid.setScale(vec3(random(0.5..3.0)))
    astroid.program = phong
    astroid.material = mats[random(0..2)]
    astroid.mesh = meshes[random(0..2)]

  let stationMeshes = @[
    initMesh("models/station1.ply", phong.handle),
    initMesh("models/rings1.obj", phong.handle)
  ]
  for i in 1..3:
    var station = newModel()
    let theta = random(0.0..(PI * 2))
    let dist = random(100.0..600.0)
    station.setPos(vec3(cos(theta) * dist, random(-10.0..10.0), sin(theta) * dist))
    station.setAngleVel(vec3(0.0, 2.0, 0))
    station.setScale(vec3(20.0))
    station.program = phong
    station.material = mat
    station.mesh = stationMeshes[random(0..2)]

proc update*(dt: float) =
  for ent in entities:
    ent.update(dt)
