import gui, sdlx, parsers, opengl, camera, global, math, entity, simulator, vector

var
  screen1 = newScreen( 5.0, 0.0, 0.0,   0.0, 180.0, 0.0 )
  button = newPanel(320-45,385,90,30,screen1)
  pane = newPanel(0,0,640,480, screen1)
  t = 1
  open* = false

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

        var n = playerShip.angle
        echo(n[0])
        echo(n[1])
        echo(n[2])
        echo()
        var newPos = playerShip.pos + vec3(n[0] * screen1.xPos, n[1] * screen1.yPos, n[2] * screen1.zPos)
        screen1.ent.setPos(newPos)
        screen1.ent.setAngle(vec3(playerShip.angle[0] + screen1.pitch,playerShip.angle[1] + screen1.yaw, playerShip.angle[2] + screen1.roll))
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
