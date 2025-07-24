uniform Tile {
  highp mat4 local_to_gl;
  highp float size;
  highp float extent;
  highp float opacity;
  highp float zoom;
} tile;

vec4 project_tile_position(vec2 position) {
  return vec4(position.x * tile.size, position.y * tile.size, 0.0, 1.0);
}

vec4 project_tile_position(vec3 position) {
  return vec4(position.x * tile.size, position.y * tile.size, position.z * tile.size, 1.0);
}

float project_pixel_length(float len) {
  return len * tile.size / tile.extent;
}
