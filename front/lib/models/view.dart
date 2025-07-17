class View {
  final int id;
  final int pokemonId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  View({
    required this.id,
    required this.pokemonId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory View.fromJson(Map<String, dynamic> json) {
    return View(
      id: json['id'],
      pokemonId: json['pokemonId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
