import sdlx, glx

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
addDraw(model("models/hind.ply", shdr))


addDraw(rect(10,20,500,450, 0.8,0.2,0.2,1))
addDraw(orect(10,20,500,450, 0.2,0.2,0.2,1))
addDraw(trect(50,30,413,397, 1,1,1,1, "bmps/notbadd.bmp"))
addDraw(orect(50,30,413,397, 0.2,0.2,0.2,1))

sdlx.run()

sdlx.destroy()
