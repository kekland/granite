#version 460 core

precision highp float;

#pragma prelude: interpolation

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp float opacity)

out highp vec4 f_color;

void main() {
  #pragma prop: resolve
  f_color = color * opacity;
}
