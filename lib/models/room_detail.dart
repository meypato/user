import 'enums.dart';

/// Comprehensive room detail model that includes all related data for room details screen
class RoomDetail {
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

  // Building details
  final String buildingName;
  final BuildingType buildingType;
  final String addressLine1;
  final String? addressLine2;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final List<String> buildingPhotos;
  final String? rulesFileUrl;
  final double? latitude;
  final double? longitude;

  // Location details
  final String cityName;
  final String stateName;

  // Amenities
  final List<RoomDetailAmenity> amenities;

  // Recent reviews (limited)
  final List<RoomDetailReview> recentReviews;
  final double? averageRating;
  final int totalReviews;

  // Owner/Agent info (basic)
  final String ownerName;
  final String? ownerPhone;

  const RoomDetail({
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
    required this.buildingName,
    required this.buildingType,
    required this.addressLine1,
    this.addressLine2,
    this.contactPersonName,
    this.contactPersonPhone,
    this.buildingPhotos = const [],
    this.rulesFileUrl,
    this.latitude,
    this.longitude,
    required this.cityName,
    required this.stateName,
    this.amenities = const [],
    this.recentReviews = const [],
    this.averageRating,
    this.totalReviews = 0,
    required this.ownerName,
    this.ownerPhone,
  });

  factory RoomDetail.fromJson(Map<String, dynamic> json) {
    // Parse room photos
    List<String> roomPhotosList = [];
    if (json['photos'] != null && json['photos'] is List) {
      roomPhotosList = (json['photos'] as List).map((e) => e.toString()).toList();
    }

    // Parse building photos
    List<String> buildingPhotosList = [];
    if (json['buildings']?['photos'] != null && json['buildings']['photos'] is List) {
      buildingPhotosList = (json['buildings']['photos'] as List).map((e) => e.toString()).toList();
    }

    // Parse amenities
    List<RoomDetailAmenity> amenitiesList = [];
    if (json['room_amenities'] != null && json['room_amenities'] is List) {
      amenitiesList = (json['room_amenities'] as List)
          .map((amenityJson) => RoomDetailAmenity.fromJson(amenityJson))
          .toList();
    }

    // Parse recent reviews
    List<RoomDetailReview> reviewsList = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => RoomDetailReview.fromJson(reviewJson))
          .toList();
    }

    // Calculate average rating
    double? avgRating;
    if (reviewsList.isNotEmpty) {
      final totalRating = reviewsList.fold<double>(0, (sum, review) => sum + review.rating);
      avgRating = totalRating / reviewsList.length;
    }

    return RoomDetail(
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
      photos: roomPhotosList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Building data
      buildingName: json['buildings']['name'] as String,
      buildingType: BuildingType.fromString(json['buildings']['building_type'] as String),
      addressLine1: json['buildings']['address_line1'] as String,
      addressLine2: json['buildings']['address_line2'] as String?,
      contactPersonName: json['buildings']['contact_person_name'] as String?,
      contactPersonPhone: json['buildings']['contact_person_phone'] as String?,
      buildingPhotos: buildingPhotosList,
      rulesFileUrl: json['buildings']['rules_file_url'] as String?,
      latitude: json['buildings']['latitude'] as double?,
      longitude: json['buildings']['longitude'] as double?,

      // Location data
      cityName: json['buildings']['cities']['name'] as String,
      stateName: json['buildings']['states']['name'] as String,

      // Amenities and reviews
      amenities: amenitiesList,
      recentReviews: reviewsList,
      averageRating: avgRating,
      totalReviews: reviewsList.length,

      // Owner data
      ownerName: json['buildings']['profiles']['name'] ?? json['buildings']['profiles']['email'] as String,
      ownerPhone: json['buildings']['profiles']['phone'] as String?,
    );
  }

  // Simplified factory for basic room data (without JOIN queries)
  factory RoomDetail.fromBasicJson(Map<String, dynamic> json) {
    // Parse room photos
    List<String> roomPhotosList = [];
    if (json['photos'] != null && json['photos'] is List) {
      roomPhotosList = (json['photos'] as List).map((e) => e.toString()).toList();
    }

    return RoomDetail(
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
      photos: roomPhotosList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Default/placeholder values for building data
      buildingName: 'Building Name Loading...',
      buildingType: BuildingType.apartment,
      addressLine1: 'Address Loading...',
      addressLine2: null,
      contactPersonName: null,
      contactPersonPhone: null,
      buildingPhotos: const [],
      rulesFileUrl: null,
      latitude: null,
      longitude: null,

      // Default/placeholder values for location
      cityName: 'City Loading...',
      stateName: 'State Loading...',

      // Empty arrays for related data
      amenities: const [],
      recentReviews: const [],
      averageRating: null,
      totalReviews: 0,

      // Default owner info
      ownerName: 'Owner Info Loading...',
      ownerPhone: null,
    );
  }

  // Factory for nested JSON data (matching the working pattern from getRooms)
  factory RoomDetail.fromNestedJson(Map<String, dynamic> json) {
    // Parse room photos
    List<String> roomPhotosList = [];
    if (json['photos'] != null && json['photos'] is List) {
      roomPhotosList = (json['photos'] as List).map((e) => e.toString()).toList();
    }

    // Parse building photos
    List<String> buildingPhotosList = [];
    if (json['buildings']?['photos'] != null && json['buildings']['photos'] is List) {
      buildingPhotosList = (json['buildings']['photos'] as List).map((e) => e.toString()).toList();
    }

    // Extract building and city data from nested structure
    final building = json['buildings'];
    String buildingName = 'Unknown Building';
    String cityName = 'Unknown City';
    String addressLine1 = 'Address not available';

    if (building != null) {
      buildingName = building['name'] as String? ?? 'Unknown Building';
      addressLine1 = building['address_line1'] as String? ?? 'Address not available';

      if (building['cities'] != null) {
        cityName = building['cities']['name'] as String? ?? 'Unknown City';
      }
    }

    return RoomDetail(
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
      photos: roomPhotosList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Building data from nested structure
      buildingName: buildingName,
      buildingType: building != null ? BuildingType.fromString(building['building_type'] as String? ?? 'apartment') : BuildingType.apartment,
      addressLine1: addressLine1,
      addressLine2: building?['address_line2'] as String?,
      contactPersonName: building?['contact_person_name'] as String?,
      contactPersonPhone: building?['contact_person_phone'] as String?,
      buildingPhotos: buildingPhotosList,
      rulesFileUrl: null,
      latitude: null,
      longitude: null,

      // Location data from nested structure
      cityName: cityName,
      stateName: 'Arunachal Pradesh', // Default for now

      // Empty arrays for data we're not fetching yet
      amenities: const [],
      recentReviews: const [],
      averageRating: null,
      totalReviews: 0,

      // Default owner info for now
      ownerName: 'Contact for details',
      ownerPhone: building?['contact_person_phone'] as String?,
    );
  }

  // Computed properties
  bool get isAvailable => availabilityStatus.isAvailable;
  bool get hasPhotos => photos.isNotEmpty;
  bool get hasBuildingPhotos => buildingPhotos.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasSecurityFee => securityFee != null && securityFee! > 0;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasRules => rulesFileUrl != null;
  bool get hasReviews => recentReviews.isNotEmpty;
  bool get hasAmenities => amenities.isNotEmpty;

  String get displayId => roomId ?? id.substring(0, 8);
  String get fullName => '$name ($roomNumber)';
  String get formattedFee => '₹${fee.toStringAsFixed(0)}';
  String get formattedSecurityFee => hasSecurityFee ? '₹${securityFee!.toStringAsFixed(0)}' : 'No deposit';
  String get fullAddress => [addressLine1, addressLine2, cityName, stateName].where((s) => s != null && s.isNotEmpty).join(', ');
  String get formattedRating => averageRating != null ? averageRating!.toStringAsFixed(1) : '0.0';

  double get totalUpfrontCost => fee + (securityFee ?? 0);

  @override
  String toString() {
    return 'RoomDetail{id: $id, name: $fullName, building: $buildingName, city: $cityName}';
  }
}

/// Amenity data for room details
class RoomDetailAmenity {
  final String id;
  final String name;
  final String? category;
  final String? icon;

  const RoomDetailAmenity({
    required this.id,
    required this.name,
    this.category,
    this.icon,
  });

  factory RoomDetailAmenity.fromJson(Map<String, dynamic> json) {
    final amenity = json['amenities'] ?? json;
    return RoomDetailAmenity(
      id: amenity['id'] as String,
      name: amenity['name'] as String,
      category: amenity['category'] as String?,
      icon: amenity['icon'] as String?,
    );
  }

  bool get hasCategory => category != null && category!.isNotEmpty;
  bool get hasIcon => icon != null && icon!.isNotEmpty;

  @override
  String toString() => 'RoomDetailAmenity{name: $name, category: $category}';
}

/// Review data for room details
class RoomDetailReview {
  final String id;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String reviewerName;
  final String? reviewerAvatar;

  const RoomDetailReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.reviewerName,
    this.reviewerAvatar,
  });

  factory RoomDetailReview.fromJson(Map<String, dynamic> json) {
    return RoomDetailReview(
      id: json['id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: json['profiles']['name'] ?? json['profiles']['email'] as String,
      reviewerAvatar: json['profiles']['avatar_url'] as String?,
    );
  }

  bool get hasComment => comment != null && comment!.isNotEmpty;
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }

  @override
  String toString() => 'RoomDetailReview{rating: $rating, reviewer: $reviewerName}';
}