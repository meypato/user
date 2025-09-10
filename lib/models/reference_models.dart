class State {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const State({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is State && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'State{id: $id, name: $name}';
}

class City {
  final String id;
  final String stateId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const City({
    required this.id,
    required this.stateId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      stateId: json['state_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_id': stateId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City{id: $id, name: $name, stateId: $stateId}';
}

class Tribe {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tribe({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tribe.fromJson(Map<String, dynamic> json) {
    return Tribe(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tribe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tribe{id: $id, name: $name}';
}

class Profession {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Profession{id: $id, name: $name}';
}

class Amenity {
  final String id;
  final String name;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Amenity({
    required this.id,
    required this.name,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasCategory => category != null && category!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Amenity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Amenity{id: $id, name: $name, category: $category}';
}

class RoomAmenity {
  final String roomId;
  final String amenityId;

  const RoomAmenity({
    required this.roomId,
    required this.amenityId,
  });

  factory RoomAmenity.fromJson(Map<String, dynamic> json) {
    return RoomAmenity(
      roomId: json['room_id'] as String,
      amenityId: json['amenity_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'amenity_id': amenityId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomAmenity && 
           other.roomId == roomId && 
           other.amenityId == amenityId;
  }

  @override
  int get hashCode => Object.hash(roomId, amenityId);

  @override
  String toString() => 'RoomAmenity{roomId: $roomId, amenityId: $amenityId}';
}

class BuildingProfessionException {
  final String buildingId;
  final String professionId;

  const BuildingProfessionException({
    required this.buildingId,
    required this.professionId,
  });

  factory BuildingProfessionException.fromJson(Map<String, dynamic> json) {
    return BuildingProfessionException(
      buildingId: json['building_id'] as String,
      professionId: json['profession_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building_id': buildingId,
      'profession_id': professionId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuildingProfessionException && 
           other.buildingId == buildingId && 
           other.professionId == professionId;
  }

  @override
  int get hashCode => Object.hash(buildingId, professionId);

  @override
  String toString() => 'BuildingProfessionException{buildingId: $buildingId, professionId: $professionId}';
}

class BuildingTribeException {
  final String buildingId;
  final String tribeId;

  const BuildingTribeException({
    required this.buildingId,
    required this.tribeId,
  });

  factory BuildingTribeException.fromJson(Map<String, dynamic> json) {
    return BuildingTribeException(
      buildingId: json['building_id'] as String,
      tribeId: json['tribe_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building_id': buildingId,
      'tribe_id': tribeId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuildingTribeException && 
           other.buildingId == buildingId && 
           other.tribeId == tribeId;
  }

  @override
  int get hashCode => Object.hash(buildingId, tribeId);

  @override
  String toString() => 'BuildingTribeException{buildingId: $buildingId, tribeId: $tribeId}';
}