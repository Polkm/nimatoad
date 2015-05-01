import vector, matrix, model, entity

type Ship* = ref object of Model

var ships* = newSeq[Ship]()

# Sarts the tracking of this entity.
method track*(this: Ship): Ship =
  discard model.track(this)
  ships.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Ship) =
  model.untrack(this)
  # ships.remove(this)

# Initializes this entity.
method init*(this: Ship): Ship =
  discard model.init(this)
  this

method update*(this: Ship, dt: float) =
  procCall this.Entity.update(dt)
  # this.setVel(vec3(1, 0, 0))
  this.setAngle(this.angle + vec3(0, 50 * dt, 0))
  this.setPos(this.pos + this.matrix.forward() * dt * 10)

proc newShip*(): Ship = Ship().init.track()
