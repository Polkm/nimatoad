import sdlx, glx, matrix, vector
import entity, parsers

sdlx.init()

var phong = shader("phong.vert", "phong.frag")

var drawStation = mesh("models/station1.ply", phong)
var metalMat = parseBmp("bmps/metal2.bmp")

var trans = identity()
addDraw(model(drawStation, metalMat, phong, trans.addr))
# addDraw(model("models/texturedcube.obj", phong, trans.addr, "bmps/notbadd.bmp"))

# Entity()

let a = rect(10,20,500,450, 0.8,0.2,0.2,1)
let b = orect(10,20,500,450, 0.2,0.2,0.2,1)
let c = trect(50,30,413,397, 1,1,1,1, "bmps/notbadd.bmp")

var panel = screen3d(xPos: 0, yPos : 0, zPos : 0, pitch : 80, yaw : 40, roll : 0)

proc drwFunc() =
  a()
  b()
  c()

# addDraw(makeScreen(panel, drwFunc))
# addDraw(orect(50,30,413,397, 0.2,0.2,0.2,1))

sdlx.run()

sdlx.destroy()
