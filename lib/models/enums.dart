enum UserRole {
  tenant,
  owner;

  String get displayName {
    switch (this) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.owner:
        return 'Owner';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value.toLowerCase(),
      orElse: () => UserRole.tenant,
    );
  }
}

enum SexType {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case SexType.male:
        return 'Male';
      case SexType.female:
        return 'Female';
      case SexType.other:
        return 'Other';
    }
  }

  static SexType fromString(String value) {
    return SexType.values.firstWhere(
      (sex) => sex.name == value.toLowerCase(),
      orElse: () => SexType.male,
    );
  }
}

enum APSTStatus {
  st,
  sc,
  obc,
  general;

  String get displayName {
    switch (this) {
      case APSTStatus.st:
        return 'ST';
      case APSTStatus.sc:
        return 'SC';
      case APSTStatus.obc:
        return 'OBC';
      case APSTStatus.general:
        return 'General';
    }
  }

  static APSTStatus fromString(String value) {
    return APSTStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => APSTStatus.general,
    );
  }
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isVerified => this == VerificationStatus.verified;
  bool get isPending => this == VerificationStatus.pending;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => VerificationStatus.unverified,
    );
  }
}

enum BuildingType {
  apartment,
  house,
  hostel,
  pg,
  flat;

  String get displayName {
    switch (this) {
      case BuildingType.apartment:
        return 'Apartment';
      case BuildingType.house:
        return 'House';
      case BuildingType.hostel:
        return 'Hostel';
      case BuildingType.pg:
        return 'PG';
      case BuildingType.flat:
        return 'Flat';
    }
  }

  static BuildingType fromString(String value) {
    return BuildingType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => BuildingType.apartment,
    );
  }
}

enum RoomType {
  single,
  double,
  triple,
  studio;

  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Single';
      case RoomType.double:
        return 'Double';
      case RoomType.triple:
        return 'Triple';
      case RoomType.studio:
        return 'Studio';
    }
  }

  static RoomType fromString(String value) {
    return RoomType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RoomType.single,
    );
  }
}

enum RoomAvailability {
  available,
  occupied,
  maintenance,
  unavailable;

  String get displayName {
    switch (this) {
      case RoomAvailability.available:
        return 'Available';
      case RoomAvailability.occupied:
        return 'Occupied';
      case RoomAvailability.maintenance:
        return 'Maintenance';
      case RoomAvailability.unavailable:
        return 'Unavailable';
    }
  }

  bool get isAvailable => this == RoomAvailability.available;

  static RoomAvailability fromString(String value) {
    return RoomAvailability.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => RoomAvailability.available,
    );
  }
}