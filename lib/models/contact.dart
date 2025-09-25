class Contact {
  final String id;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? youtube;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contact({
    required this.id,
    this.phone,
    this.email,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.youtube,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      whatsapp: json['whatsapp'] as String?,
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      youtube: json['youtube'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'facebook': facebook,
      'youtube': youtube,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}