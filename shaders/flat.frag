#version 130

uniform vec3 camera_pos = vec3(1, 8, 20);

uniform sampler2D texture;

uniform vec3 light_dir = normalize(vec3(5.0, 10.0, 1.0));
uniform vec4 light_ambient = vec4(0.1, 0.1, 0.2, 1.0);
uniform vec4 light_difuse = vec4(0.9, 0.9, 0.8, 1.0);
uniform vec4 light_specular = vec4(0.8, 0.8, 0.7, 1.0);
uniform vec4 mat_ambient = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 mat_diffuse = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 mat_specular = vec4(1.0, 1.0, 1.0, 1.0);
uniform float mat_ioe = 5;

in vec3 pass_pos;
in vec3 pass_normal;
in vec2 pass_uv;
in vec4 pass_color;

out vec4 out_color;

void main()
{
  out_color = texture2D(texture, pass_uv);
  // Ambient
  out_color = out_color + mat_ambient * light_ambient;
  // Diffuse
  out_color = out_color + max(dot(pass_normal, light_dir), 0.0) * mat_diffuse * light_difuse;
  // Specular
  float R = pow(max(0.0, dot(normalize(camera_pos - pass_pos), reflect(-light_dir, pass_normal))), mat_ioe);
  out_color = out_color + R * mat_specular * light_specular;




  // vec3 normal = normalize(transpose(inverse(mat3(model))) * fragNormal);
  // vec3 surfacePos = vec3(model * vec4(fragVert, 1));
  // vec4 surfaceColor = texture(materialTex, fragTexCoord);
  // vec3 surfaceToLight = normalize(light.position - surfacePos);
  // vec3 surfaceToCamera = normalize(cameraPosition - surfacePos);
  //
  // //ambient
  // vec3 ambient = light.ambientCoefficient * surfaceColor.rgb * light.intensities;
  //
  // //diffuse
  // float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
  // vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
  //
  // //specular
  // float specularCoefficient = 0.0;
  // if(diffuseCoefficient > 0.0)
  // specularCoefficient = pow(max(0.0, dot(surfaceToCamera, reflect(-surfaceToLight, normal))), materialShininess);
  // vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
  //
  // //attenuation
  // float distanceToLight = length(light.position - surfacePos);
  // float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
  //
  // //linear color (color before gamma correction)
  // vec3 linearColor = ambient + attenuation*(diffuse + specular);
  //
  // //final color (after gamma correction)
  // vec3 gamma = vec3(1.0/2.2);
  // finalColor = vec4(pow(linearColor, gamma), surfaceColor.a);
}
