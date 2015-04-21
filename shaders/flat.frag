#version 130

uniform sampler2D texture;

in vec3 pass_normal;
in vec2 pass_uv;
in vec4 pass_color;

out vec4 out_color;

const vec3 light_dir = normalize(vec3(1.0, -1.0, -1.0));
const vec4 mat_diffuse = vec4(1.0, 1.0, 1.0, 1.0);

void main()
{
  out_color = texture2D(texture, pass_uv);
  out_color = out_color + max(dot(pass_normal, light_dir), 0.0) * mat_diffuse;
}
