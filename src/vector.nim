import math, complex

type Vec3* = object
  d: array[3, float]

proc vec3*(x, y, z: float): Vec3 =
  result = Vec3()
  result.d = [x, y, z]
