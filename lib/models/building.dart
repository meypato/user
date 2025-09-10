import 'enums.dart';

class Building {
  final String id;
  final String ownerId;
  final String name;
  final BuildingType buildingType;
  final String addressLine1;
  final String? addressLine2;
  final String country;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final bool isActive;
  final String? buildingId;
  final String stateId;
  final String cityId;
  final String? rulesFileUrl;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Building({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.buildingType,
    required this.addressLine1,
    this.addressLine2,
    this.country = 'India',
    this.pincode,
    this.latitude,
    this.longitude,
    this.contactPersonName,
    this.contactPersonPhone,
    this.isActive = true,
    this.buildingId,
    required this.stateId,
    required this.cityId,
    this.rulesFileUrl,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = (json['photos'] as List).map((e) => e.toString()).toList();
      }
    }

    return Building(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      buildingType: BuildingType.fromString(json['building_type'] as String),
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      country: json['country'] as String? ?? 'India',
      pincode: json['pincode'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      contactPersonName: json['contact_person_name'] as String?,
      contactPersonPhone: json['contact_person_phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      buildingId: json['building_id'] as String?,
      stateId: json['state_id'] as String,
      cityId: json['city_id'] as String,
      rulesFileUrl: json['rules_file_url'] as String?,
      photos: photosList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'building_type': buildingType.name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'contact_person_name': contactPersonName,
      'contact_person_phone': contactPersonPhone,
      'is_active': isActive,
      'building_id': buildingId,
      'state_id': stateId,
      'city_id': cityId,
      'rules_file_url': rulesFileUrl,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Building copyWith({
    String? name,
    BuildingType? buildingType,
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? pincode,
    double? latitude,
    double? longitude,
    String? contactPersonName,
    String? contactPersonPhone,
    bool? isActive,
    String? buildingId,
    String? stateId,
    String? cityId,
    String? rulesFileUrl,
    List<String>? photos,
    DateTime? updatedAt,
  }) {
    return Building(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      buildingType: buildingType ?? this.buildingType,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      isActive: isActive ?? this.isActive,
      buildingId: buildingId ?? this.buildingId,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      rulesFileUrl: rulesFileUrl ?? this.rulesFileUrl,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
    ];
    return parts.join(', ');
  }

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasPhotos => photos.isNotEmpty;

  bool get hasRules => rulesFileUrl != null;

  String get displayId => buildingId ?? id.substring(0, 8);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Building && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Building{id: $id, name: $name, type: $buildingType, isActive: $isActive}';
  }
}