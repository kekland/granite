class TileCoordinates {
  TileCoordinates(this.x, this.y, this.z);

  final int x;
  final int y;
  final int z;

  @override
  String toString() => '[$x, $y, $z]';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TileCoordinates) return false;
    return x == other.x && y == other.y && z == other.z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}
