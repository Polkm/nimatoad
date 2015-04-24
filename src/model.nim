import entity, opengl, glx, camera, matrix

type Model* = ref object of Entity
  program*: Program
  material*: Material

var models*: seq[ref Model] = @[]

proc draw*(this: ref Model) =
  discard
  # this.program.use()
  # glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  # cameraUniforms(this.program.handle)
  # this.material.use(this.program.handle)
  # mat.use()
  # drawMesh()

proc newModel*(): ref Model =
  let mdl = new Model
  # models.add(mdl)
  # addDraw(proc() = mdl.draw())
  mdl
