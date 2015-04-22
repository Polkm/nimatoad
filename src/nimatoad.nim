import sdlx, glx, matrix, vector, gui

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
var trans = identity()
# var trans = lookat(eye = vec3(0, -2, 0), target = vec3(0, -100, 100), up = vec3(0, 1, 0))
# addDraw(model("models/station1.ply", shdr, trans.addr, "bmps/metal2.bmp"))
addDraw(model("models/texturedcube.obj", shdr, trans.addr, "bmps/notbadd.bmp"))

addDraw(gui.rect(0,0,0.5,0.5))


sdlx.run()

sdlx.destroy()
