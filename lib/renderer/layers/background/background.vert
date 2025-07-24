#version 460 core

precision highp float;

#pragma prelude: tile
#pragma prelude: frame-info
#pragma prelude: interpolation

in highp vec2 position;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp float opacity)

void main() {
  #pragma prop: resolve(...)
  gl_Position = frame_info.camera_transform * frame_info.model_transform * project_tile_position(position);
}
