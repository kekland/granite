#version 460 core

uniform TextureUbo {
  float opacity;
} texture_ubo;

uniform sampler2D u_texture;

in vec2 v_texCoord;

out vec4 f_color;

void main() {
  vec4 color = texture(u_texture, v_texCoord) * texture_ubo.opacity;
  if (color.a < 0.01) discard;

  f_color = color;
}