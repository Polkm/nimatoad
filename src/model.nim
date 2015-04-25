import entity, opengl, glx, camera, matrix

type Model* = object of Entity
  program*: Program
  material*: Material
  mesh*: Mesh

var models*: seq[ref Model] = @[]

proc draw*(this: ref Model, ) =
  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)
  this.material.use()
  this.mesh.use()

proc newModel*(): ref Model =
  let mdl = Model.new
  mdl.matrix = identity()
  models.add(mdl)
  addDraw(proc() = mdl.draw())
  mdl
