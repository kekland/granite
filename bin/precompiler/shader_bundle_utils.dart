import 'shader_bundle/shader_bundle_impeller.fb.shaderbundle_generated.dart' as ipsb;

List<ipsb.ShaderInputObjectBuilder>? shaderInputObjectBuilderMapper(List<ipsb.ShaderInput>? inputs) {
  if (inputs == null) return null;

  return inputs
      .map(
        (v) => ipsb.ShaderInputObjectBuilder(
          $set: v.$set,
          binding: v.binding,
          bitWidth: v.bitWidth,
          columns: v.columns,
          location: v.location,
          name: v.name,
          offset: v.offset,
          type: v.type,
          vecSize: v.vecSize,
        ),
      )
      .toList();
}

List<ipsb.ShaderUniformStructObjectBuilder>? shaderUniformStructObjectBuilderMapper(
  List<ipsb.ShaderUniformStruct>? structs,
) {
  if (structs == null) return null;

  return structs
      .map(
        (v) => ipsb.ShaderUniformStructObjectBuilder(
          name: v.name,
          $set: v.$set,
          binding: v.binding,
          extRes0: v.extRes0,
          sizeInBytes: v.sizeInBytes,
          fields: v.fields
              ?.map(
                (f) => ipsb.ShaderUniformStructFieldObjectBuilder(
                  name: f.name,
                  arrayElements: f.arrayElements,
                  elementSizeInBytes: f.elementSizeInBytes,
                  offsetInBytes: f.offsetInBytes,
                  totalSizeInBytes: f.totalSizeInBytes,
                  type: f.type,
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

List<ipsb.ShaderUniformTextureObjectBuilder> shaderUniformTextureObjectBuilderMapper(
  List<ipsb.ShaderUniformTexture>? textures,
) {
  if (textures == null) return [];

  return textures
      .map(
        (v) => ipsb.ShaderUniformTextureObjectBuilder(
          name: v.name,
          binding: v.binding,
          $set: v.$set,
          extRes0: v.extRes0,
        ),
      )
      .toList();
}

ipsb.BackendShaderObjectBuilder? backendShaderObjectBuilderMapper(ipsb.BackendShader? shader) {
  if (shader == null) return null;

  return ipsb.BackendShaderObjectBuilder(
    entrypoint: shader.entrypoint,
    inputs: shaderInputObjectBuilderMapper(shader.inputs),
    shader: shader.shader,
    stage: shader.stage,
    uniformStructs: shaderUniformStructObjectBuilderMapper(shader.uniformStructs),
    uniformTextures: shaderUniformTextureObjectBuilderMapper(shader.uniformTextures),
  );
}
