#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;

#pragma prop: declare(bool antialias)
#pragma prop: declare(highp float opacity)
#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)

out vec4 v_frag_pos_light_space;

void main() {
  #pragma prop: resolve
  vec2 translated = position + translate;

  v_frag_pos_light_space = tile_info.light_mvp * vec4(translated, 0.0, 1.0);
  gl_Position = tile_info.mvp * vec4(translated, 0.0, 1.0);
}
