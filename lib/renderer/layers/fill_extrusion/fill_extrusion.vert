#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

in highp vec3 position;
in highp vec3 normal;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)
#pragma prop: declare(highp float height)
#pragma prop: declare(highp float base)

out vec3 v_position;
out vec3 v_normal;
out vec4 v_frag_pos_light_space;

void main() {
  #pragma prop: resolve
  vec2 translated_pos = position.xy + translate;
  vec3 resolved_pos = vec3(translated_pos.xy, base) + vec3(0.0, 0.0, position.z * height);

  v_position = resolved_pos;
  v_normal = normal;
  v_frag_pos_light_space = tile_info.light_mvp * vec4(resolved_pos, 1.0);
  gl_Position = tile_info.mvp * vec4(resolved_pos, 1.0);
}
