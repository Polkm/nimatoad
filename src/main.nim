import sdlx, glx, matrix, vector

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
var trans = identity()
# var trans = lookat(eye = vec3(0, -2, 0), target = vec3(0, -100, 100), up = vec3(0, 1, 0))
addDraw(model("models/texturedcube.obj", shdr, trans.addr, "bmps/metal1.bmp"))
let a = rect(10,20,500,450, 0.8,0.2,0.2,1)
let b = orect(10,20,500,450, 0.2,0.2,0.2,1)
let c = trect(50,30,413,397, 1,1,1,1, "bmps/notbadd.bmp")

var panel = screen3d(xPos: 0, yPos : 0, zPos : 0, pitch : 80, yaw : 40, roll : 0)

proc drwFunc() =
  a()
  b()
  c()

addDraw(makeScreen(panel, a))
#addDraw(orect(50,30,413,397, 0.2,0.2,0.2,1))

sdlx.run()

sdlx.destroy()
