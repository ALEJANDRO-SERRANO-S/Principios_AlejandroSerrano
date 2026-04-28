/// Entidad de Campeón en la capa de dominio
/// Cumple con SRP: solo representa un campeón sin lógica de serialización
class ChampionEntity {
  final int? id;
  final String name;
  final String birthCountry;
  final String representedCountry;
  final int ageAtFirstWin;
  final String period;
  final String imageUrl;
  final String bio;

  const ChampionEntity({
    this.id,
    required this.name,
    required this.birthCountry,
    required this.representedCountry,
    required this.ageAtFirstWin,
    required this.period,
    required this.imageUrl,
    required this.bio,
  });

  /// Factory para crear desde Champion model (compatibilidad con código existente)
  factory ChampionEntity.fromChampion(dynamic champion) {
    return ChampionEntity(
      id: champion.id,
      name: champion.name,
      birthCountry: champion.birthCountry,
      representedCountry: champion.representedCountry,
      ageAtFirstWin: champion.ageAtFirstWin,
      period: champion.period,
      imageUrl: champion.imageUrl,
      bio: champion.bio,
    );
  }

  /// Copiar con cambios
  ChampionEntity copyWith({
    int? id,
    String? name,
    String? birthCountry,
    String? representedCountry,
    int? ageAtFirstWin,
    String? period,
    String? imageUrl,
    String? bio,
  }) {
    return ChampionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      birthCountry: birthCountry ?? this.birthCountry,
      representedCountry: representedCountry ?? this.representedCountry,
      ageAtFirstWin: ageAtFirstWin ?? this.ageAtFirstWin,
      period: period ?? this.period,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() => 'ChampionEntity(id: $id, name: $name)';
}

/// Entidad de Usuario para autenticación
class UserEntity {
  final String username;
  final String email;
  final String token;
  final List<String> roles;

  const UserEntity({
    required this.username,
    required this.email,
    required this.token,
    this.roles = const ['user'],
  });

  @override
  String toString() => 'UserEntity(username: $username, email: $email)';
}

