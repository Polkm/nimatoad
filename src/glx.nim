import os, opengl, times, math

proc assertShader(shader: GLuint) =
  var status: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr status)
  if status != GL_TRUE:
    var buff: array[512, char]
    glGetShaderInfoLog(shader, 512, nil, buff)
    echo(buff)
    assert false

const
  vertexSource = """
#version 130

in vec2 position;
in vec3 color;

out vec3 Color;

void main()
{
    Color = color;
    gl_Position = vec4(position, 0.0, 1.0);
}
"""
  fragmentSource = """
#version 130

in vec3 Color;

out vec4 outColor;

void main()
{
    outColor = vec4(Color, 1.0);
}
"""

proc setup*(shaderProgram: var TGLUint) =
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

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  glDrawArrays(GL_TRIANGLES, 0, 3)
