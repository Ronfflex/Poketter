class Like {
  final int id;
  final int pokemonId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Like({
    required this.id,
    required this.pokemonId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      pokemonId: json['pokemonId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
