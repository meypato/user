import 'enums.dart';

class Room {
  final String id;
  final String buildingId;
  final String name;
  final String roomNumber;
  final String? roomId;
  final RoomType roomType;
  final double fee;
  final double? securityFee;
  final int maximumOccupancy;
  final RoomAvailability availabilityStatus;
  final String? description;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Building details (from JOIN)
  final String? buildingName;
  final String? cityName;

  const Room({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.roomNumber,
    this.roomId,
    required this.roomType,
    required this.fee,
    this.securityFee,
    this.maximumOccupancy = 1,
    this.availabilityStatus = RoomAvailability.available,
    this.description,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.buildingName,
    this.cityName,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = (json['photos'] as List).map((e) => e.toString()).toList();
      }
    }

    // Extract building and city data from nested structure
    String? buildingName;
    String? cityName;

    if (json['buildings'] != null) {
      final building = json['buildings'];
      buildingName = building['name'] as String?;

      if (building['cities'] != null) {
        cityName = building['cities']['name'] as String?;
      }
    }

    return Room(
      id: json['id'] as String,
      buildingId: json['building_id'] as String,
      name: json['name'] as String,
      roomNumber: json['room_number'] as String,
      roomId: json['room_id'] as String?,
      roomType: RoomType.fromString(json['room_type'] as String),
      fee: double.parse(json['fee'].toString()),
      securityFee: json['security_fee'] != null ? double.parse(json['security_fee'].toString()) : null,
      maximumOccupancy: json['maximum_occupancy'] as int? ?? 1,
      availabilityStatus: RoomAvailability.fromString(json['availability_status'] as String),
      description: json['description'] as String?,
      photos: photosList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      buildingName: buildingName,
      cityName: cityName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'name': name,
      'room_number': roomNumber,
      'room_id': roomId,
      'room_type': roomType.name,
      'fee': fee,
      'security_fee': securityFee,
      'maximum_occupancy': maximumOccupancy,
      'availability_status': availabilityStatus.name,
      'description': description,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'building_name': buildingName,
      'city_name': cityName,
    };
  }

  Room copyWith({
    String? name,
    String? roomNumber,
    String? roomId,
    RoomType? roomType,
    double? fee,
    double? securityFee,
    int? maximumOccupancy,
    RoomAvailability? availabilityStatus,
    String? description,
    List<String>? photos,
    DateTime? updatedAt,
    String? buildingName,
    String? cityName,
  }) {
    return Room(
      id: id,
      buildingId: buildingId,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      roomId: roomId ?? this.roomId,
      roomType: roomType ?? this.roomType,
      fee: fee ?? this.fee,
      securityFee: securityFee ?? this.securityFee,
      maximumOccupancy: maximumOccupancy ?? this.maximumOccupancy,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      buildingName: buildingName ?? this.buildingName,
      cityName: cityName ?? this.cityName,
    );
  }

  bool get isAvailable => availabilityStatus.isAvailable;

  bool get hasPhotos => photos.isNotEmpty;

  bool get hasDescription => description != null && description!.isNotEmpty;

  bool get hasSecurityFee => securityFee != null && securityFee! > 0;

  String get displayId => roomId ?? id.substring(0, 8);

  String get fullName => '$name ($roomNumber)';

  String get formattedFee => '₹${fee.toStringAsFixed(0)}/month';

  String get formattedSecurityFee => hasSecurityFee ? '₹${securityFee!.toStringAsFixed(0)}' : 'No deposit';

  double get totalUpfrontCost => fee + (securityFee ?? 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Room{id: $id, name: $name, roomNumber: $roomNumber, fee: $fee, status: $availabilityStatus}';
  }
}