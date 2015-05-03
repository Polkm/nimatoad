import opengl, matrix, vector, entity

var pos* = vec3(0, 0.4, 0.6)
var pitch* = 0.0'f32
var yaw* = 180.0'f32
var view* = identity()
var proj* = identity()
var driver*: Entity = nil

proc cameraPoint*(eye, target: Vec3) =
  pos = eye * -1
  # view = lookat(eye = pos, target = target, up = vec3(0.0, 1.0, 0.0))
  echo($view)
# cameraPoint(pos, vec3(0.0, 0.0, 0.0))

proc cameraEye*(eye: Vec3, p, y: float32) =
  # pos = eye * -1
  camera.pitch = p
  camera.yaw = y
  # view = identity().rotate(pitch, vec3(1, 0, 0)) * identity().rotate(yaw, vec3(0, 1, 0)) * identity().translate(pos)
cameraEye(pos, pitch, yaw)

proc moveEyeForward*(amount: float) =
  cameraEye(camera.pos + view.forward() * amount, camera.pitch, camera.yaw)
proc moveEyeSide*(amount: float) =
  cameraEye(camera.pos + view.side() * amount, camera.pitch, camera.yaw)

proc cameraAspect*(aspect: float) =
  proj = perspective(fov = 50.0, aspect = aspect, near = 0.05, far = 10000.0)

proc cameraUniforms*(program: uint32) =
  if (driver != nil):
    # let pPos = driver.pos * -1 + driver.matrix.forward() * 0.55 + driver.matrix.up() * 0.4
    let pPitch = driver.angle[0] + pitch
    let pYaw = -driver.angle[1] + yaw
    let pPos = driver.matrix * pos
    view = identity().rotate(pPitch, vec3(1, 0, 0)) * identity().rotate(pYaw, vec3(0, 1, 0)) * identity().translate(pPos * -1)

  if (program.int != 0):
    glUniformMatrix4fv(glGetUniformLocation(program, "view").int32, 1, false, view.m[0].addr)
    glUniformMatrix4fv(glGetUniformLocation(program, "proj").int32, 1, false, proj.m[0].addr)
    glUniform3f(glGetUniformLocation(program, "camera_pos").int32, pos[0], pos[1], pos[2])
