class Meeting {
  final String name; // Görüşülecek kişi
  final DateTime dateTime; // Görüşme zamanı
  final String creatorName; // Ekleyen kişi
  final String description;

  Meeting({
    required this.name,
    required this.dateTime,
    required this.creatorName,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'creatorName': creatorName,
      'description': description,
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map, String id) {
    return Meeting(
      name: map['name'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      creatorName: map['creatorName'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
