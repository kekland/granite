#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec2 position;
in highp vec2 anchor;
in highp vec2 uv;

#pragma prop: declare(highp vec4 text_color)
#pragma prop: declare(float text_opacity)
#pragma prop: declare(highp vec4 text_halo_color)
#pragma prop: declare(float text_halo_width)

out highp vec2 v_uv;

void main() {
  #pragma prop: resolve
  
  vec4 clip_position = tile_info.mvp * vec4(anchor, 0.0, 1.0);
  vec2 screen_position = (tile_info.clip_to_screen_transform * vec4(clip_position.xy / clip_position.w, 0.0, 1.0)).xy;
  screen_position = screen_position + position;

  gl_Position = tile_info.screen_to_clip_transform * vec4(screen_position, 0.0, 1.0);
  v_uv = uv;
}

