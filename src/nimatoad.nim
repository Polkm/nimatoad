import sdlx, glx, matrix, vector, gui, parsers, opengl

sdlx.init()

var shdr = shader("flat.vert", "flat.frag")
var trans = identity()
# var trans = lookat(eye = vec3(0, -2, 0), target = vec3(0, -100, 100), up = vec3(0, 1, 0))
addDraw(model("models/station1.ply", shdr, trans.addr, "bmps/metal2.bmp"))
#addDraw(model("models/icosahedron.obj", shdr, trans.addr, "bmps/metal1.bmp"))

var pane = newPanel(0,240,100,100)
pane.textureID = parseBmp("bmps/notbadd.bmp")

proc z(): proc( x,y,w,h: float ) =
  var
    col = 0
    pitch = 0.0.float
    yaw = -45.0.float
    roll = 0.0.float
    xPos = 0.0.float
    yPos = 0.0.float
    zPos = 0.1.float
    progress = 1000
  return proc( x,y,w,h: float ) =

    glRotatef( pitch, 1.0, 0, 0 )
    glRotatef( yaw, 0, 1.0, 0 )
    glRotatef( roll, 0, 0, 1.0 )
    glTranslatef( xPos + x * -1, yPos + y * 1, zPos )

    gui.setColor( col, 255, 255, col )
    col = col + 1
    if (col >= 255) :
      col = col - 255

    gui.trect(x + (w * 0.25),y - (h * 0.25),w * 0.5,h *0.5, pane.textureID)
    glTranslatef( 0.0, 0.0,0.001 )
    gui.setColor( 100, 0, 0, col )
    gui.orect(x,y,w,h)

    glTranslatef( 0.0, 0.0,0.001 )
    gui.setColor( 0, 100, 0, col )
    gui.rect(x - w *0.2,y - h * 0.1,w * 0.1,(h - h * 0.2 ) * (progress mod 1000).float / 1000 )


    glTranslatef( 0.0, 0.0,0.001 )
    gui.setColor( 255, 255, 255, col )
    gui.rect(x,y,w,h)

    progress = progress + 1
    if ((progress mod 1000).float / 1000 > 1) :
      progress = 0
    yaw = yaw + 0.1

pane.drawFunc = z()

addDraw(panelsDraw())


sdlx.run()

sdlx.destroy()
