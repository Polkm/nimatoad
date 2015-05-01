import matrix, vector

type Entity* = object of RootObj
  pos*: Vec3
  angle*: Vec3
  scale*: Vec3
  matrix*: Mat4

var entities*: seq[ref Entity] = @[]

proc newEntity*(): ref Entity = new Entity

# Sarts the tracking of this entity.
method track*(this: ref Entity): ref Entity =
  entities.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: ref Entity) =
  # entities.remove(this)
  discard

# Recalculates the transform matrix.
method calcMatrix(this: ref Entity) =
  this.matrix = identity()
  this.matrix = this.matrix.scale(this.scale)
  this.matrix = this.matrix.rotate(this.angle[0], vec3(1, 0, 0))
  this.matrix = this.matrix.rotate(this.angle[1], vec3(0, 1, 0))
  this.matrix = this.matrix.rotate(this.angle[2], vec3(0, 0, 1))
  this.matrix = this.matrix.translate(this.pos)

# Sets the pos of the entity
method setPos*(this: ref Entity, v: Vec3) =
  this.pos = v
  this.calcMatrix()

# Sets the angle of the entity
method setAngle*(this: ref Entity, a: Vec3) =
  this.angle = a
  this.calcMatrix()

# Sets the scale of the entity
method setScale*(this: ref Entity, s: Vec3) =
  this.scale = s
  this.calcMatrix()

# Initializes this entity.
method init*(this: ref Entity): ref Entity =
  this.pos = vec3(0, 0, 0)
  this.angle = vec3(0, 0, 0)
  this.scale = vec3(1, 1, 1)
  this.calcMatrix()
  this
