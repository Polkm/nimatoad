import sdlx, glx

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
addDraw(model("models/icosahedron.obj", shdr))

sdlx.run()

sdlx.destroy()
