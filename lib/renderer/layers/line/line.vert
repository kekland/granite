#version 460 core

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;
in highp vec2 normal;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(float opacity)
#pragma prop: declare(float width)

out vec4 v_frag_pos_light_space;

void main() {
  #pragma prop: resolve

  // Width is defined in terms of screen pixels, so we need to convert it.
  float local_width = width * tile_info.units_per_pixel;
  vec2 offset = normal * local_width * 0.5;
  vec2 resolved_pos = position + offset;

  v_frag_pos_light_space = tile_info.light_mvp * vec4(resolved_pos, 0.0, 1.0);
  gl_Position = tile_info.mvp * vec4(resolved_pos, 0.0, 1.0);
}
