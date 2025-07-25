#version 460 core

uniform sampler2D u_shadow_map;

in vec3 v_position;
in vec3 v_normal;
in vec3 v_viewvector; // camera_position - vertex_position
in vec2 v_texture_coords;
in vec4 v_color;
in vec4 v_frag_pos_light_space;
out vec4 f_color;

void main() {
  vec3 proj_light_coords = v_frag_pos_light_space.xyz / v_frag_pos_light_space.w;
  proj_light_coords.x = proj_light_coords.x * 0.5 + 0.5; // convert from [-1, 1] to [0, 1]
  proj_light_coords.y = proj_light_coords.y * 0.5 + 0.5; // convert from [-1, 1] to [0, 1]
  proj_light_coords.z = proj_light_coords.z;

  float current_depth = proj_light_coords.z;
  float closest_depth = texture(u_shadow_map, vec2(proj_light_coords.x, 1.0 - proj_light_coords.y)).r;
  float visibility = current_depth - 0.0025 > closest_depth ? 0.0 : 1.0;

  f_color = vec4(vec3(1.0), 1.0) * (visibility * 0.25 + 0.75);
}
