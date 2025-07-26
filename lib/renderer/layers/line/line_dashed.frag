#version 460 core

#pragma prelude: interpolation
#pragma prelude: shadow-frag

uniform DasharrayInfo {
  highp vec2 texture_size;
} dasharray_info;

uniform sampler2D u_dasharray;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(float opacity)
#pragma prop: declare(float width)

in float v_line_length;
in vec4 v_frag_pos_light_space;

out highp vec4 f_color;

void main() {
  #pragma prop: resolve

  // Shadows
  float visibility = get_visibility(v_frag_pos_light_space, u_shadow_map);
  visibility = visibility * 0.5 + 0.5;

  // Dash pattern
  float line_position = v_line_length / width;
  float dash_value = texture(u_dasharray, vec2(line_position / dasharray_info.texture_size.x, 0.5)).r;
  if (dash_value < 0.5) discard;

  f_color = vec4(color.rgb * visibility, color.a) * opacity;
}
