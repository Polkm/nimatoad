import os, times, math
import opengl, glu, assimp
import matrix, vector

type Unchecked* {.unchecked.}[T] = array[1,T]

proc reshape*(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)

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

  # var colAttrib = glGetAttribLocation(program, "in_color").GLuint
  # glEnableVertexAttribArray(colAttrib)
  # glVertexAttribPointer(colAttrib, 3, cGL_FLOAT, false,
  #                       6 * sizeof(GLFloat).int32,
  #                       cast[pointer](3 * sizeof(GLFloat)))
  return program

proc bufferArray*(): GLuint =
  glGenVertexArrays(1, addr result)
  glBindVertexArray(result)

# Buffers the given data to a VAO and returns it
proc buffer*(kind: GLenum, size: GLsizeiptr, data): GLuint =
  glGenBuffers(1, addr result)
  glBindBuffer(kind, result)
  var tmp = data
  glBufferData(kind, size, addr tmp, GL_STATIC_DRAW);

proc attrib*(pos: GLuint, size: GLint, kind: GLenum) =
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0.GLsizei, nil)

# Returns the proc used to draw the given model file.
proc model*(filename: string): proc() =
  var scene = assimp.aiImportFile(filename, 0)
  var mesh = cast[ptr Unchecked[PMesh]](scene.meshes)[0]

  var buffArray = bufferArray()

  var faces = cast[ptr Unchecked[TFace]](addr mesh.faces)
  var faceArray = newSeq[uint](mesh.faceCount * 3)
  echo mesh.vertexCount
  for i in 0..mesh.faceCount:
    var fc = faces[i]
    # var inds = fc.indices
    var inds = cast[array[3, uint]](fc.indices)
    faceArray[i] = inds[0]
    faceArray[i + 1] = inds[1]
    faceArray[i + 2] = inds[2]

  var faceBuff = buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint).int32 * mesh.faceCount * 3, faceArray)

  var vertArray = cast[ptr Unchecked[float32]](addr mesh.vertices)
  var vertBuff = buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * mesh.vertexCount * 3, faceArray)
  attrib(0, 3, cGL_FLOAT)

  # The draw proc for this model
  var offset: ptr int
  return proc() =
    glBindVertexArray(buffArray)
    glDrawElements(GL_TRIANGLES, mesh.faceCount * 3, GL_UNSIGNED_INT, offset)

  # if (mesh->HasPositions()) {
  #     glGenBuffers(1, &buffer);
  #     glBindBuffer(GL_ARRAY_BUFFER, buffer);
  #     glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*mesh->mNumVertices, mesh->mVertices, GL_STATIC_DRAW);
  #     glEnableVertexAttribArray(vertexLoc);
  #     glVertexAttribPointer(vertexLoc, 3, GL_FLOAT, 0, 0, 0);
  # }


        # // buffer for faces
        # glGenBuffers(1, &buffer);
        # glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
        # glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint) * mesh->mNumFaces * 3, faceArray, GL_STATIC_DRAW);
        #
        # // buffer for vertex positions
        # if (mesh->HasPositions()) {
        #     glGenBuffers(1, &buffer);
        #     glBindBuffer(GL_ARRAY_BUFFER, buffer);
        #     glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*mesh->mNumVertices, mesh->mVertices, GL_STATIC_DRAW);
        #     glEnableVertexAttribArray(vertexLoc);
        #     glVertexAttribPointer(vertexLoc, 3, GL_FLOAT, 0, 0, 0);
        # }
        #
        # // buffer for vertex normals
        # if (mesh->HasNormals()) {
        #     glGenBuffers(1, &buffer);
        #     glBindBuffer(GL_ARRAY_BUFFER, buffer);
        #     glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*mesh->mNumVertices, mesh->mNormals, GL_STATIC_DRAW);
        #     glEnableVertexAttribArray(normalLoc);
        #     glVertexAttribPointer(normalLoc, 3, GL_FLOAT, 0, 0, 0);
        # }
        #
        # // buffer for vertex texture coordinates
        # if (mesh->HasTextureCoords(0)) {
        #     float *texCoords = (float *)malloc(sizeof(float)*2*mesh->mNumVertices);
        #     for (uint k = 0; k < mesh->mNumVertices; ++k) {
        #
        #         texCoords[k*2]   = mesh->mTextureCoords[0][k].x;
        #         texCoords[k*2+1] = mesh->mTextureCoords[0][k].y;
        #
        #     }
        #     glGenBuffers(1, &buffer);
        #     glBindBuffer(GL_ARRAY_BUFFER, buffer);
        #     glBufferData(GL_ARRAY_BUFFER, sizeof(float)*2*mesh->mNumVertices, texCoords, GL_STATIC_DRAW);
        #     glEnableVertexAttribArray(texCoordLoc);
        #     glVertexAttribPointer(texCoordLoc, 2, GL_FLOAT, 0, 0, 0);
        # }

var draws: seq[proc()] = @[]

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)                  # Set background color to black and opaque
  glClearDepth(1.0)                                 # Set background depth to farthest
  glEnable(GL_DEPTH_TEST)                           # Enable depth testing for z-culling
  glDepthFunc(GL_LEQUAL)                            # Set the type of depth-test
  glShadeModel(GL_SMOOTH)                           # Enable smooth shading
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) # Nice perspective corrections

  var view = identity().lookat(eye = vec3(0.0, 0.0, 0.0), org = vec3(1.0, 1.0, 0.0), up = vec3(0.0, 1.0, 0.0))
  echo(view)
  var proj = perspective(fov = 71, aspect = 9.0/16.0, near = 1.0, far = 10000.0)
  echo(proj)


  draws.add(model("models/hind.ply"))
  var vertices = [
     0.0'f32, 0.5, 0, 1, 0, 0,
     0.5,    -0.5, 0, 0, 1, 0,
    -0.5,    -0.5, 0, 0, 0, 1
  ]
  # var buff = buffer(vertices)
  var shdr = shader("flat.vert", "flat.frag")

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

  # glDrawArrays(GL_TRIANGLES, 0, 3)
