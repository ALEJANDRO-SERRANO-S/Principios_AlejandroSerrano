class Champion {
  final int? id; // Es opcional porque al crear uno nuevo, la BD le asigna el ID
  final String name;
  final String birthCountry;
  final String representedCountry;
  final int ageAtFirstWin;
  final String period;
  final String imageUrl;
  final String bio;

  Champion({
    this.id,
    required this.name,
    required this.birthCountry,
    required this.representedCountry,
    required this.ageAtFirstWin,
    required this.period,
    required this.imageUrl,
    required this.bio,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  // Convierte el JSON que viene de Spring Boot a un objeto de Flutter
  factory Champion.fromJson(Map<String, dynamic> json) {
    return Champion(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      birthCountry: json['birthCountry']?.toString() ?? '',
      representedCountry: json['representedCountry']?.toString() ?? '',
      ageAtFirstWin: _toInt(json['ageAtFirstWin']) ?? 0,
      period: json['period']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
    );
  }

  // Convierte el objeto de Flutter a JSON para enviarlo a Spring Boot
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthCountry': birthCountry,
      'representedCountry': representedCountry,
      'ageAtFirstWin': ageAtFirstWin,
      'period': period,
      'imageUrl': imageUrl,
      'bio': bio,
    };
  }
}
