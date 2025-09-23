import 'enums.dart';

class Profile {
  final String id;
  final String fullName;
  final String? photoUrl;
  final UserRole role;
  final String? identificationFileUrl;
  final String? policeVerificationFileUrl;
  final int? age;
  final SexType? sex;
  final String? tribeId;
  final APSTStatus? apst;
  final String? addressLine1;
  final String? addressLine2;
  final String country;
  final String? pincode;
  final bool isVerified;
  final VerificationStatus verificationState;
  final String? professionId;
  final String? phone;
  final String? email;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool isActive;
  final String stateId;
  final String cityId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.photoUrl,
    required this.role,
    this.identificationFileUrl,
    this.policeVerificationFileUrl,
    this.age,
    this.sex,
    this.tribeId,
    this.apst,
    this.addressLine1,
    this.addressLine2,
    this.country = 'India',
    this.pincode,
    this.isVerified = false,
    this.verificationState = VerificationStatus.unverified,
    this.professionId,
    this.phone,
    this.email,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.isActive = true,
    required this.stateId,
    required this.cityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      photoUrl: json['photo_url'] as String?,
      role: UserRole.fromString(json['role'] as String),
      identificationFileUrl: json['identification_file_url'] as String?,
      policeVerificationFileUrl: json['police_verification_file_url'] as String?,
      age: json['age'] as int?,
      sex: json['sex'] != null ? SexType.fromString(json['sex'] as String) : null,
      tribeId: json['tribe_id'] as String?,
      apst: json['apst'] != null ? APSTStatus.fromString(json['apst'] as String) : null,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      country: json['country'] as String? ?? 'India',
      pincode: json['pincode'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationState: VerificationStatus.fromString(json['verification_state'] as String? ?? 'unverified'),
      professionId: json['profession_id'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      stateId: json['state_id'] as String,
      cityId: json['city_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'photo_url': photoUrl,
      'role': role.name,
      'identification_file_url': identificationFileUrl,
      'police_verification_file_url': policeVerificationFileUrl,
      'age': age,
      'sex': sex?.name,
      'tribe_id': tribeId,
      'apst': apst?.databaseValue,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'country': country,
      'pincode': pincode,
      'is_verified': isVerified,
      'verification_state': verificationState.name,
      'profession_id': professionId,
      'phone': phone,
      'email': email,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'is_active': isActive,
      'state_id': stateId,
      'city_id': cityId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? photoUrl,
    UserRole? role,
    String? identificationFileUrl,
    String? policeVerificationFileUrl,
    int? age,
    SexType? sex,
    String? tribeId,
    APSTStatus? apst,
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? pincode,
    bool? isVerified,
    VerificationStatus? verificationState,
    String? professionId,
    String? phone,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? isActive,
    String? stateId,
    String? cityId,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      identificationFileUrl: identificationFileUrl ?? this.identificationFileUrl,
      policeVerificationFileUrl: policeVerificationFileUrl ?? this.policeVerificationFileUrl,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      tribeId: tribeId ?? this.tribeId,
      apst: apst ?? this.apst,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      isVerified: isVerified ?? this.isVerified,
      verificationState: verificationState ?? this.verificationState,
      professionId: professionId ?? this.professionId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      isActive: isActive ?? this.isActive,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get hasCompleteProfile {
    return fullName.isNotEmpty &&
        phone != null &&
        email != null &&
        age != null &&
        sex != null &&
        addressLine1 != null &&
        pincode != null &&
        stateId.isNotEmpty &&
        cityId.isNotEmpty;
  }

  bool get canRent {
    return role == UserRole.tenant &&
        isActive &&
        hasCompleteProfile &&
        isVerified;
  }

  bool get canListProperties {
    return role == UserRole.owner &&
        isActive &&
        hasCompleteProfile &&
        isVerified;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, fullName: $fullName, role: $role, isVerified: $isVerified}';
  }
}