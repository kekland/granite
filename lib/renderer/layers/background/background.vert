#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp float opacity)

void main() {
  #pragma prop: resolve(...)
  gl_Position = tile_info.mvp * vec4(position, 0.0, 1.0);
}
