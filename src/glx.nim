import os, times, math
import opengl, glu, assimp
import matrix, vector, pointer_arithm

type Unchecked* {.unchecked.}[T] = array[1,T]

var draws: seq[proc()] = @[]
var trans = identity()
var view = lookat(eye = vec3(-0.2, 0.1, 1), target = vec3(0.0, 0.0, 0.0), up = vec3(0.0, 1.0, 0.0))
var proj = identity()

proc reshape*(width: cint, height: cint) =
  glViewport(0, 0, width, height)
  proj = perspective(fov = 40.0, aspect = float(width) / float(height), near = 0.05, far = 10.0)

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

proc attrib*(program: GLuint, name: string, size: GLint, kind: GLenum) =
  let pos = glGetAttribLocation(program, name).GLuint
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0'i32, nil)

proc shader*(vertexFile: string, fragmentFile: string): GLuint =
  var program = glCreateProgram()
  discard compileShader(program, glCreateShader(GL_VERTEX_SHADER), "src/shaders/" & vertexFile)
  discard compileShader(program, glCreateShader(GL_FRAGMENT_SHADER), "src/shaders/" & fragmentFile)

  glBindFragDataLocation(program, 0, "out_color")
  glLinkProgram(program)
  glUseProgram(program)

  program.attrib("in_position", 3'i32, cGL_FLOAT)
  # attrib(glGetAttribLocation(program, "in_color").GLuint, 3, cGL_FLOAT)
  return program

proc uniformMat(program: GLuint, name: string, mat: ptr GLfloat) =
  glUniformMatrix4fv(int32(glGetUniformLocation(program, name)), 1, false, mat)

proc uniformDrawMats(program: GLuint, model, view, proj: ptr GLfloat) =
  program.uniformMat("model", model)
  program.uniformMat("view", view)
  program.uniformMat("proj", proj)

proc bufferArray*(): GLuint =
  glGenVertexArrays(1, addr result)
  glBindVertexArray(result)

# Buffers the given data to a VAO and returns it
proc buffer*(kind: GLenum, size: GLsizeiptr, data: ptr): GLuint =
  glGenBuffers(1, addr result)
  glBindBuffer(kind, result)
  glBufferData(kind, size, data, GL_STATIC_DRAW);

# Returns the proc used to draw the given model file.
proc model*(filename: string): proc() =
  var scene = assimp.aiImportFile(filename, 0)
  var mesh = cast[ptr Unchecked[PMesh]](scene.meshes)[0]
  # let mesh = scene.meshes.offset(0)

  var buffArray = bufferArray()

  var faceArray = newSeq[ptr cint](mesh.faceCount * 3)
  # for ii in 0..mesh.faceCount:
  #   let face = mesh.faces.offset(ii)
  #   for iii in 0..face.indexCount:
  #     echo cast[cint](face.indices.offset(iii))

  # var faceArray = newSeq[ptr cint](mesh.faceCount * 3)
  # for ii in 0..mesh.faceCount:
  #   let face = mesh.faces.offset(ii)
  #   let indiis = cast[ptr array[0..0xffffff, cint]](face.indices)
  #
  #   var faceMode: GLenum
  #   case face.indexCount
  #   of 1: faceMode = GL_POINTS
  #   of 2: faceMode = GL_LINES
  #   of 3: faceMode = GL_TRIANGLES
  #   else: faceMode = GL_POLYGON
  #
  #   if (face.indexCount <= 3):
  #     for iii in 0..face.indexCount:
  #       echo face.indices[iii]

  # var faces = cast[ptr Unchecked[TFace]](addr mesh.faces)
  # var faceArray = newSeq[cint](mesh.faceCount * 3)
  # echo mesh.vertexCount
  # for i in 0..mesh.faceCount:
  #   var fc = faces[i]
    # var inds = fc.indices
    # faceArray[i] = fc.indices[0]
    # faceArray[i + 1] = inds[1]
    # faceArray[i + 2] = inds[2]

  var faceBuff = buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint).int32 * mesh.faceCount * 3, addr(faceArray[0]))

  var vertArray = cast[ptr Unchecked[float32]](addr mesh.vertices)
  var vertBuff = buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * mesh.vertexCount * 3, addr(vertArray[0]))

  # The draw proc for this model
  var offsett = 0
  var offset: ptr int = addr offsett
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

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_DEPTH_TEST)
  glDepthFunc(GL_LEQUAL)

  var shdr = shader("flat.vert", "flat.frag")

  var n = 0.1'f32
  var vertices = [
     n, n, -n,   -n, n, -n,   -n, n,  n,   n, n,  n,
     n, -n, -n,   -n, -n, -n,   -n, -n,  n,   n, -n,  n,
  ]
  var indices = [
    0'u32, 1, 2, 2, 3, 0,
    4, 7, 6, 6, 5, 4
  ]
  var buffArray = 0'u32
  glGenVertexArrays(1, addr buffArray)
  glBindVertexArray(buffArray)
  var buffVert = buffer(GL_ARRAY_BUFFER, sizeof(vertices).int32, addr vertices[0])
  shdr.attrib("in_position", 3'i32, cGL_FLOAT)
  var buffInd = buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices).int32, addr indices[0])

  draws.add(proc() =
    # view = lookat(eye = vec3(0.0, 0.0, 0.0), target = vec3(10.0, 10.0, 0.0), up = vec3(0.0, 1.0, 0.0))
    glUseProgram(shdr)
    shdr.uniformDrawMats(addr trans.m[0], addr view.m[0], addr proj.m[0])

    glBindVertexArray(buffArray)
    glDrawElements(GL_TRIANGLES, indices.len.int32, GL_UNSIGNED_INT, nil)
  )
  # draws.add(model("models/hind.ply"))

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

  # glDrawArrays(GL_TRIANGLES, 0, 3)
