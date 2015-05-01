#version 150

const vec3 gamma = vec3(1.0 / 2.2);

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

uniform sampler2D texture;

in vec3 pass_pos;
in vec3 pass_normal;
in vec2 pass_uv;
in vec4 pass_color;

out vec4 out_color;

void main()
{
  out_color = texture2D(texture, pass_uv);
}
