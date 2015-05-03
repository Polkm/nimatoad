import gui, sdlx, parsers, opengl, camera, global, math, entity, simulator, vector, matrix

var
  screen1 = newScreen( 0.30, -0.35, -0.5,   -50.0, -180.0, 0.0 )
  button = newPanel(320-45,385,90,30)
  pane = newPanel(0,0,640,480)
  t = 1
  open* = true
  harvest = newPanel(100,0,60,20, screen1)
  resources = newPanel(200,0,45,15, screen1)
  resource = newPanel(190,20,16,10, screen1)
  progressBar = newPanel(100,22,60,2, screen1)
  resourceCount = 2
  progress = 0.0
  harvesting = false

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

  pane.drawFunc = textured(false, pane)
  button.drawFunc = textured(true, button)
  button.doClick = clicked()

  proc drwH( x,y,w,h: float ) =
    screen1.ent.setAngle(vec3(-playerShip.angle[0] + screen1.pitch, playerShip.angle[1] + screen1.yaw, playerShip.angle[2] + screen1.roll))

    # var forward = vec3(playerShip.matrix.m[8],playerShip.matrix.m[9],playerShip.matrix.m[10])
    # var right = vec3(playerShip.matrix.m[0],playerShip.matrix.m[1],playerShip.matrix.m[2])
    # var up = vec3(playerShip.matrix.m[4],playerShip.matrix.m[5],playerShip.matrix.m[6])
    # var newPos = playerShip.pos + forward * screen1.xPos + up * screen1.yPos + right * screen1.zPos

    screen1.ent.setPos(playerShip.matrix * vec3(screen1.zPos, screen1.yPos, screen1.xPos))

    setColor(255,255,255,255)
    trect( x,y,w,h,harvest.textureID )

  proc drwR( x,y,w,h: float ) =
    setColor(255,255,255,255)
    trect( x,y,w,h,resources.textureID )

  proc drwRs( x,y,w,h: float ) =
    for i in 0..resourceCount :
      setColor(155,255,155,255)
      trect( x + (21 * (i mod 4)).float/(640.float/2.0),y - (12 * floor(i.float/4.0)).float/(240.0), w,h,resource.textureID )

  proc drwP( x,y,w,h: float ) =
    let percent = progress/100
    setColor(255-(255* percent).int,(255* percent).int,0,255)
    rect( x,y,w * percent,h )
    setColor(0,0,0,255)
    rect( x + w * percent,y,w - w * percent,h )
    setColor(255,255,255,255)
    orect( x,y,w,h )
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
proc pullup*() =
  pane.visible = true
  button.visible = true
  t = 1
  open = true


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
