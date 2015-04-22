import opengl

###########################
########GUI STUFF##########
###########################

#I/O panel management

type
  panel* = object
    x*: float
    y*: float
    width*: float
    height*: float
    textureID*: GLfloat #if it has a texture
    drawFunc*: proc( x,y,width,height: float)#this is the function to call to draw it

# actual Drawing functions

let scrW = 640
let scrH = 480
var
  dRed = 1.float
  dGreen = 1.float
  dBlue = 1.float
  dAlpha = 1.float

#  var x = iX/(scrW/2) - 1
#  var y = iY/(-scrH/2) + 1 # corrects it so that the origin is the top left
#  var width = iW/(scrW/2)
#  var height = iH/(scrH/2)

proc gui_setColor*( r,g,b,a ) =
  dRed = (r/255).float
  dGreen = (g/255).float
  dBlue = (b/255).float
  dAlpha = (a/255).float


# Returns the proc used to draw a rectangle
proc rect*( x,y,width,height: float): proc() =
  glUseProgram(0)

  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y - height, 0)

  glEnd()

# Returns the proc used to draw a rectangle
proc orect*( x,y,width,height: float): proc() =
  glUseProgram(0)

  glBegin(GL_LINE_LOOP)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y - height - 1/480, 0)

  glEnd()


#Textured Rect
proc trect*( x,y,width,height: float,textureID): proc() =
  glUseProgram(0)

  glEnable(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, textureID)

  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,0 )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,0 )
  glVertex3f( x + width, y, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,1 )
  glVertex3f( x + width, y - height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,1 )
  glVertex3f( x, y - height, 0)

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

proc makeScreen*( obj: screen3d, canvas: proc() ): proc() =
  return proc() =
    glUseProgram(0)

    glRotatef( obj.pitch, 1.0, 0, 0 )
    glRotatef( obj.yaw, 0, 1.0, 0 )
    glRotatef( obj.roll, 0, 0, 1.0 )
    glTranslatef( obj.xPos, obj.yPos, obj.zPos )

    canvas()

    glTranslatef( -1*obj.xPos, -1*obj.yPos, -1*obj.zPos )
    glRotatef( -1*obj.roll, 0, 0, 1.0 )
    glRotatef( -1*obj.yaw, 0, 1.0, 0 )
    glRotatef( -1*obj.pitch, 1.0, 0, 0 )
