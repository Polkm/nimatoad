import os, opengl, glu, times, math

proc reshape*(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
  glMatrixMode(GL_PROJECTION)             # To operate on the projection matrix
  glLoadIdentity()                        # Reset
  gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)  # Enable perspective projection with fovy, aspect, zNear and zFar

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
  glClearDepth(1.0)                                 # Set background depth to farthest
  glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
  glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
  glShadeModel(GL_SMOOTH)                           # Enable smooth shading
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections
  
  var vertices = [
     0.0'f32, 0.5, 1, 0, 0,
     0.5,    -0.5, 0, 1, 0,
    -0.5,    -0.5, 0, 0, 1
  ]
  echo(vertices.repr)
  var vertexBuffer: GLuint
  glGenBuffers(1, addr vertexBuffer)
  echo("Verter Buff: ", vertexBuffer)

  var vertexArray: GLuint
  glGenVertexArrays(1, addr vertexArray)
  glBindVertexArray(vertexArray)


  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices).int32, addr vertices,
               GL_STATIC_DRAW)

  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  var vertexSrcArray = [vertexSource.cstring]
  glShaderSource(vertexShader, 1, cast[cstringArray](addr vertexSrcArray), nil)
  glCompileShader(vertexShader)
  assertShader(vertexShader)

  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
  var fragmentSrcArray = [fragmentSource.cstring]
  glShaderSource(fragmentShader, 1, cast[cstringArray](addr fragmentSrcArray),
      nil)
  glCompileShader(fragmentShader)
  assertShader(fragmentShader)

  shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, vertexShader)
  glAttachShader(shaderProgram, fragmentShader)

  # Apparently this is not necessary according to http://open.gl
  glBindFragDataLocation(shaderProgram, 0, "outColor")

  glLinkProgram(shaderProgram)
  glUseProgram(shaderProgram)

  # Vertex data <-> attributes
  var posAttrib = glGetAttribLocation(shaderProgram, "position").GLuint
  glEnableVertexAttribArray(posAttrib)
  glVertexAttribPointer(posAttrib, 2, cGL_FLOAT, false,
                        5*sizeof(GLFloat).int32, nil)

  var colAttrib = glGetAttribLocation(shaderProgram, "color").GLuint
  glEnableVertexAttribArray(colAttrib)
  glVertexAttribPointer(colAttrib, 3, cGL_FLOAT, false,
                        5*sizeof(GLFloat).int32,
                        cast[pointer](2*sizeof(GLFloat)))

proc compileShader(program: GLuint, shdr: GLuint, file: string) =
  glShaderSource(vertexShader, 1, cast[cstringArray](addr [readFile(file).cstring]), nil)
  glCompileShader(vertexShader)
  var status: GLint
  glGetShaderiv(shdr, GL_COMPILE_STATUS, addr status)
  if status != GL_TRUE:
    var buff: array[512, char]
    glGetShaderInfoLog(shdr, 512, nil, buff)
    echo(buff)
    assert false
  glAttachShader(program, shdr)
  return shdr

proc shader*(vertexFile: string, fragmentFile: string): TGLUint =
  var program = glCreateProgram()
  var vertShdr = compileShader(program, glCreateShader(GL_VERTEX_SHADER), vertexFile)
  var fragShdr = compileShader(program, glCreateShader(GL_FRAGMENT_SHADER), fragmentFile)

  glAttachShader(program, fragmentShader)
  glBindFragDataLocation(program, 0, "out_color")
  glLinkProgram(program)
  glUseProgram(program)
  return program


proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT) # Clear color and depth buffers
  glMatrixMode(GL_MODELVIEW)                          # To operate on model-view matrix
  glLoadIdentity()                 # Reset the model-view matrix
  glTranslatef(1.5, 0.0, -7.0)     # Move right and into the screen

  # Render a cube consisting of 6 quads
  # Each quad consists of 2 triangles
  # Each triangle consists of 3 vertices

  glBegin(GL_TRIANGLES)        # Begin drawing of triangles

  # Top face (y = 1.0f)
  glColor3f(0.0, 1.0, 0.0)     # Green
  glVertex3f( 1.0, 1.0, -1.0)
  glVertex3f(-1.0, 1.0, -1.0)
  glVertex3f(-1.0, 1.0,  1.0)
  glVertex3f( 1.0, 1.0,  1.0)
  glVertex3f( 1.0, 1.0, -1.0)
  glVertex3f(-1.0, 1.0,  1.0)

  # Bottom face (y = -1.0f)
  glColor3f(1.0, 0.5, 0.0)     # Orange
  glVertex3f( 1.0, -1.0,  1.0)
  glVertex3f(-1.0, -1.0,  1.0)
  glVertex3f(-1.0, -1.0, -1.0)
  glVertex3f( 1.0, -1.0, -1.0)
  glVertex3f( 1.0, -1.0,  1.0)
  glVertex3f(-1.0, -1.0, -1.0)

  # Front face  (z = 1.0f)
  glColor3f(1.0, 0.0, 0.0)     # Red
  glVertex3f( 1.0,  1.0, 1.0)
  glVertex3f(-1.0,  1.0, 1.0)
  glVertex3f(-1.0, -1.0, 1.0)
  glVertex3f( 1.0, -1.0, 1.0)
  glVertex3f( 1.0,  1.0, 1.0)
  glVertex3f(-1.0, -1.0, 1.0)

  # Back face (z = -1.0f)
  glColor3f(1.0, 1.0, 0.0)     # Yellow
  glVertex3f( 1.0, -1.0, -1.0)
  glVertex3f(-1.0, -1.0, -1.0)
  glVertex3f(-1.0,  1.0, -1.0)
  glVertex3f( 1.0,  1.0, -1.0)
  glVertex3f( 1.0, -1.0, -1.0)
  glVertex3f(-1.0,  1.0, -1.0)

  # Left face (x = -1.0f)
  glColor3f(0.0, 0.0, 1.0)     # Blue
  glVertex3f(-1.0,  1.0,  1.0)
  glVertex3f(-1.0,  1.0, -1.0)
  glVertex3f(-1.0, -1.0, -1.0)
  glVertex3f(-1.0, -1.0,  1.0)
  glVertex3f(-1.0,  1.0,  1.0)
  glVertex3f(-1.0, -1.0, -1.0)

  # Right face (x = 1.0f)
  glColor3f(1.0, 0.0, 1.0)    # Magenta
  glVertex3f(1.0,  1.0, -1.0)
  glVertex3f(1.0,  1.0,  1.0)
  glVertex3f(1.0, -1.0,  1.0)
  glVertex3f(1.0, -1.0, -1.0)
  glVertex3f(1.0,  1.0, -1.0)
  glVertex3f(1.0, -1.0,  1.0)

  glEnd()  # End of drawing


#
# proc draw*() =
#   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
#
#   glDrawArrays(GL_TRIANGLES, 0, 3)
