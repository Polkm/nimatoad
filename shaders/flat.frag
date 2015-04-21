#version 130

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

uniform vec3 camera_pos = vec3(1, 8, 20);

uniform sampler2D texture;

uniform vec3 light_pos = vec3(5.0, 10.0, 1.0);
uniform vec3 light_ambient = vec3(0.1, 0.1, 0.2);
uniform vec3 light_difuse = vec3(0.9, 0.9, 0.8);
uniform vec3 light_specular = vec3(0.8, 0.8, 0.7);
uniform vec3 mat_ambient = vec3(1.0, 1.0, 1.0);
uniform vec3 mat_diffuse = vec3(1.0, 1.0, 1.0);
uniform vec3 mat_specular = vec3(1.0, 1.0, 1.0);
uniform float mat_ioe = 5;

in vec3 pass_pos;
in vec3 pass_normal;
in vec2 pass_uv;
in vec4 pass_color;

out vec4 out_color;

void main()
{
  vec3 normal = normalize(transpose(inverse(mat3(model))) * pass_normal);
  vec3 surfacePos = vec3(model * vec4(pass_pos, 1));
  vec4 surfaceColor = texture2D(texture, pass_uv);
  vec3 surfaceToLight = normalize(light_pos - surfacePos);
  vec3 surfaceToCamera = normalize(camera_pos - surfacePos);

  //ambient
  vec3 ambient = light_ambient * surfaceColor.rgb * mat_ambient;

  //diffuse
  float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
  vec3 diffuse = diffuseCoefficient * surfaceColor.rgb *  mat_diffuse * light_difuse;

  //specular
  float specularCoefficient = 0.0;
  if(diffuseCoefficient > 0.0)
  specularCoefficient = pow(max(0.0, dot(surfaceToCamera, reflect(-surfaceToLight, normal))), mat_ioe);
  vec3 specular = specularCoefficient * mat_specular * light_specular;

  //attenuation
  float distanceToLight = length(light_pos - surfacePos);
  float attenuation = 1.0; //1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));

  //linear color (color before gamma correction)
  vec3 linearColor = ambient + attenuation * (diffuse + specular);

  //final color (after gamma correction)
  vec3 gamma = vec3(1.0/2.2);
  out_color = vec4(pow(linearColor, gamma), surfaceColor.a);
}
