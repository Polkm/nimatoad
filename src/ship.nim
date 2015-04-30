import vector, matrix, model, entity

type Ship* = object of Model

var ships*: seq[ref Ship] = @[]

# Sarts the tracking of this entity.
method track*(this: ref Ship): ref Ship =
  discard model.track(this)
  ships.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: ref Ship) =
  model.untrack(this)
  # ships.remove(this)

# Initializes this entity.
method init*(this: ref Ship): ref Ship =
  discard model.init(this)
  this

proc update*(this: ref Ship, dt: float) =
  this.setAngle(this.angle + vec3(0, 50 * dt, 0))
  this.setPos(this.pos + this.matrix.forward() * dt * 10)

proc newShip*(): ref Ship = Ship.new.init.track()
