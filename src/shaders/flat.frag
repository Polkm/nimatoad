#version 130

in vec3 pass_normal;
//in vec4 pass_color;

out vec4 out_color;

void main()
{
  out_color = vec4(pass_normal.xyz, 1);
}
