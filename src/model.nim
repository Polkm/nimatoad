import entity, opengl, glx, camera, matrix
import vector

type Model* = ref object of Entity
  program*: Program
  material*: Material
  mesh*: Mesh

var models*: seq[Model] = @[]

method draw*(this: Model) =
  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)
  this.material.use(this.program)
  this.mesh.use()

# Sarts the tracking of this entity.
method track*(this: Model): Model =
  discard entity.track(this)
  models.add(this)
  addDraw(proc() = this.draw())
  this

# Stops the tracking of this entity.
method untrack*(this: Model) =
  entity.untrack(this)
  # models.remove(this)

# Initializes this entity.
method init*(this: Model): Model =
  discard entity.init(this)
  this

# method update*(this: Model, dt: float) =
#   procCall entity.update(this, dt)

proc newModel*(): Model = Model().init.track()
