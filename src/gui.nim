import parsers, opengl, sdl2

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

let scrW = 640
let scrH = 480

var pTable*: seq[ref panel] = @[] # panels

proc default(): proc( x,y,width,height: float ) =
  return proc( x,y,width,height: float ) =
    setColor( 255, 255, 255, 255 )
    rect( x, y, width, height )

proc defaultClick(): proc( button: int, pressed: bool, x,y: float ) =
  return proc( button: int, pressed: bool, x,y: float ) =
    echo("Clicked")

proc newPanel*( x,y,width,height: float ): ref panel =
  let newP = new(panel)
  newP.x = x/(scrW/2) - 1
  newP.y = y/(-scrH/2) + 1 # corrects it so that the origin is the top left
  newP.width = width/(scrW/2)
  newP.height = height/(scrH/2)
  newP.visible = true
  newP.textureID = 0

  newP.drawFunc = default()
  newP.doClick =  defaultClick()

  pTable.add( newP )

  return newP

proc panelsDraw*(): proc() =
  return proc() =
    glUseProgram(0) # make sure we don't mess with the custom shader
    var cur: ref panel
    for i in low(pTable)..high(pTable):
      cur = pTable[i]
      if (cur.visible) :
        glLoadIdentity()
        cur.drawFunc( cur.x, cur.y, cur.width, cur.height )

#Panel I/O
proc panelsMouseInput*( button: int, pressed: bool, x,y:float ) =
  var
    cur: ref panel
    xMin,xMax: float
    yMin,yMax: float

  for i in low(pTable)..high(pTable):
    cur = pTable[i]
    xMin = (cur.x + 1) * scrW.float/2
    xMax = xMin + cur.width * scrW.float/2
    if ( xMin <= x and xMax >= x ) : #check if its within the panel's x
      yMin = (cur.y - 1) * -1 * scrH.float/2
      yMax = yMin + cur.height * scrH.float/2
      if ( yMin <= y and yMax >= y ) : #check if its within the panel's y
        cur.doClick( button, pressed, x,y ) # call the do click

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


type
  screen3d* = object
    xPos*: GLfloat
    yPos*: GLfloat
    zPos*: GLfloat
    pitch*: GLfloat
    yaw*: GLfloat
    roll*: GLfloat
