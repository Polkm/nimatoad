import os, opengl, glu, times, math

proc reshape*(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window
  glMatrixMode(GL_PROJECTION)             # To operate on the projection matrix
  glLoadIdentity()                        # Reset
  gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)  # Enable perspective projection with fovy, aspect, zNear and zFar

proc compileShader(program: GLuint, shdr: GLuint, file: string): GLuint =
  var src = readFile(file).cstring
  glShaderSource(shdr, 1, cast[cstringArray](addr src), nil)
  glCompileShader(shdr)
  var status: GLint
  glGetShaderiv(shdr, GL_COMPILE_STATUS, addr status)
  if status != GL_TRUE:
    var buff: array[512, char]
    glGetShaderInfoLog(shdr, 512, nil, buff)
    echo(buff)
    assert false
  glAttachShader(program, shdr)
  return shdr

proc shader*(vertexFile: string, fragmentFile: string): GLuint =
  var program = glCreateProgram()
  discard compileShader(program, glCreateShader(GL_VERTEX_SHADER), "src/shaders/" & vertexFile)
  discard compileShader(program, glCreateShader(GL_FRAGMENT_SHADER), "src/shaders/" & fragmentFile)

  glBindFragDataLocation(program, 0, "out_color")
  glLinkProgram(program)
  glUseProgram(program)
  # Vertex data <-> attributes
  var posAttrib = glGetAttribLocation(program, "in_position").GLuint
  glEnableVertexAttribArray(posAttrib)
  glVertexAttribPointer(posAttrib, 2, cGL_FLOAT, false,
                        6 * sizeof(GLFloat).int32, nil)

  var colAttrib = glGetAttribLocation(program, "in_color").GLuint
  glEnableVertexAttribArray(colAttrib)
  glVertexAttribPointer(colAttrib, 3, cGL_FLOAT, false,
                        6 * sizeof(GLFloat).int32,
                        cast[pointer](3 * sizeof(GLFloat)))
  return program

# Buffers the given data to a VAO and returns it
proc buffer*(data): GLuint =
  glGenVertexArrays(1, addr result)
  glBindVertexArray(result)

  var vertexBuffer: GLuint
  glGenBuffers(1, addr vertexBuffer)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
  var tmp = data
  glBufferData(GL_ARRAY_BUFFER, sizeof(tmp).int32, addr tmp, GL_STATIC_DRAW)

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
  glClearDepth(1.0)                                 # Set background depth to farthest
  glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
  glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
  glShadeModel(GL_SMOOTH)                           # Enable smooth shading
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections

  var vertices = [
     0.0'f32, 0.5, 0, 1, 0, 0,
     0.5,    -0.5, 0, 0, 1, 0,
    -0.5,    -0.5, 0, 0, 0, 1
  ]
  var buff = buffer(vertices)
  var shdr = shader("flat.vert", "flat.frag")

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  glDrawArrays(GL_TRIANGLES, 0, 3)
