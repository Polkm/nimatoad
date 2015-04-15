import opengl
import strutils
import typeinfo
import math

## -------------------------------------------------------------------------------

var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0

    windowW: GLint = 1024
    windowH: GLint = 768

    vshaderID: GLuint
    fshaderID: GLuint
    shaderProg: GLuint

    vertexPosAttrLoc: GLuint
    colorsPosAttrLoc: GLuint

    startTime: cdouble

    rotationLoc: int32
    rx, ry, rz: float32

    scaleLoc: int32
    scale: float32

    mvpMatrixUniLoc: int
    positionLoc: int

    x: float32
    y: float32
    z: float32

    mvMatrix: array[0..15, float32] = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
                                       0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
                                       0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
                                       0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]

    pMatrix: array[0..15, float32]  = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
                                       0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
                                       0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
                                       0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]

    vbo: GLuint
    colors_vbo: GLuint

type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------


proc DegToRad(deg: float32) :float32 =
    result = deg / 180 * PI

proc OpenGlOrthographic(l: float32, r: float32, b: float32, t: float32, n: float32, f: float32, matrix: var array[0..15, float32]) =

    matrix[0] = 2.0 / (r - l)
    matrix[1] = 0.0
    matrix[2] = 0.0
    matrix[3] = 0.0

    matrix[4] = 0.0
    matrix[5] = 2.0 / (t - b)
    matrix[6] = 0.0
    matrix[7] = 0.0

    matrix[8] = 0.0
    matrix[9] = 0.0
    matrix[10] = 2.0 / (n - f)
    matrix[11] = 0.0

    matrix[12] = (r + l) / (r - l)
    matrix[13] = (t + b) / (t - b)
    matrix[14] = (f + n) / (f - n)
    matrix[15] = 0.0

proc OpenGlPerspective(angle: float32, imageAspectRatio: float32, n: float32, f: float32, matrix: var array[0..15, float32]) =
    var
        r = DegToRad(angle)
        f = 1.0 / tan(r / 2.0)

    matrix[0] = f / imageAspectRatio
    matrix[1] = 0.0
    matrix[2] = 0.0
    matrix[3] = 0.0

    matrix[4] = 0.0
    matrix[5] = f
    matrix[6] = 0.0
    matrix[7] = 0.0

    matrix[8] = 0.0
    matrix[9] = 0.0
    matrix[10] = -(f + n) / (f - n)
    matrix[11] = -1.0

    matrix[12] = 0.0
    matrix[13] = 0.0
    matrix[14] = -(2.0 * f * n) / (f - n)
    matrix[15] = 0.0

proc Resize(width: GLint, height: int32) =

    glViewport(0, 0, width, height)

    #OpenGlOrthographic(-10.0, 10.0, -10.0, 10.0, -1.0, -50.0, pMatrix)
    OpenGlPerspective(60.0, float32(width) / float32(height), -1.0, -50.0, pMatrix)

## -------------------------------------------------------------------------------

proc LoadShader(shaderType: ShaderType, file: string ): GLuint =

    if shaderType == VertexShader:
        result = glCreateShader(GL_VERTEX_SHADER)

    else:
        result = glCreateShader(GL_FRAGMENT_SHADER)


    var shaderSrc = readFile(file)

    var shader = result

    var stringArray = allocCStringArray([shaderSrc])

    glShaderSource(shader, 1 , stringArray, nil)

    deallocCStringArray(stringArray)

    glCompileShader(shader)

    var compileResult : GLInt

    glGetShaderiv(shader, GL_COMPILE_STATUS, addr(compileResult))

    if compileResult != GL_TRUE:
      result = 0

      var logLength : GLInt
      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr(logLength))

      var log : cstring = cast[cstring](alloc0(logLength))
      # glGetShaderInfoLog(shader, logLength, logLength, log)
      echo ("Error compiling the shader: ", file, " error: ", log)

      dealloc(log)
## ---------------------------------------------------------------------

proc InitializeGL() =

    glClearColor(0.2,0.0,0.2,1.0)
    glClearDepth(1.0)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST)

proc PrintOpenGLError() =

    nil


## ---------------------------------------------------------------------

proc InitializeShaders() =

    vshaderID = LoadShader(ShaderType.VertexShader, "vertexshader.vert")
    fshaderID = LoadShader(ShaderType.FragmentShader, "fragshader.frag")

    # if vshaderID == 9999 or fshaderID == 999:
    #     quit("Error compiling shaders!")

    shaderProg = glCreateProgram()

    glAttachShader(shaderProg, vshaderID)
    glAttachShader(shaderProg, fshaderID)

    glLinkProgram(shaderProg)

    var linkStatus : GLint

    glGetProgramiv(shaderProg, GL_LINK_STATUS, addr(linkStatus))

    if linkStatus != GL_TRUE:
        quit("Error linking shader program!")

    glUseProgram(shaderProg)

    vertexPosAttrLoc = cast[GLUint](glGetAttribLocation(shaderProg, "a_position"))

    glEnableVertexAttribArray(vertexPosAttrLoc)

    colorsPosAttrLoc = cast[GLUint](glGetAttribLocation(shaderProg, "a_color"))

    glEnableVertexAttribArray(colorsPosAttrLoc)

    rotationLoc = glGetUniformLocation(shaderProg, "u_rotation")
    scaleLoc = glGetUniformLocation(shaderProg, "u_scale")
    mvpMatrixUniLoc = glGetUniformLocation(shaderProg, "u_mvp")
    positionLoc = glGetUniformLocation(shaderProg, "u_position")

## -----------------------------------------------------------------------------

proc InitializeBuffers() =

    #var vertices = [0.0'f32, 1.0'f32, 0.0'f32, -1.0'f32, -1.0'f32, 0.0'f32, 1.0'f32, -1.0'f32, 0.0'f32]
    #var vertices = [0.0, 0.0, 0.0, -1.0, -1.0, 0.0, 0.0, -1.0, 0.0]
    var vertices = [0.0'f32,  0.0'f32,  0.0'f32,
                    1.0'f32,  0.0'f32,  0.0'f32,
                    1.0'f32,  1.0'f32,  0.0'f32,

                    1.0'f32,  1.0'f32,  0.0'f32,
                    1.0'f32,  0.0'f32,  0.0'f32,
                    1.0'f32,  0.0'f32,  1.0'f32,

                    1.0'f32, 0.0'f32, 0.0'f32,
                    0.0'f32, 1.0'f32, 0.0'f32,
                    0.0'f32, 0.0'f32, 1.0'f32,

                    0.0'f32, 0.0'f32, 1.0'f32,
                    0.0'f32, 1.0'f32, 0.0'f32,
                    1.0'f32, 0.0'f32, 0.0'f32,
                   ]

    glGenBuffers(1, addr(vbo))

    glBindBuffer(GL_ARRAY_BUFFER, vbo)

    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * vertices.len, addr(vertices[0]), GL_STATIC_DRAW)

## -------------------------------------------------------------------------------

proc Initialize*() =
  InitializeGL()
  InitializeShaders()
  InitializeBuffers()

proc Render*() =

  glClear(GL_COLOR_BUFFER_BIT)

  glUseProgram(shaderProg)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)

  glVertexAttribPointer(vertexPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)

  # glVertexAttribPointer(colorsPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, cast[GLvoid](18*sizeof(GL_FLOAT)))

  glUniform3f(rotationLoc, rx, ry, rz)
  glUniform1f(scaleLoc, scale)
  glUniformMatrix4fv(int32(mvpMatrixUniLoc), 16'i32, false, addr(pMatrix[0]))
  glUniform3f(int32(positionLoc), x, y, z)

  glDrawArrays(GL_TRIANGLES, 0, 6)

  glUseProgram(0)
