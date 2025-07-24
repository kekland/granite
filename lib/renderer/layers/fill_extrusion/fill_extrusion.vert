#version 460 core

precision highp float;

#pragma prelude: tile
#pragma prelude: frame-info
#pragma prelude: interpolation

in highp vec3 position;
in highp vec3 normal;

#pragma prop: declare(highp float opacity)
#pragma prop: declare(highp vec4 color)
#pragma prop: declare(highp vec2 translate)
#pragma prop: declare(highp float height)
#pragma prop: declare(highp float base)

out float temp_height;
out vec3 v_normal;

void main() {
  #pragma prop: resolve
  vec2 translatedPos = position.xy + translate;
  vec3 resolvedPos = vec3(translatedPos, base) + vec3(0.0, 0.0, position.z * height);

  temp_height = position.z;
  v_normal = normal;

  gl_Position = frame_info.camera_transform * frame_info.model_transform * project_tile_position(resolvedPos);
}
