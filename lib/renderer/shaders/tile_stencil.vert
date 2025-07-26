#version 460 core

uniform TileStencilInfo {
  mat4 mvp;
} tile_stencil_info;

in highp vec2 position;

void main() {
  gl_Position = tile_stencil_info.mvp * vec4(position, 0.0, 1.0);
}
