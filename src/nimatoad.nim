import sdlx, glx, matrix, vector
import gui, parsers, opengl
import ship, entity


sdlx.init()

var phong = initProgram("phong.vert", "phong.frag")
var mat = initMaterial("bmps/metal2.bmp")
var msh = initMesh("models/ship1.obj", phong.handle)

var station = newShip()
station.setPos(vec3(0, 0, -6))
station.program = phong
station.material = mat
station.mesh = msh

var shp = newShip()
shp.setPos(vec3(1, 4, -10))
shp.program = phong
shp.material = mat
shp.mesh = msh

var pane = newPanel(50,50,100,100)
pane.textureID = parseBmp("bmps/notbadd.bmp")

proc z(): proc( x,y,w,h: float ) =
  var
    col = 55
    pitch = 0.0.float
    yaw = -45.0.float
    roll = 0.0.float
    xPos = 0.0.float
    yPos = 0.0.float
    zPos = 0.0.float
    progress = 1000
  return proc( x,y,w,h: float ) =

    #glRotatef( pitch, 1.0, 0, 0 )
    #glRotatef( yaw, 0, 1.0, 0 )
    #glRotatef( roll, 0, 0, 1.0 )
    #glTranslatef( xPos + x * -1, yPos + y * 1, zPos )

    gui.setColor( col, 255, 255, col )
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
