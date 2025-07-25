#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp float opacity)

out vec3 v_world_position;

void main() {
  #pragma prop: resolve(...)
  vec4 world_position = tile_info.model_transform * vec4(position, 0.0, 1.0);
  v_world_position = world_position.xyz;
  gl_Position = tile_info.mvp * vec4(position, 0.0, 1.0);
}
