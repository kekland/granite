#version 460 core

precision highp float;

#pragma prelude: interpolation
#pragma prelude: shadow-frag

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp float opacity)

in vec4 v_frag_pos_light_space;

out highp vec4 f_color;

void main() {
  #pragma prop: resolve
  float visibility = get_visibility(v_frag_pos_light_space, u_shadow_map);
  visibility = visibility * 0.5 + 0.5;
  f_color = vec4(color.rgb * visibility, color.a) * opacity;
}
