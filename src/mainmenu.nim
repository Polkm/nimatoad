import gui, sdlx, parsers, opengl

proc init*() =
  var
    button = newPanel(320-60,385,120,30)
    pane = newPanel(0,0,640,480)
    alpha = 255
  pane.textureID = parseBmp("bmps/mainmenu.bmp")


  proc outlined(): proc( x,y,w,h: float ) =
    return proc( x,y,w,h: float ) =
      setColor(155,155,155,alpha)
      orect( x,y,w,h )

  proc textured(): proc( x,y,w,h: float ) =
    return proc( x,y,w,h: float ) =
      setColor(255,255,255,alpha)
      trect( x,y,w,h,pane.textureID )

  pane.drawFunc = textured()





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
