import math, complex

type Vec3* = object
  d*: array[3, float]

proc vec3*(x, y, z: float): Vec3 =
  result = Vec3()
  result.d = [x, y, z]

proc vec3*(v: Vec3): Vec3 =
  result = Vec3()
  result.d = v.d

proc `$`*(v: Vec3): string = "(" & $v.d[0] & ", " & $v.d[1] & ", " & $v.d[2] & ")"
proc `==`*(a, b: Vec3): bool = a.d[0] == b.d[0] and a.d[1] == b.d[1] and a.d[2] == b.d[2]
proc `+`*(a, b: Vec3): Vec3 = vec3(a.d[0] + b.d[0], a.d[1] + b.d[1], a.d[2] + b.d[2])
proc `-`*(a, b: Vec3): Vec3 = vec3(a.d[0] - b.d[0], a.d[1] - b.d[1], a.d[2] - b.d[2])
proc `*`*(a, b: Vec3): Vec3 = vec3(a.d[0] * b.d[0], a.d[1] * b.d[1], a.d[2] * b.d[2])
proc `/`*(a, b: Vec3): Vec3 = vec3(a.d[0] / b.d[0], a.d[1] / b.d[1], a.d[2] / b.d[2])

proc length2*(v: Vec3): float = v.d[0] * v.d[0] + v.d[1] * v.d[1] + v.d[2] * v.d[2]
proc length*(v: Vec3): float = sqrt(v.length2())

proc normal*(v: Vec3): Vec3 =
  let len = length(v)
  if (len == 0): vec3(0.0, 0.0, 0.0)
  else: vec3(v.d[0] / len, v.d[1] / len, v.d[2] / len)

proc dot*(a, b: Vec3): float = a.d[0] * b.d[0] + a.d[1] * b.d[1] + a.d[2] * b.d[2]
proc normDot(a, b: Vec3): float = dot(normal(a), normal(b))

proc cross*(a, b: Vec3): Vec3 = vec3(
  a.d[1]*b.d[2] - a.d[2]*b.d[1],
  a.d[2]*b.d[0] - a.d[0]*b.d[2],
  a.d[0]*b.d[1] - a.d[1]*b.d[0])

when isMainModule:
  proc test(cond: bool, name: string) =
    if (cond): echo("  PASSED: " & name)
    else: echo("FAILED: " & name)
    # assert(cond, name)
  proc testEqual(value, expected, name) =
    test(value == expected, $name & " expected " & $expected & " got " & $value)

  block:
    let a = vec3(1.2, 2.4, 3.6)
    test(a.d[0] == 1.2 and a.d[1] == 2.4 and a.d[2] == 3.6, "vec3 constructor sets value")

  block:
    let a = vec3(1.0, 0.0, 0.0)
    let b = vec3(0.0, 0.0, 0.0)
    testEqual(length(a), 1.0, "vec3 unit length")
    testEqual(length(b), 0.0, "vec3 zero length")

  block:
    let a = vec3(2.0, 1.0, 0.5)
    testEqual(length(normal(a)), 1.0, "vec3 normal length")

  block:
    testEqual(normDot(vec3(1, 1, 0), vec3(1, 1, 0)).float32, 1.0'f32, "vec3 dot parallel positive")
    testEqual(normDot(vec3(1, 1, 0), vec3(-1, -1, 0)).float32, -1.0'f32, "vec3 dot parallel negative")

  block:
    testEqual(cross(vec3(1, 0, 0), vec3(0, 1, 0)), vec3(0, 0, 1), "vec3 cross")
