#version 150

const vec3 gamma = vec3(1.0 / 2.2);

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

uniform vec3 camera_pos = vec3(0, 0, 0);

uniform sampler2D texture;
uniform sampler2D normalmap;

uniform vec3 light_pos = vec3(0.0, 0.0, 0.0);
uniform vec3 light_ambient = vec3(0.01, 0.01, 0.03);
uniform vec3 light_difuse = vec3(0.9, 0.9, 0.8);
uniform vec3 light_specular = vec3(0.8, 0.8, 0.7);

uniform vec3 mat_ambient = vec3(1.0, 1.0, 1.0);
uniform vec3 mat_diffuse = vec3(1.0, 1.0, 1.0);
uniform vec3 mat_specular = vec3(1.0, 1.0, 1.0);
uniform float mat_shine = 40;

in vec3 pass_pos;
in vec3 pass_normal;
in vec2 pass_uv;
in vec4 pass_color;

out vec4 out_color;

void main()
{
  vec3 mat_pos = vec3(model * vec4(pass_pos, 1));
  vec4 mat_color = texture2D(texture, pass_uv);
  // vec3 n = texture(normalmap, pass_uv);
  vec3 n = normalize((texture2D(normalmap, pass_uv).rgb + pass_normal) * 2.0 - 1.0);
  vec3 mat_normal = normalize(transpose(inverse(mat3(model))) * n);
  vec3 camera_dir = normalize(camera_pos - mat_pos);
  vec3 light_dir = normalize(light_pos - mat_pos);

  // Ambient
  vec3 ambient = mat_color.rgb * mat_ambient * light_ambient;

  // Diffuse
  float diffuse_dot = max(0.0, dot(mat_normal, light_dir));
  vec3 diffuse = diffuse_dot * mat_color.rgb *  mat_diffuse * light_difuse;

  // Specular
  float specular_r = 0.0;
  if (diffuse_dot > 0.0)
    specular_r = pow(max(0.0, dot(camera_dir, reflect(-light_dir, mat_normal))), mat_shine);
  vec3 specular = specular_r * mat_specular * light_specular;

  // Attenuation
  // float distanceToLight = length(light_pos - mat_pos);
  float attenuation = 1.0; //1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));

  // Linear color (color before gamma correction)
  vec3 color_linear = ambient + (diffuse + specular) * attenuation;

  // Final color (after gamma correction)
  // out_color = vec4(1);
  out_color = vec4(pow(color_linear, gamma), mat_color.a);
}
