#version 460 core

precision highp float;

#pragma prelude: tile-info
#pragma prelude: interpolation

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)
#pragma prop: declare(highp float height)
#pragma prop: declare(highp float base)

in vec3 v_position;
in vec3 v_normal;

out highp vec4 f_color;

void main() {
  #pragma prop: resolve(...)

  // Lights
  vec3 light_color = tile_info.light_color.rgb;
  float light_intensity = tile_info.light_intensity;

  // Ambient occlussion based on the distance from ground
  float ao_intensity = clamp((24.0 - v_position.z) / 24.0, 0.0, 1.0) * 0.125;

  // No AO on the floors/roofs
  ao_intensity *= 1.0 - abs(v_normal.z);
  vec3 ao = vec3(ao_intensity);

  float diffuse_amount = max(dot(v_normal, tile_info.light_direction), 0.0);
  vec3 ambient = light_color * light_intensity * 0.5;
  vec3 diffuse = light_color * light_intensity * diffuse_amount;
  vec4 light = vec4(ambient + diffuse - ao, 1.0);

  vec4 result_color = color * light;
  f_color = result_color;
}
