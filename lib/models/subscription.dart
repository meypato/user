class Subscription {
  final String id;
  final String roomId;
  final String tenantId;
  final double monthlyRent;
  final double securityDeposit;
  final DateTime startDate;
  final bool isActive;
  final String? agreementFileUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.monthlyRent,
    this.securityDeposit = 0.0,
    required this.startDate,
    this.isActive = true,
    this.agreementFileUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      tenantId: json['tenant_id'] as String,
      monthlyRent: double.parse(json['monthly_rent'].toString()),
      securityDeposit: json['security_deposit'] != null 
          ? double.parse(json['security_deposit'].toString()) 
          : 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      agreementFileUrl: json['agreement_file_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'tenant_id': tenantId,
      'monthly_rent': monthlyRent,
      'security_deposit': securityDeposit,
      'start_date': startDate.toIso8601String().split('T')[0],
      'is_active': isActive,
      'agreement_file_url': agreementFileUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Subscription copyWith({
    double? monthlyRent,
    double? securityDeposit,
    DateTime? startDate,
    bool? isActive,
    String? agreementFileUrl,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id,
      roomId: roomId,
      tenantId: tenantId,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      agreementFileUrl: agreementFileUrl ?? this.agreementFileUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Duration get tenancyDuration {
    return DateTime.now().difference(startDate);
  }

  int get tenancyDurationInMonths {
    final now = DateTime.now();
    final months = (now.year - startDate.year) * 12 + (now.month - startDate.month);
    return months > 0 ? months : 0;
  }

  bool get hasAgreement => agreementFileUrl != null && agreementFileUrl!.isNotEmpty;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  bool get hasSecurityDeposit => securityDeposit > 0;

  String get formattedMonthlyRent => '₹${monthlyRent.toStringAsFixed(0)}';

  String get formattedSecurityDeposit => hasSecurityDeposit 
      ? '₹${securityDeposit.toStringAsFixed(0)}' 
      : 'No deposit';

  String get formattedStartDate => '${startDate.day}/${startDate.month}/${startDate.year}';

  String get tenancyDurationText {
    final months = tenancyDurationInMonths;
    if (months == 0) {
      return 'Less than a month';
    } else if (months == 1) {
      return '1 month';
    } else if (months < 12) {
      return '$months months';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      String text = years == 1 ? '1 year' : '$years years';
      if (remainingMonths > 0) {
        text += remainingMonths == 1 ? ', 1 month' : ', $remainingMonths months';
      }
      return text;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Subscription{id: $id, roomId: $roomId, tenantId: $tenantId, monthlyRent: $monthlyRent, isActive: $isActive}';
  }
}