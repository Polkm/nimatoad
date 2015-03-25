#version 130

in vec3 in_position;
in vec4 in_color;

out vec4 pass_color;

void main()
{
  pass_color = in_color;
  gl_Position = vec4(in_position, 1.0);
}
