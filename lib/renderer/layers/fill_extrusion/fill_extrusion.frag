#version 460 core

precision highp float;

#pragma prelude: interpolation

#pragma prop: declare(highp float opacity)
#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)
#pragma prop: declare(highp float height)
#pragma prop: declare(highp float base)

in float temp_height;
in vec3 v_normal;
out highp vec4 f_color;

void main() {
  #pragma prop: resolve(...)
  f_color = vec4(v_normal * 0.5 + 0.5, 1.0);
}
