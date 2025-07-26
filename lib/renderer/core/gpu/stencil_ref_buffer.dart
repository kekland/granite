class StencilRefBuffer {
  StencilRefBuffer({this.maxStencilRef = 255});

  final int maxStencilRef;
  late final _state = List.generate(maxStencilRef + 1, (_) => false);

  int allocate() {
    for (var i = 0; i < _state.length; i++) {
      if (!_state[i]) {
        _state[i] = true;
        return i;
      }
    }

    throw StateError('No available stencil reference values left.');
  }

  void deallocate(int stencilRef) {
    if (stencilRef < 0 || stencilRef > maxStencilRef) {
      throw RangeError.range(stencilRef, 0, maxStencilRef, 'stencilRef');
    }

    _state[stencilRef] = false;
  }
}
