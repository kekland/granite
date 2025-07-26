uniform sampler2D u_shadow_map;

float get_visibility(vec4 v_frag_pos_light_space, sampler2D u_shadow_map, float bias) {
  vec3 proj_light_coords = v_frag_pos_light_space.xyz / v_frag_pos_light_space.w;
  proj_light_coords.x = proj_light_coords.x * 0.5 + 0.5; // convert from [-1, 1] to [0, 1]
  proj_light_coords.y = proj_light_coords.y * 0.5 + 0.5; // convert from [-1, 1] to [0, 1]
  proj_light_coords.z = proj_light_coords.z;

  float current_depth = proj_light_coords.z;
  float closest_depth = texture(u_shadow_map, vec2(proj_light_coords.x, 1.0 - proj_light_coords.y)).r;
  float visibility = current_depth - bias > closest_depth ? 0.0 : 1.0;
  if (proj_light_coords.z > 1.0) visibility = 1.0;
  if (proj_light_coords.z < 0.0) visibility = 1.0;

  return visibility;
}