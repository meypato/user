class UserFavoriteRoom {
  final String userId;
  final String roomId;
  final DateTime createdAt;

  UserFavoriteRoom({
    required this.userId,
    required this.roomId,
    required this.createdAt,
  });

  factory UserFavoriteRoom.fromJson(Map<String, dynamic> json) {
    return UserFavoriteRoom(
      userId: json['user_id'],
      roomId: json['room_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'room_id': roomId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserFavoriteBuilding {
  final String userId;
  final String buildingId;
  final DateTime createdAt;

  UserFavoriteBuilding({
    required this.userId,
    required this.buildingId,
    required this.createdAt,
  });

  factory UserFavoriteBuilding.fromJson(Map<String, dynamic> json) {
    return UserFavoriteBuilding(
      userId: json['user_id'],
      buildingId: json['building_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'building_id': buildingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}