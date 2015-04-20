#version 130

in vec3 in_position;
in vec3 in_normal;
//in vec4 in_color;
//in vec2 in_uv;

out vec3 pass_normal;
//out vec4 pass_color;
//out vec2 pass_uv;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main()
{
  //pass_color = in_color;
  //pass_uv = in_uv;
  gl_Position = proj * view * model * vec4(in_position, 1.0);
  pass_normal = normalize(vec3(view * model * vec4(in_normal, 0.0)));
}
