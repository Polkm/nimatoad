import parsers, opengl, sdl2, camera, vector, math
import global

###########################
########GUI STUFF##########
###########################

#panel management

proc rect*( x,y,width,height: float )
proc orect*( x,y,width,height: float )
proc trect*( x,y,width,height: float, textureID:GLuint )
proc setColor*( r,g,b,a: int )

type
  panel* = object
    x*: float
    y*: float
    width*: float
    height*: float
    textureID*: GLuint #if it has a texture
    drawFunc*: proc( x,y,width,height: float )#this is the function to call to draw it
    doClick*: proc( button: int, pressed: bool, x,y: float )
    visible*: bool

  screen3d* = object
    xPos*: float
    yPos*: float
    zPos*: float
    pitch*: float
    yaw*: float
    roll*: float
    pTable*: seq[ref panel] #this is the function to call to draw it, happens after rotation

var mainScreen: ref screen3d

var sTable*: seq[ref screen3d] = @[] # screens that display panels

proc default(): proc( x,y,width,height: float ) =
  return proc( x,y,width,height: float ) =
    setColor( 255, 255, 255, 255 )
    rect( x, y, width, height )

proc defaultClick(): proc( button: int, pressed: bool, x,y: float ) =
  return proc( button: int, pressed: bool, x,y: float ) =
    echo("Clicked")

proc newPanel*( x,y,width,height: float, addToScreen = mainScreen ): ref panel =
  let newP = new(panel)
  newP.x = x/(screenWidth/2) - 1
  newP.y = y/(-screenHeight/2) + 1 # corrects it so that the origin is the top left
  newP.width = width/(screenWidth/2)
  newP.height = height/(screenHeight/2)
  newP.visible = true
  newP.textureID = 0

  newP.drawFunc = default()
  newP.doClick =  defaultClick()

  addToScreen.pTable.add( newP )

  return newP

proc newScreen*( xPos,yPos,zPos,pitch,yaw,roll: float, shouldAdd = true ): ref screen3d =
  let newS = new(screen3d)
  newS.xPos = xPos.float
  newS.yPos = yPos.float # corrects it so that the origin is the top left
  newS.zPos = zPos.float
  newS.pitch = pitch.float
  newS.yaw = yaw.float
  newS.roll = roll.float

  newS.pTable = @[] # no panels currently

  if (shouldAdd) :
    sTable.add( newS )

  return newS

mainScreen = newScreen(0.0, 0.0, 0.0,  0.0, 0.0, 0.0)

proc dist( x1,x2,y1,y2: float ): float =
  return sqrt( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) )

proc panelsDraw*(): proc() =
  return proc() =
    glDisable(GL_CULL_FACE)
    glUseProgram(0) # make sure we don't mess with the custom shader
    var curS: ref screen3d
    for i in low(sTable)..high(sTable):
      curS = sTable[i]

      glLoadIdentity()
      glRotatef( curS.pitch, 1.0, 0, 0 )
      glRotatef( curS.yaw, 0, 1.0, 0 )
      glRotatef( curS.roll, 0, 0, 1.0 )
      glTranslatef( curS.xPos, curS.yPos, curS.zPos )

      var cur: ref panel
      for i in low(curS.pTable)..high(curS.pTable):
        cur = curS.pTable[i]
        if (cur.visible) :
          cur.drawFunc( cur.x, cur.y, cur.width, cur.height )
          glTranslatef(0,0,0.0001) # push the next panel back a bit to stop z fighting

#Panel I/O
proc panelsMouseInput*( button: int, pressed: bool, x,y:float ) =
  var
    cur: ref panel
    xCoords, yCoords: float
    xMin,xMax: float
    yMin,yMax: float
  var curS: ref screen3d
  var pixelArray: array[0..3,GLfloat]
  for i in low(sTable)..high(sTable):
    curS = sTable[i]
    glLoadIdentity()
    glRotatef( curS.pitch, 1.0, 0, 0 )
    glRotatef( curS.yaw, 0, 1.0, 0 )
    glRotatef( curS.roll, 0, 0, 1.0 )
    glTranslatef( curS.xPos, curS.yPos, curS.zPos )
    #cheaper method is just compare pixels
    for i in low(curS.pTable)..high(curS.pTable):
      cur = curS.pTable[i]
      if (cur.visible) :
        pixelArray[0] = 0
        pixelArray[1] = 0
        pixelArray[2] = 0
        pixelArray[3] = 0

        glClear( GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT )

        setColor(69,96,59,255)
        rect( cur.x,cur.y,cur.width,cur.height )

        glReadPixels((GLint) x,(GLint)(screenHeight.float-y-1), (GLsizei) 1,(GLsizei) 1, GL_RGBA, cGL_FLOAT, addr pixelArray[0])

        if (pixelArray[0]*255 == 69 and pixelArray[1]*255 == 96 and pixelArray[2]*255 == 59) :
          cur.doClick( button, pressed, x,y ) # call the do click
          break


    #take screen coords, convert them to real word coordinates
    #no
    #xCoords = x / (screenWidth.float/2) - 1
    #yCoords = y / (-screenHeight.float/2) + 1 # corrects it so that the origin is the top left
    #for i in low(curS.pTable)..high(curS.pTable):
    #  cur = curS.pTable[i]
    #  if (cur.visible) :
    #    xMin = cur.x
    #    xMax = xMin + cur.width
    #    if ( xMin <= xCoords and xMax >= xCoords ) : #check if its within the panel's x
    #      yMax = cur.y
    #      yMin = yMax - cur.height
    #      if ( yCoords >= yMin and yCoords <= yMax ) : #check if its within the panel's y
    #        cur.doClick( button, pressed, x,y ) # call the do click

# actual Drawing functions
var
  dRed = 1.float
  dGreen = 1.float
  dBlue = 1.float
  dAlpha = 1.float

#  var x = iX/(scrW/2) - 1
#  var y = iY/(-scrH/2) + 1 # corrects it so that the origin is the top left
#  var width = iW/(scrW/2)
#  var height = iH/(scrH/2)

proc setColor*( r,g,b,a: int ) =
  dRed = (r/255).float
  dGreen = (g/255).float
  dBlue = (b/255).float
  dAlpha = (a/255).float

# Returns the proc used to draw a rectangle
proc rect*( x,y,width,height: float ) =
  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glEnd()

# Returns the proc used to draw a rectangle
proc orect*( x,y,width,height: float ) =
  glBegin(GL_LINE_LOOP)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glEnd()


#Textured Rect
proc trect*( x,y,width,height: float,textureID: GLuint ) =
  glEnable(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, textureID)

  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,0 )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,1 )
  glVertex3f( x, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,1 )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,0 )
  glVertex3f( x + width, y, 0)

  glEnd()
  glDisable(GL_TEXTURE_2D)
