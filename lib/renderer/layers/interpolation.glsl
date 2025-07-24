#define prop_crossfade(a, b) mix(a, b, tile.zoom - floor(tile.zoom))

#define prop_step(start_value, end_value, start_stop, end_stop) \
  mix(start_value, end_value, step(end_stop, tile.zoom))

#define prop_interpolate(start_value, end_value, start_stop, end_stop) \
  mix(start_value, end_value, prop_interpolate_factor(1.0, start_stop, end_stop, tile.zoom))

#define prop_interpolate_exponential(base, start_value, end_value, start_stop, end_stop) \
  mix(start_value, end_value, prop_interpolate_factor(base, start_stop, end_stop, tile.zoom))

float prop_interpolate_factor(
  float base,
  float start_stop,
  float end_stop,
  float t
) {
  float difference = end_stop - start_stop;
  float progress = t - start_stop;

  if (difference == 0.0) return 0.0;
  else if (base == 1.0) return progress / difference;
  else return (pow(base, progress) - 1.0) / (pow(base, difference) - 1.0);
}
