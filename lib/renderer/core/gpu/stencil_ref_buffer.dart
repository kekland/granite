class StencilRefBuffer {
  StencilRefBuffer({this.maxStencilRef = 254});

  final int maxStencilRef;
  late final _state = List.generate(maxStencilRef + 1, (_) => false);

  int allocate() {
    for (var i = 0; i < _state.length; i++) {
      if (!_state[i]) {
        _state[i] = true;
        return i + 1;
      }
    }

    throw StateError('No available stencil reference values left.');
  }

  void deallocate(int stencilRef) {
    _state[stencilRef - 1] = false;
  }
}
