#version 460 core

#pragma prelude: interpolation

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(float opacity)
#pragma prop: declare(float width)

out highp vec4 f_color;

void main() {
  #pragma prop: resolve
  f_color = color * opacity;
}
