import vector, matrix, model, entity
import math

type Ship* = ref object of Model
  throttle: float
  throttling*: bool
  reverse*: bool
  righting*: bool
  lefting*: bool
  upping*: bool
  downing*: bool
  yawttle: float
  pitchle: float


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
  this.throttle = 0.0
  this.throttling = false
  this.reverse = false
  this.righting = false
  this.lefting = false
  this.yawttle = 0.0
  this

method update*(this: Ship, dt: float) =
  procCall this.Entity.update(dt)
  # this.setVel(vec3(1, 0, 0))
  # this.setAngle(this.angle + vec3(0, 50 * dt, 0))
  # this.setPos(this.pos + this.matrix.forward() * dt * 10)
  if (this.throttling): this.throttle += 10.0 * dt
  else: this.throttle = max(this.throttle - 20.0 * dt, 0.0)
  let yaw = this.angle[1] * PI / 180.0 - PI * 0.5
  # this.setVel(vec3(cos(yaw), 0, sin(-yaw)) * this.throttle)
  this.setVel(vec3(this.matrix[8], this.matrix[9], this.matrix[10]) * this.throttle)

  if (this.righting and not this.lefting): this.yawttle -= 40.0 * dt
  elif (this.lefting and not this.righting): this.yawttle += 40.0 * dt
  else: this.yawttle = this.yawttle * min(40 * dt, 1.0)

  if (this.upping and not this.downing): this.pitchle -= 40.0 * dt
  elif (this.downing and not this.upping): this.pitchle += 40.0 * dt
  else: this.pitchle = (0.0 - this.pitchle) * dt * 0.1

  this.setAngleVel(vec3(this.pitchle, this.yawttle, 0))

proc newShip*(): Ship = Ship().init.track()
