#version 460 core

in vec2 position;
in vec2 texCoord;

out vec2 v_texCoord;

void main() {
  gl_Position = vec4(position, 0.0, 1.0);
  v_texCoord = texCoord;
}