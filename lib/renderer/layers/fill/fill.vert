#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;

#pragma prop: declare(bool antialias)
#pragma prop: declare(highp float opacity)
#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)

out vec3 v_world_position;

void main() {
  #pragma prop: resolve
  vec2 translated = position + translate;
  vec4 world_position = tile_info.model_transform * vec4(translated, 0.0, 1.0);

  v_world_position = world_position.xyz;
  gl_Position = tile_info.mvp * vec4(translated, 0.0, 1.0);
}
