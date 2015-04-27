import math, complex

type Vec3* = object
  d*: array[3, float]

proc vec3*(x, y, z: float): Vec3 =
  result = Vec3()
  result.d = [x, y, z]

proc vec3*(v: Vec3): Vec3 =
  result = Vec3()
  result.d = v.d

proc `[]`*(v: Vec3, i: int): float = v.d[i]
proc `[]=`*(v: var Vec3, i: int, x: float) = v.d[i] = x
proc `==`*(a, b: Vec3): bool = a[0] == b[0] and a[1] == b[1] and a[2] == b[2]
proc `!=`*(a, b: Vec3): bool = a[0] != b[0] or a[1] != b[1] or a[2] != b[2]
proc `+=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] + b[0]
  a[1] = a[1] + b[1]
  a[2] = a[2] + b[2]
proc `-=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] - b[0]
  a[1] = a[1] - b[1]
  a[2] = a[2] - b[2]
proc `*=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] * b[0]
  a[1] = a[1] * b[1]
  a[2] = a[2] * b[2]
proc `*=`*(a: var Vec3, s: float) =
  a[0] = a[0] * s
  a[1] = a[1] * s
  a[2] = a[2] * s
proc `/=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] / b[0]
  a[1] = a[1] / b[1]
  a[2] = a[2] / b[2]
proc `/=`*(a: var Vec3, s: float) =
  a[0] = a[0] / s
  a[1] = a[1] / s
  a[2] = a[2] / s
proc `+`*(a, b: Vec3): Vec3 = vec3(a[0] + b[0], a[1] + b[1], a[2] + b[2])
proc `-`*(a, b: Vec3): Vec3 = vec3(a[0] - b[0], a[1] - b[1], a[2] - b[2])
proc `*`*(a, b: Vec3): Vec3 = vec3(a[0] * b[0], a[1] * b[1], a[2] * b[2])
proc `/`*(a, b: Vec3): Vec3 = vec3(a[0] / b[0], a[1] / b[1], a[2] / b[2])
proc `$`*(v: Vec3): string = "(" & $v[0] & ", " & $v[1] & ", " & $v[2] & ")"
proc `&`*(s: string, v: Vec3): string = s & $v
proc `&`*(v: Vec3, s: string): string = $v & s

proc length2*(v: Vec3): float = v[0] * v[0] + v[1] * v[1] + v[2] * v[2]
proc length*(v: Vec3): float = sqrt(v.length2())

proc normalize*(v: var Vec3) =
  let len = v.length
  if (len != 0):
    v /= len
proc normal*(v: Vec3): Vec3 =
  let len = length(v)
  if (len == 0): vec3(0.0, 0.0, 0.0)
  else: vec3(v[0] / len, v[1] / len, v[2] / len)

proc dot*(a, b: Vec3): float = a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
proc normDot(a, b: Vec3): float = dot(normal(a), normal(b))

proc cross*(a, b: Vec3): Vec3 = vec3(
  a[1]*b[2] - a[2]*b[1],
  a[2]*b[0] - a[0]*b[2],
  a[0]*b[1] - a[1]*b[0])

when isMainModule:
  proc test(cond: bool, name: string) =
    if (cond): echo("  PASSED: " & name)
    else: echo("FAILED: " & name)
    # assert(cond, name)
  proc testEqual(value, expected, name) =
    test(value == expected, $name & " expected " & $expected & " got " & $value)

  block:
    test(vec3(1.2, 2.4, 3.6) == vec3(1.2, 2.4, 3.6), "vec3 equality")
    test(vec3(1.2, 2.4, 3.6) != vec3(3.6, 2.4, 1.2), "vec3 not equality")

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
