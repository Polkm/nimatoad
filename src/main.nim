import sdlx, glx, matrix, vector

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
# var trans = identity()
var trans = lookat(eye = vec3(0, -2, 0), target = vec3(0, -100, 100), up = vec3(0, 1, 0))
addDraw(model("models/hind.ply", shdr, trans.addr, "bmps/notbadd.bmp"))

#addDraw(rect(10,20,500,450, 0.8,0.2,0.2,1))
#addDraw(orect(10,20,500,450, 0.2,0.2,0.2,1))
#addDraw(trect(50,30,413,397, 1,1,1,1, "bmps/notbadd.bmp"))
#addDraw(orect(50,30,413,397, 0.2,0.2,0.2,1))

sdlx.run()

sdlx.destroy()
