import math
import sequtils
import sdl2

const
  width  = 1280
  height = 720
  fov    = 45.0
  max_depth = 6

type
  TVec3 = array[3,float]
  TRay {.pure, final.} = object
    start: TVec3
    dir: TVec3
  TSphere {.pure, final.} = object
    center : TVec3
    radius : float
    color : TVec3
    reflection: float
    transparency: float
  TLight {.pure, final.} = object
    position: TVec3
    color: TVec3
  TScene {.pure, final.} = object
    objects: seq[ref TSphere]
    lights: seq[ref TLight]


proc newRay(start, dir: TVec3): TRay {.noInit, inline.} =
  result.start = start
  result.dir = dir

template newVec3(x: float): TVec3 = [x.float,x,x]

proc newLight(position, color: TVec3): ref TLight =
  new result
  result.position = position
  result.color = color

template `-` (me: TVec3): TVec3 = [-me[0], -me[1], -me[2]]

template declOpBinary(op: expr) =

    proc op(me, rhs: TVec3): TVec3 {.inline, noInit.} = [op(me[0], rhs[0]), op(me[1], rhs[1]), op(me[2], rhs[2])]

    proc op(me: TVec3, rhs: float): TVec3 {.inline, noInit.} = [op(me[0], rhs), op(me[1], rhs), op(me[2], rhs)]

template declOpBinaryAssign(op: expr) =

    proc op(me: var TVec3, rhs: TVec3) {.inline.} =
      op(me[0], rhs[0])
      op(me[1], rhs[1])
      op(me[2], rhs[2])

    proc op(me: var TVec3, rhs: float) {.inline.} =
      op(me[0], rhs)
      op(me[1], rhs)
      op(me[2], rhs)

declOpBinary(`+`)
declOpBinary(`-`)
declOpBinary(`*`)
declOpBinary(`/`)
declOpBinaryAssign(`+=`)
declOpBinaryAssign(`-=`)
declOpBinaryAssign(`*=`)
declOpBinaryAssign(`/=`)

proc dot(v1, v2: TVec3): float {.inline.} = v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2]

proc magnitude(v: TVec3) : float {.inline.} = sqrt(dot(v,v))

proc normalize(v: TVec3): TVec3 {.inline, noInit.} =
  let m = v.magnitude()
  return [v[0] / m, v[1] / m, v[2] / m]

proc newSphere(center: TVec3, radius: float, color: TVec3, reflection: float = 0.0, transparency: float = 0.0): ref TSphere =
  new(result)
  result.center = center
  result.radius = radius
  result.color = color
  result.reflection = reflection
  result.transparency = transparency

proc normalize(me: ref TSphere, v: TVec3): TVec3 {.inline, noInit.} = normalize(v - me.center)

template intersectImpl(me: ref TSphere, ray: expr) : expr {.immediate, dirty.} =

  var vl = me.center - ray.start
  var a = dot(vl, ray.dir)
  if (a < 0) :             # opposite direction
    return false
  var b2 = dot(vl, vl) - a * a
  var r2 = me.radius * me.radius
  if (b2 > r2) :           # perpendicular > r
    return false

proc intersect(me: ref TSphere, ray: TRay) : bool {.inline.} =
  intersectImpl(me, ray)
  return true

proc intersect(me: ref TSphere, ray: TRay, distance: var float) : bool {.inline.} =
  intersectImpl(me, ray)
  var c = sqrt(r2 - b2)
  var near = a - c
  var far  = a + c
  distance = if (near < 0) : far else : near
  return true


proc trace(ray: TRay, scene: TScene, depth: int): TVec3 =
  var nearest = 99999999999999.0
  var obj : ref TSphere

  # // search the scene for nearest intersection
  for o in scene.objects :
    var distance = 99999999999999.0
    if o.intersect(ray, distance) :
      if distance < nearest :
        nearest = distance
        obj = o

  if obj.isNil : return #newVec3(0)

  var point_of_hit = ray.dir * nearest
  point_of_hit += ray.start
  var normal = obj.normalize(point_of_hit)
  var inside = false

  var dot_normal_ray = dot(normal, ray.dir)
  if dot_normal_ray > 0 :
    inside = true
    normal = -normal
    dot_normal_ray = -dot_normal_ray

  #result = newVec3(0.0)
  var reflection_ratio = obj.reflection

  let normE5 = normal * 1.0e-5
  for lgt in scene.lights :

    let light_direction = normalize(lgt.position - point_of_hit)
    let r = newRay(point_of_hit + normE5, light_direction)

    # go through the scene check whether we're blocked from the lights

    var blocked = false
    for it in scene.objects:
      blocked = it.intersect(r)
      if blocked: break

    if not blocked :
      when true :
        var temp = lgt.color
        temp *= max(0.0, dot(normal, light_direction))
        temp *= obj.color
        temp *= (1.0 - reflection_ratio)
        result += temp
      else :
        result += lgt.color *
          max(0.0, dot(normal, light_direction)) *
          obj.color * (1.0 - reflection_ratio)


  var facing = max(0.0, - dot_normal_ray)
  var fresneleffect = reflection_ratio + (1.0 - reflection_ratio) * pow((1.0 - facing), 5.0)

  # compute reflection
  if depth < max_depth and reflection_ratio > 0 :
      var reflection_direction = ray.dir - normal * 2.0 * dot_normal_ray
      var reflection = trace(newRay(point_of_hit + normE5, reflection_direction), scene, depth + 1)
      result += reflection * fresneleffect


  # compute refraction
  if depth < max_depth and (obj.transparency > 0.0) :
    var ior = 1.5
    let CE = ray.dir.dot(normal) * -1.0
    ior = if inside : 1.0 / ior else: ior
    let eta = 1.0 / ior
    let GF = (ray.dir + normal * CE) * eta
    let sin_t1_2 = 1.0 - CE * CE
    let sin_t2_2 = sin_t1_2 * (eta * eta)
    if sin_t2_2 < 1.0 :
        let GC = normal * sqrt(1 - sin_t2_2)
        let refraction_direction = GF - GC
        let refraction = trace(newRay(point_of_hit - normal * 1.0e-4, refraction_direction),
                                scene, depth + 1)
        result += refraction * (1.0 - fresneleffect) * obj.transparency


proc render (scene: TScene, surface: PSurface) =
  discard LockSurface(surface)

  let eye = newVec3(0.0)
  var h = tan(fov / 360.0 * 2.0 * PI / 2.0) * 2.0
  var
    w = h * width.float / height.float
  const
    ww = width.float
    hh = height.float

  for y in 0 .. < height :
    let yy = y.float
    var row: ptr int32 = cast[ptr int32](cast[TAddress](surface.pixels) + surface.pitch.int32 * y)
    for x in 0 .. < width :
      let xx = x.float

      var dir = normalize([(xx - ww / 2.0) / ww  * w,
                           (hh/2.0 - yy) / hh * h,
                           -1.0])
      let pixel = trace(newRay(eye, dir), scene, 0)
      #macFor x -> [0,1,2], col -> [r,g,b] :
      let r = min(255, round(pixel[0] * 255.0)).uint8
      let g = min(255, round(pixel[1] * 255.0)).uint8
      let b = min(255, round(pixel[2] * 255.0)).uint8
      #auto rgb = map!("cast(ubyte)min(255, a*255+0.5)")(pixel[]);
      row[] = mapRGB(surface.format, r, g, b).int32
      row = cast[ptr int32](cast[TAddress](row) + sizeof(int32))
  UnlockSurface(surface)
  # UpdateRect(surface, 0, 0, 0, 0)

proc test() =
  if init(INIT_VIDEO) != 0.SDL_Return:
    quit "SDL failed to initialize!"

  var screen = CreateWindow("My Game Window",
                          SDL_WINDOWPOS_UNDEFINED,
                          SDL_WINDOWPOS_UNDEFINED,
                          width, height,
                          SDL_WINDOW_FULLSCREEN and SDL_WINDOW_OPENGL)
  var renderer: Renderer = CreateRenderer(screen, , )

  # var screen = SetVideoMode(width, height, 32, SWSURFACE or ANYFORMAT)
  if screen.isNil:
    quit($sdl2.getError())
  var scene: TScene
  scene.objects = @[newSphere([0.0, -10002.0, -20.0], 10000.0, [0.8, 0.8, 0.8]),
           newSphere([0.0, 2.0, -20.0], 4.0, [0.8, 0.5, 0.5], 0.5),
           newSphere([5.0, 0.0, -15.0], 2.0, [0.3, 0.8, 0.8], 0.2),
           newSphere([-5.0, 0.0, -15.0], 2.0, [0.3, 0.5, 0.8], 0.2),
           newSphere([-2.0, -1.0, -10.0], 1.0, [0.1, 0.1, 0.1], 0.1, 0.8)]
  scene.lights = @[newLight([-10.0, 20.0, 30.0], [2.0, 2.0, 2.0]) ]
  render(scene, screen)

when isMainModule :

  import benchmark

  bench("duration"):
    test()
  #discard stdin.readline
