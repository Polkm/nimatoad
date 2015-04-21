import opengl, matrix, vector

var pos = vec3(0, 0, 2)
var view = identity()
var proj = identity()

proc cameraPoint*(eye, target: Vec3) =
  pos = eye
  view = lookat(eye = pos, target = target, up = vec3(0, 1, 0))
cameraPoint(pos, vec3(0, 0, 0))
echo($view)

proc cameraAspect*(aspect: float) =
  proj = perspective(fov = 70.0, aspect = aspect, near = 0.05, far = 10000.0)

proc cameraUniforms*(program: uint32) =
  glUniformMatrix4fv(glGetUniformLocation(program, "view").int32, 1, false, view.m[0].addr)
  glUniformMatrix4fv(glGetUniformLocation(program, "proj").int32, 1, false, proj.m[0].addr)
  glUniform3f(glGetUniformLocation(program, "camera_pos").int32, pos.d[0], pos.d[1], pos.d[2])
