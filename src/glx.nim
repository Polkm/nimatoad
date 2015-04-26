import os, times, math, tables, strutils
import opengl, glu, assimp
import matrix, vector, pointer_arithm
import parsers, camera

# var resources* Table[]
var draws*: seq[proc()] = @[]
proc addDraw*(draw: proc()) =
  draws.add(draw)

type Unchecked* {.unchecked.}[T] = array[1, T]

type Resource* = ref object of RootObj
method use*(this: Resource) = discard
method stop*(this: Resource) = discard
method destroy*(this: Resource) = discard

type Program* = ref object of Resource
  handle*: uint32
  uniforms: Table[string, int32]

method use*(this: Program) = glUseProgram(this.handle)

method uniform*(this: Program, name: string): int32 =
  if not this.uniforms.hasKey(name):
    this.uniforms[name] = glGetUniformLocation(this.handle, name)
  return this.uniforms[name]

method stop*(this: Program) = glUseProgram(0)

method destroy*(this: Program) =
  this.stop()
  glDeleteProgram(this.handle)

proc compileShader(program: uint32, shdr: uint32, file: string) =
  var src = readFile(file).cstring
  glShaderSource(shdr, 1, cast[cstringArray](addr src), nil)
  glCompileShader(shdr)
  var status: GLint
  glGetShaderiv(shdr, GL_COMPILE_STATUS, addr status)
  if status != GL_TRUE:
    var buff: array[512, char]
    glGetShaderInfoLog(shdr, 512, nil, buff)
    assert false
  glAttachShader(program, shdr)

proc initProgram*(vertexFile: string, fragmentFile: string): Program =
  result = Program(handle: glCreateProgram(), uniforms: initTable[string, int32]())
  compileShader(result.handle, glCreateShader(GL_VERTEX_SHADER), "shaders/" & vertexFile)
  compileShader(result.handle, glCreateShader(GL_FRAGMENT_SHADER), "shaders/" & fragmentFile)
  glBindFragDataLocation(result.handle, 0, "out_color")
  glLinkProgram(result.handle)
  result.use()
  glUniform1i(glGetUniformLocation(result.handle, "texture"), 0)
  glUniform1i(glGetUniformLocation(result.handle, "normalmap"), 1)

type Material* = ref object of Resource
  texture*: uint32
  normal*: uint32
  ambient*: Vec3
  diffuse*: Vec3
  specular*: Vec3
  shine*: float32

method use*(this: Material, program: Program) =
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, this.texture)
  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, this.normal)
  glActiveTexture(GL_TEXTURE0)
  glUniform3f(program.uniform("mat_ambient"), this.ambient.d[0], this.ambient.d[1], this.ambient.d[2])
  glUniform3f(program.uniform("mat_diffuse"), this.diffuse.d[0], this.diffuse.d[1], this.diffuse.d[2])
  glUniform3f(program.uniform("mat_specular"), this.specular.d[0], this.specular.d[1], this.specular.d[2])
  glUniform1f(program.uniform("mat_shine"), this.shine)

method stop*(this: Material) =
  glBindTexture(GL_TEXTURE_2D, 0)

method destroy*(this: Material) =
  this.stop()
  glDeleteTextures(1, this.texture.addr)
  glDeleteTextures(1, this.normal.addr)

proc initMaterial*(file: string, normalFile: string): Material =
  result = Material(texture: parseBmp(file), normal: parseBmp(normalFile))
  result.ambient = vec3(1.0, 1.0, 1.0)
  result.diffuse = vec3(1.0, 1.0, 1.0)
  result.specular = vec3(1.0, 1.0, 1.0)
  result.shine = 40.0'f32

proc initMaterial*(file: string): Material = initMaterial(file, replace(file, ".bmp", "_normal.bmp"))

type Mesh* = ref object of Resource
  handle*: uint32
  triangles*: int32

method use*(this: Mesh) =
  glBindVertexArray(this.handle)
  glDrawElements(GL_TRIANGLES, this.triangles, GL_UNSIGNED_INT, nil)

method stop*(this: Mesh) = glBindVertexArray(0)

method destroy*(this: Mesh) =
  this.stop()
  glDeleteVertexArrays(1, this.handle.addr)

proc bufferArray*(): uint32 =
  glGenVertexArrays(1, result.addr)
  glBindVertexArray(result)

# Buffers the given data to a VAO and returns it
proc buffer*(kind: GLenum, size: GLsizeiptr, data: ptr): uint32 =
  glGenBuffers(1, result.addr)
  glBindBuffer(kind, result)
  glBufferData(kind, size, data, GL_STATIC_DRAW);

proc attrib*(pos: uint32, size: GLint, kind: GLenum) =
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0'i32, nil)

proc initMesh*(filename: string, program: uint32): Mesh =
  var scene = assimp.aiImportFile(filename, aiProcessPreset_TargetRealtime_Quality)

  # for m in 0..scene.meshCount - 1:
  var mesh = scene.meshes.offset(0)[]

  var vao = bufferArray()
  var triangles = 0'i32;
  if (mesh.hasFaces):
    var indices = newSeq[uint32](mesh.faceCount * 3)
    for i in 0..mesh.faceCount - 1:
      for ii in 0..2:
        indices[i * 3 + ii] = (mesh.faces[i].indices[ii] + 0).uint32
    triangles = indices.len.int32
    discard buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * triangles.int32, indices[0].addr)

  if (mesh.hasPositions):
    var vertices = newSeq[float32](mesh.vertexCount * 3)
    for i in 0..(mesh.vertexCount - 1).int:
      var vert = mesh.vertices.offset(i)[]
      vertices[i * 3 + 0] = vert.x
      vertices[i * 3 + 1] = vert.y
      vertices[i * 3 + 2] = vert.z
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * vertices.len.int32, vertices[0].addr)
    let pos = glGetAttribLocation(program, "in_position").uint32
    attrib(pos, 3'i32, cGL_FLOAT)

  if (mesh.hasNormals):
    var normals = newSeq[float32](mesh.vertexCount * 3)
    for i in 0..(mesh.vertexCount - 1).int:
      var norm = mesh.normals.offset(i)[]
      normals[i * 3 + 0] = norm.x
      normals[i * 3 + 1] = norm.y
      normals[i * 3 + 2] = norm.z
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * normals.len.int32, normals[0].addr)
    # let pos = glGetAttribLocation(program, "in_normal").uint32
    attrib(1, 3'i32, cGL_FLOAT)

  if (mesh.hasUVCords):
    var texCoords = newSeq[float32](mesh.vertexCount * 2)
    for i in 0..(mesh.vertexCount - 1).int:
      var uv = mesh.texCoords[0].offset(i)[]
      texCoords[i * 2 + 0] = uv.x
      texCoords[i * 2 + 1] = uv.y
    discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * texCoords.len.int32, texCoords[0].addr)
    # let pos = glGetAttribLocation(program, "in_uv").uint32
    attrib(2, 2'i32, cGL_FLOAT)

  return Mesh(handle: vao, triangles: triangles)

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_CULL_FACE)

proc drawScene*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

proc reshape*(width: cint, height: cint) =
  glViewport(0, 0, width, height)
  cameraAspect(width.float / height.float)
