enum PieceType { general, advisor, elephant, horse, chariot, cannon, soldier }

enum Side { red, black }

extension SideX on Side {
  Side get opponent => this == Side.red ? Side.black : Side.red;
}

class Piece {
  final PieceType type;
  final Side side;

  const Piece(this.type, this.side);

  @override
  bool operator ==(Object other) =>
      other is Piece && other.type == type && other.side == side;

  @override
  int get hashCode => Object.hash(type, side);

  static const _fenChars = {
    PieceType.general: 'k',
    PieceType.advisor: 'a',
    PieceType.elephant: 'b',
    PieceType.horse: 'n',
    PieceType.chariot: 'r',
    PieceType.cannon: 'c',
    PieceType.soldier: 'p',
  };

  /// FEN piece letter, uppercase for red, lowercase for black.
  String get fenChar {
    final c = _fenChars[type]!;
    return side == Side.red ? c.toUpperCase() : c;
  }

  static Piece fromFenChar(String c) {
    final side = c == c.toUpperCase() ? Side.red : Side.black;
    final lower = c.toLowerCase();
    final type = _fenChars.entries
        .firstWhere(
          (e) => e.value == lower,
          orElse: () => throw ArgumentError('Unknown FEN piece char: $c'),
        )
        .key;
    return Piece(type, side);
  }

  static const _redChars = {
    PieceType.general: '帥',
    PieceType.advisor: '仕',
    PieceType.elephant: '相',
    PieceType.horse: '傌',
    PieceType.chariot: '俥',
    PieceType.cannon: '炮',
    PieceType.soldier: '兵',
  };

  static const _blackChars = {
    PieceType.general: '將',
    PieceType.advisor: '士',
    PieceType.elephant: '象',
    PieceType.horse: '馬',
    PieceType.chariot: '車',
    PieceType.cannon: '砲',
    PieceType.soldier: '卒',
  };

  /// Traditional Chinese character used to render the piece face.
  String get character => (side == Side.red ? _redChars : _blackChars)[type]!;
}
