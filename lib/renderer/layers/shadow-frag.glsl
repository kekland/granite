uniform sampler2D u_shadow_map;

float get_visibility(vec4 v_frag_pos_light_space, sampler2D u_shadow_map) {
  vec3 proj = v_frag_pos_light_space.xyz / v_frag_pos_light_space.w;
  if (proj.z <= 0.0 || proj.z >= 1.0) return 1.0;

  vec2 uv = proj.xy * 0.5 + 0.5;
  uv.y = 1.0 - uv.y;

  vec2 texel = 1.0 / vec2(2048);

  // biasing
  float slope = max(abs(dFdx(proj.z)), abs(dFdy(proj.z)));
  float min_bias = 0.00195;
  float slope_scale = 0.0005;
  float bias = max(min_bias, slope * slope_scale);

  // PCF
  float result = 0.0;
  const int K = 1;
  int taps = 0;

  for (int y = -K; y <= K; ++y)
  for (int x = -K; x <= K; ++x) {
      vec2 offset = vec2(x, y) * texel;
      float closest = texture(u_shadow_map, uv + offset).r;
      float lit = (proj.z - bias > closest) ? 0.0 : 1.0;
      result += lit;
      taps++;
  }

  return result / float(taps);
}