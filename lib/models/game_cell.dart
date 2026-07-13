class GameCell {
  final String id;
  final int value;
  final int row;
  final int col;
  final bool isMerged;
  final bool isNew;

  const GameCell({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isMerged = false,
    this.isNew = true,
  });

  GameCell copyWith({
    int? value,
    int? row,
    int? col,
    bool? isMerged,
    bool? isNew,
  }) {
    return GameCell(
      id: id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isMerged: isMerged ?? this.isMerged,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'row': row,
      'col': col,
      'isMerged': isMerged,
      'isNew': isNew,
    };
  }

  factory GameCell.fromJson(Map<String, dynamic> json) {
    return GameCell(
      id: json['id'] as String,
      value: json['value'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
      isMerged: json['isMerged'] as bool,
      isNew: json['isNew'] as bool,
    );
  }
}
