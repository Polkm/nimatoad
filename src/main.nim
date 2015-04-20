import sdlx, glx

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
addDraw(model("models/hind.ply", shdr))

sdlx.run()

sdlx.destroy()
