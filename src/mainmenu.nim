import gui, sdlx, parsers, opengl, camera
import global, math, entity, simulator, vector, matrix

var
  screen1 = newScreen( 0.30, -0.35, -0.5,   -50.0, -180.0, 0.0 )
  button = newPanel(320-45,385,90,30)
  pane = newPanel(0,0,640,480)
  t = 1
  open* = true
  cursor* = true
  harvest = newPanel(100,0,60,20, screen1)
  resources = newPanel(200,0,45,15, screen1)
  resource = newPanel(190,20,16,10, screen1)
  progressBar = newPanel(100,22,60,2, screen1)
  resourceCount = 2
  progress = 0.0
  harvesting = false
  crosshair = newPanel(320,240,1,1)
  crosshair.onClick: proc( but: int, pressed: bool, x,y:float ) = proc( but: int, pressed: bool, x,y:float )



proc addStationMenu( ent: Entity ) =
  var screen = newScreen( ent.pos[0] + 1.0, ent.pos[1] + 22.0, ent.pos[2],   0.0, 0.0, 0.0 )
  var panel = newPanel( 0,0,1600,1600, screen)
  panel.textureID = parseBmp("bmps/mainmenu/resourcesbutton.bmp")

  proc drw( x,y,w,h: float ) =
    #screen.ent.setPos(vec3())
    screen.ent.setAngle(vec3(screen.pitch, screen.yaw, screen.roll))
    setColor(255,255,255,255)
    trect( x,y, w,h,panel.textureID )
    screen.yaw = screen.yaw + 1

  proc harvestClick( but: int, pressed: bool, x,y:float ) =
    resourceCount = 0

  panel.drawFunc = drw
  panel.doClick = harvestClick

proc init*() =
  var
    alpha = 255.float

  pane.textureID = parseBmp("bmps/mainmenu/mainmenu.bmp")
  button.textureID = parseBmp("bmps/mainmenu/playbutton.bmp")
  harvest.textureID = parseBmp("bmps/mainmenu/harvestbutton.bmp")
  resources.textureID = parseBmp("bmps/mainmenu/resourcesbutton.bmp")
  resource.textureID = parseBmp("bmps/mainmenu/resource.bmp")
  progressBar.textureID = parseBmp("bmps/mainmenu/bar.bmp")
  proc textured( think: bool, panelref : ref panel, alph = true ): proc( x,y,w,h: float ) =
    return proc( x,y,w,h: float ) =
      if (alph) :
        setColor(255,255,255,alpha.int)
      else :
        setColor(255,255,255,255)
      trect( x,y,w,h,panelref.textureID )
      if (think) :
        if (t < 0) :
          alpha = alpha - 10
          if (alpha <= 0) :
            alpha = 0
            pane.visible = false
            button.visible = false
        elif (t > 0):
          alpha = alpha + 15
          if (alpha >= 255) :
            alpha = 255


  proc clicked(): proc( but: int, pressed: bool, x,y:float ) =
    return proc( but: int, pressed: bool, x,y:float ) =
      t = t * -1
      open = false
      cursor = false

  pane.drawFunc = textured(false, pane)
  button.drawFunc = textured(true, button)
  button.doClick = clicked()

  proc drwH( x,y,w,h: float ) =
    setColor(255,255,255,255)
    trect( x,y,w,h,harvest.textureID )

  proc drwR( x,y,w,h: float ) =
    setColor(255,255,255,255)
    trect( x,y,w,h,resources.textureID )

  proc drwRs( x,y,w,h: float ) =
    for i in 1..resourceCount :
      setColor(155,255,155,255)
      trect( x + (21 * ((i-1) mod 4)).float/(640.float/2.0),y - (12 * floor((i-1).float/4.0)).float/(240.0), w,h,resource.textureID )

  proc drwP( x,y,w,h: float ) =
    let percent = progress/100
    setColor(255-(255* percent).int,(255* percent).int,0,255)
    rect( x,y,w * percent,h )
    setColor(0,0,0,255)
    rect( x + w * percent,y,w - w * percent,h )
    setColor(255,255,255,255)
    orect( x,y,w,h )

    if (harvesting) :
      progress = progress + 1
      if (progress >= 100) :
        progress = 100
        if (harvesting) :
          resourceCount = resourceCount + 1
        harvesting = false


  proc harvestClick( but: int, pressed: bool, x,y:float ) =
    harvesting = not harvesting
    if (progress >= 100) :
      progress = 0

  harvest.drawFunc = drwH
  harvest.doClick = harvestClick
  resources.drawFunc = drwR
  resource.drawFunc = drwRs
  progressBar.drawFunc = drwP

  addStationMenu(fetchStation())

proc pullup*() =
  pane.visible = true
  button.visible = true
  t = 1
  open = true
  cursor = true

# proc z(): proc( x,y,w,h: float ) =
  # var
  #   col = 55
  #   pitch = 0.0.float
  #   yaw = -45.0.float
  #   roll = 0.0.float
  #   xPos = 0.0.float
  #   yPos = 0.0.float
  #   zPos = 0.0.float
  #   progress = 1000
  # return proc( x,y,w,h: float ) =
  #
  #   #glRotatef( pitch, 1.0, 0, 0 )
  #   #glRotatef( yaw, 0, 1.0, 0 )
  #   #glRotatef( roll, 0, 0, 1.0 )
  #   #glTranslatef( xPos + x * -1, yPos + y * 1, zPos )
  #
  #   gui.setColor( col, 255, 255, col )
  #   gui.trect(x + (w * 0.25),y - (h * 0.25),w * 0.5,h *0.5, pane.textureID)
  #   glTranslatef( 0.0, 0.0,0.001 )
  #   gui.setColor( 100, 0, 0, col )
  #   gui.orect(x,y,w,h)
  #
  #   glTranslatef( 0.0, 0.0,0.001 )
  #   gui.setColor( 0, 100, 0, col )
  #   gui.rect(x - w *0.2,y - h * 0.1,w * 0.1,(h - h * 0.2 ) * (progress mod 1000).float / 1000 )
  #
  #
  #   glTranslatef( 0.0, 0.0,0.001 )
  #   gui.setColor( 255, 255, 255, col )
  #   gui.rect(x,y,w,h)
  #
  #   progress = progress + 1
  #   if ((progress mod 1000).float / 1000 > 1) :
  #     progress = 0
  #   yaw = yaw + 0.1
