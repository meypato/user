class Payment {
  final String id;
  final String subscriptionId;
  final DateTime monthYear;
  final double amountPaid;
  final DateTime paidDate;
  final String? paymentMethod;
  final String? transactionReference;
  final String? notes;
  final String? paymentGroupId;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.subscriptionId,
    required this.monthYear,
    required this.amountPaid,
    required this.paidDate,
    this.paymentMethod,
    this.transactionReference,
    this.notes,
    this.paymentGroupId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String,
      monthYear: DateTime.parse(json['month_year'] as String),
      amountPaid: double.parse(json['amount_paid'].toString()),
      paidDate: DateTime.parse(json['paid_date'] as String),
      paymentMethod: json['payment_method'] as String?,
      transactionReference: json['transaction_reference'] as String?,
      notes: json['notes'] as String?,
      paymentGroupId: json['payment_group_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'month_year': monthYear.toIso8601String().split('T')[0],
      'amount_paid': amountPaid,
      'paid_date': paidDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'notes': notes,
      'payment_group_id': paymentGroupId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Payment copyWith({
    double? amountPaid,
    DateTime? paidDate,
    String? paymentMethod,
    String? transactionReference,
    String? notes,
    String? paymentGroupId,
  }) {
    return Payment(
      id: id,
      subscriptionId: subscriptionId,
      monthYear: monthYear,
      amountPaid: amountPaid ?? this.amountPaid,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      notes: notes ?? this.notes,
      paymentGroupId: paymentGroupId ?? this.paymentGroupId,
      createdAt: createdAt,
    );
  }

  bool get hasPaymentMethod => paymentMethod != null && paymentMethod!.isNotEmpty;

  bool get hasTransactionReference => transactionReference != null && transactionReference!.isNotEmpty;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  bool get isGroupPayment => paymentGroupId != null;

  Duration get paymentDelay {
    final expectedDate = DateTime(monthYear.year, monthYear.month, 1);
    return paidDate.difference(expectedDate);
  }

  bool get isPaidLate => paymentDelay.inDays > 5;

  bool get isPaidEarly => paymentDelay.inDays < -1;

  bool get isPaidOnTime => !isPaidLate && !isPaidEarly;

  String get paymentStatus {
    if (isPaidEarly) return 'Early';
    if (isPaidLate) return 'Late';
    return 'On Time';
  }

  String get formattedAmount => '₹${amountPaid.toStringAsFixed(0)}';

  String get formattedPaidDate => '${paidDate.day}/${paidDate.month}/${paidDate.year}';

  String get formattedMonthYear => '${_getMonthName(monthYear.month)} ${monthYear.year}';

  String get shortMonthYear => '${_getShortMonthName(monthYear.month)} ${monthYear.year.toString().substring(2)}';

  String _getMonthName(int month) {
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month];
  }

  String _getShortMonthName(int month) {
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Payment{id: $id, subscriptionId: $subscriptionId, monthYear: $formattedMonthYear, amountPaid: $amountPaid}';
  }
}