layout (std140) uniform TileInfo {
  // transforms and camera
  mat4 mvp;
  mat4 camera_transform;
  mat4 model_transform;
  mat4 screen_to_clip_transform;
  mat4 clip_to_screen_transform;
  vec3 camera_position;

  // light
  vec3 light_direction;
  float light_intensity;
  vec4 light_color;
  mat4 light_mvp;

  // other data
  float units_per_pixel;
  float zoom;
} tile_info;
