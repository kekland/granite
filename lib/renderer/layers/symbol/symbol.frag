#version 460 core

precision highp float;

#pragma prelude: interpolation

uniform sampler2D u_glyph_atlas_texture;

#pragma prop: declare(highp vec4 text_color)
#pragma prop: declare(float text_opacity)
#pragma prop: declare(highp vec4 text_halo_color)
#pragma prop: declare(float text_halo_width)

in highp vec2 v_uv;

out highp vec4 f_color;

const float inner_edge = 0.75;
const float smoothing = 1.0 / 16.0;

void main() {
  #pragma prop: resolve

  float scaled_halo_width = text_halo_width / 6.0;
  float halo_edge = inner_edge - scaled_halo_width;

  float dist = texture(u_glyph_atlas_texture, v_uv).r;
  float text_alpha = smoothstep(inner_edge - smoothing, inner_edge + smoothing, dist);
  float halo_alpha = smoothstep(halo_edge - smoothing, halo_edge + smoothing, dist);

  vec4 mixed_color = mix(text_halo_color, text_color, text_alpha);
  f_color = mixed_color * text_opacity * halo_alpha;
}
