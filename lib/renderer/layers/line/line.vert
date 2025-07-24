#version 460 core

#pragma prelude: tile
#pragma prelude: frame-info
#pragma prelude: interpolation

in highp vec2 position;
in highp vec2 normal;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(float opacity)
#pragma prop: declare(float width)

void main() {
  #pragma prop: resolve

  // Width is defined in terms of screen pixels, so we need to convert it.
  float local_width = width * (tile.extent / tile.size);
  vec2 offset = normal * local_width * 0.5;
  gl_Position = frame_info.camera_transform * frame_info.model_transform * project_tile_position(position + offset);
}
