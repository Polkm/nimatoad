import os, times, math
import opengl, glu, assimp
import matrix, vector, pointer_arithm
import parsers, camera

type Unchecked* {.unchecked.}[T] = array[1, T]

var draws*: seq[proc()] = @[]

proc addDraw*(draw: proc()) =
  draws.add(draw)

proc attrib*(pos: uint32, size: GLint, kind: GLenum) =
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0'i32, nil)

proc bufferArray*(): uint32 =
  glGenVertexArrays(1, result.addr)
  glBindVertexArray(result)

# Buffers the given data to a VAO and returns it
proc buffer*(kind: GLenum, size: GLsizeiptr, data: ptr): uint32 =
  glGenBuffers(1, result.addr)
  glBindBuffer(kind, result)
  glBufferData(kind, size, data, GL_STATIC_DRAW);

proc material(diffuseFile: string): proc() =
  var texture = parseBmp(diffuseFile)
  return proc() =
    glBindTexture(GL_TEXTURE_2D, texture)

# Returns the draw proc of a vao constructed from a given model file.
proc mesh*(filename: string, program: uint32): proc() =
  var scene = assimp.aiImportFile(filename, aiProcessPreset_TargetRealtime_Quality)

  # for m in 0..scene.meshCount - 1:
  var mesh = scene.meshes.offset(0)[]

  var vao = bufferArray()
  var triangles = 0;
  if (mesh.hasFaces):
    var indices = newSeq[uint32](mesh.faceCount * 3)
    for i in 0..mesh.faceCount - 1:
      for ii in 0..2:
        indices[i * 3 + ii] = (mesh.faces[i].indices[ii] + 0).uint32
    triangles = indices.len
    var buffInd = buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * triangles.int32, indices[0].addr)

  if (mesh.hasPositions):
    var vertices = newSeq[float32](mesh.vertexCount * 3)
    for i in 0..(mesh.vertexCount - 1).int:
      var vert = mesh.vertices.offset(i)[].TVector3d
      vertices[i * 3 + 0] = vert.x
      vertices[i * 3 + 1] = vert.y
      vertices[i * 3 + 2] = vert.z
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * vertices.len.int32, vertices[0].addr)
    let pos = glGetAttribLocation(program, "in_position").uint32
    attrib(pos, 3'i32, cGL_FLOAT)

  if (mesh.hasNormals):
    var normals = newSeq[float32](mesh.vertexCount * 3)
    for i in 0..(mesh.vertexCount - 1).int:
      var norm = mesh.normals.offset(i)[].TVector3d
      normals[i * 3 + 0] = norm.x
      normals[i * 3 + 1] = norm.y
      normals[i * 3 + 2] = norm.z
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * normals.len.int32, normals[0].addr)
    let pos = glGetAttribLocation(program, "in_normal").uint32
    attrib(1, 3'i32, cGL_FLOAT)

  if (mesh.hasUVCords):
    var texCoords = newSeq[float32](mesh.vertexCount * 2)
    for i in 0..(mesh.vertexCount - 1).int:
      var uv = mesh.texCoords[0].offset(i)[].TVector3d
      texCoords[i * 2 + 0] = uv.x
      texCoords[i * 2 + 1] = uv.y
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * texCoords.len.int32, texCoords[0].addr)
    let pos = glGetAttribLocation(program, "in_uv").uint32
    attrib(2, 2'i32, cGL_FLOAT)

  return proc() =
    glBindVertexArray(vao)
    glDrawElements(GL_TRIANGLES, triangles.int32, GL_UNSIGNED_INT, nil)


# Returns the proc used to draw the given model file.
proc model*(drawMesh: proc(), texture, program: uint32, trans: ptr Mat4): proc() =
  return proc() =
    glUseProgram(program)
    glUniformMatrix4fv(glGetUniformLocation(program, "model").int32, 1, false, trans[].m[0].addr)
    cameraUniforms(program)

    glBindTexture(GL_TEXTURE_2D, texture)
    drawMesh()


proc compileShader(program: uint32, shdr: uint32, file: string): uint32 =
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
  return program

proc shader*(vertexFile: string, fragmentFile: string): uint32 =
  var program = glCreateProgram()
  discard compileShader(program, glCreateShader(GL_VERTEX_SHADER), "shaders/" & vertexFile)
  discard compileShader(program, glCreateShader(GL_FRAGMENT_SHADER), "shaders/" & fragmentFile)

  glBindFragDataLocation(program, 0, "out_color")
  glLinkProgram(program)
  glUseProgram(program)
  return program

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_CULL_FACE)

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

proc reshape*(width: cint, height: cint) =
  glViewport(0, 0, width, height)
  cameraAspect(width.float / height.float)


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
