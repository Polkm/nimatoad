#version 130

in vec3 pass_normal;
in vec2 pass_uv;
//in vec4 pass_color;

out vec4 out_color;

void main()
{
  // out_color = vec4(pass_uv.xy, 1, 1);
  out_color = vec4(pass_uv.xy, 1, 1);
}