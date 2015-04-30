import entity, opengl, glx, camera, matrix

type Model* = object of Entity
  program*: Program
  material*: Material
  mesh*: Mesh

var models*: seq[ref Model] = @[]

method draw*(this: ref Model) =
  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)
  this.material.use(this.program)
  this.mesh.use()

# Sarts the tracking of this entity.
method track*(this: ref Model): ref Model =
  discard entity.track(this)
  models.add(this)
  addDraw(proc() = this.draw())
  this

# Stops the tracking of this entity.
method untrack*(this: ref Model) =
  entity.untrack(this)
  # models.remove(this)

# Initializes this entity.
method init*(this: ref Model): ref Model =
  discard entity.init(this)
  this

proc newModel*(): ref Model =
  Model.new.init.track()
