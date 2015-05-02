import gui, sdlx, parsers, opengl, camera, global, math

var
  button = newPanel(320-45,385,90,30)
  pane = newPanel(0,0,640,480)
  t = 1
  open* = false
  helmetopen = false


#COCK PIT STUFF

var
  screen1 = newScreen( 0.0, -1.5, 0.0,   -25.0, -45.0, 0.0 )
  screen2 = newScreen( 0.0, 0.0, 0.0,   0.0, 0.0, 0.0 )
  screen3 = newScreen( 2.0, -1.4, 0.0,   -25.0, 45.0, 0.0 )
  pane1 = newPanel(0,0,90,30, screen1)
  pane2 = newPanel( screenWidth.float - 120 ,screenHeight.float - 40,90,30, screen2)
  progress = newPanel(0,-20,0,30, screen1)

pane1.visible = false
pane2.visible = false
progress.visible = false

proc setHelmet*( b: bool ) =
  pane1.visible = b
  pane2.visible = b
  progress.visible = b
  helmetopen = b

proc init*() =
  var
    alpha = 255.float

  pane.textureID = parseBmp("bmps/mainmenu/mainmenu.bmp")
  button.textureID = parseBmp("bmps/mainmenu/playbutton.bmp")

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
      setHelmet(true)

  pane.drawFunc = textured(false, pane)
  button.drawFunc = textured(true, button)
  button.doClick = clicked()
  open = true

  var harvesting = false
  pane1.textureID = parseBmp("bmps/mainmenu/harvestbutton.bmp")
  pane1.drawFunc = textured(false, pane1, false)
  proc clk( but: int, pressed: bool, x,y:float ) =
    harvesting = not harvesting

  pane1.doClick = clk

  pane2.textureID = parseBmp("bmps/mainmenu/resourcesbutton.bmp")

  var vag = 0
  proc drwT( x,y,w,h: float ) =
    setColor(255,255,255,255)
    trect( x,y,w,h,pane2.textureID )
    vag = vag + 1
    if ( vag > 270 ) :
      vag = 0
    screen3.yaw = 45.0 + 5 * cos(vag/45)
  pane2.drawFunc = drwT

  var resourceY = 0.0
  let res = parseBmp("bmps/mainmenu/resource.bmp")

  proc drw( x,y,w,h: float ) =
    if (helmetopen) :
      setColor(255,255,255,255)
      trect( x,y,w,h,res )

  proc progD(): proc( x,y,w,h: float ) =
    return proc( x,y,w,h: float ) =
      setColor(0,0,0,255)
      orect(x,y,w,h)
      setColor(100,255,100,255)
      rect(x,y,w,h)
      if (harvesting) :
        progress.width = w + 1/screenWidth.float
        if (progress.width > 90/screenWidth.float * 2 ) :
          progress.width = 0

          var pan = newPanel(24,-10 + -1 * resourceY,47,30, screen3)
          pan.textureID = res
          pan.drawFunc = drw
          harvesting = false
          resourceY = resourceY + 40

      progress.height = 30/screenHeight.float

  progress.drawFunc = progD()

proc pullup*() =
  pane.visible = true
  button.visible = true
  t = 1
  open = true
  setHelmet(false)


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
