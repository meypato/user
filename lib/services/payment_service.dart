import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PaymentService {
  static final _supabase = Supabase.instance.client;

  /// Calculate payment amount with month-based conditions (matches admin logic)
  static Future<Map<String, dynamic>> calculatePaymentWithConditions({
    required String? subscriptionId, // null for new subscriptions
    required DateTime subscriptionStartDate,
    required double monthlyRent,
    required DateTime selectedPaymentDate, // When payment is made
    required DateTime targetMonthYear, // Which month to pay for
    DateTime? currentDateOverride, // for testing scenarios
  }) async {
    final currentDate = currentDateOverride ?? DateTime.now();

    try {
      // Check if this is a first payment
      bool isFirstPayment = false;
      if (subscriptionId == null) {
        // New subscription - definitely first payment
        isFirstPayment = true;
      } else {
        // Check existing payments for this subscription
        final response = await _supabase
            .from('payments')
            .select('id')
            .eq('subscription_id', subscriptionId)
            .limit(1);

        isFirstPayment = response.isEmpty;
      }

      // Calculate payment conditions using admin logic
      return _calculatePaymentConditionsAdmin(
        isFirstPayment: isFirstPayment,
        subscriptionStartDate: subscriptionStartDate,
        monthlyRent: monthlyRent,
        selectedPaymentDate: selectedPaymentDate,
        targetMonthYear: targetMonthYear,
        currentDate: currentDate,
      );
    } catch (e) {
      throw Exception('Failed to calculate payment conditions: $e');
    }
  }

  /// Admin-style payment calculation logic with proper month targeting
  static Map<String, dynamic> _calculatePaymentConditionsAdmin({
    required bool isFirstPayment,
    required DateTime subscriptionStartDate,
    required double monthlyRent,
    required DateTime selectedPaymentDate,
    required DateTime targetMonthYear,
    required DateTime currentDate,
  }) {
    double baseAmount = monthlyRent;
    double lateFee = 0.0;
    String condition = 'regular';
    String description = 'Regular monthly payment';

    // Normalize target month to first day
    final targetMonth = DateTime(targetMonthYear.year, targetMonthYear.month, 1);
    final subscriptionMonth = DateTime(subscriptionStartDate.year, subscriptionStartDate.month, 1);

    if (isFirstPayment && targetMonth == subscriptionMonth) {
      // First payment for subscription start month
      final startDay = subscriptionStartDate.day;

      if (startDay >= 1 && startDay <= 20) {
        // Pro-rated first payment
        final totalDaysInMonth = _getDaysInMonth(subscriptionStartDate);
        final remainingDays = totalDaysInMonth - startDay + 1;
        baseAmount = (remainingDays / totalDaysInMonth) * monthlyRent;
        condition = 'first_payment_prorated';
        description = 'First payment (pro-rated for $remainingDays days)';
      } else {
        // Post-20th start - current month pro-rated
        final totalDaysInMonth = _getDaysInMonth(subscriptionStartDate);
        final remainingDays = totalDaysInMonth - startDay + 1;
        baseAmount = (remainingDays / totalDaysInMonth) * monthlyRent;
        condition = 'first_payment_post_20th_current';
        description = 'First payment current month (₹${baseAmount.toStringAsFixed(0)} for $remainingDays days)';
      }
    } else if (isFirstPayment && targetMonth.isAfter(subscriptionMonth)) {
      // First payment for month after subscription start (full amount)
      final subscriptionDay = subscriptionStartDate.day;
      if (subscriptionDay >= 21) {
        condition = 'first_payment_post_20th_next';
        description = 'First payment next month (full amount)';
      } else {
        condition = 'regular';
        description = 'Regular monthly payment';
      }
    } else {
      // Regular payment - check for late fees
      final gracePeriod = DateTime(targetMonthYear.year, targetMonthYear.month, 3);

      if (selectedPaymentDate.isAfter(gracePeriod)) {
        // Calculate late fee: 0.8% per day
        final daysLate = selectedPaymentDate.difference(gracePeriod).inDays;
        lateFee = monthlyRent * 0.008 * daysLate;
        condition = 'regular_with_late_fee';
        description = 'Regular payment with late fee ($daysLate days late)';
      } else {
        condition = 'regular';
        description = 'Regular monthly payment';
      }
    }

    final totalAmount = baseAmount + lateFee;

    return {
      'baseAmount': baseAmount,
      'lateFee': lateFee,
      'totalAmount': totalAmount,
      'condition': condition,
      'description': description,
      'isFirstPayment': isFirstPayment,
      'formattedBaseAmount': '₹${baseAmount.toStringAsFixed(0)}',
      'formattedLateFee': lateFee > 0 ? '₹${lateFee.toStringAsFixed(0)}' : null,
      'formattedTotalAmount': '₹${totalAmount.toStringAsFixed(0)}',
      'monthYear': targetMonth,
    };
  }

  /// Get available months for payment (admin-style)
  static Future<List<Map<String, dynamic>>> getAvailableMonthsForPayment({
    required String? subscriptionId,
    required DateTime subscriptionStartDate,
    required double monthlyRent,
    required DateTime selectedPaymentDate,
    DateTime? currentDateOverride,
  }) async {
    final currentDate = currentDateOverride ?? DateTime.now();
    final availableMonths = <Map<String, dynamic>>[];

    // Get existing payments to exclude already paid months
    Set<DateTime> paidMonths = {};
    if (subscriptionId != null) {
      try {
        final existingPayments = await getPaymentsBySubscription(subscriptionId);
        paidMonths = existingPayments
            .map((p) => DateTime(p.monthYear.year, p.monthYear.month, 1))
            .toSet();
      } catch (e) {
        // Continue without existing payments if error
      }
    }

    // Generate months from subscription start to current + 1 year
    final endDate = DateTime(currentDate.year + 1, currentDate.month, 1);
    DateTime monthIterator = DateTime(subscriptionStartDate.year, subscriptionStartDate.month, 1);

    while (monthIterator.isBefore(endDate)) {
      if (!paidMonths.contains(monthIterator)) {
        // Calculate payment for this month
        final paymentData = await calculatePaymentWithConditions(
          subscriptionId: subscriptionId,
          subscriptionStartDate: subscriptionStartDate,
          monthlyRent: monthlyRent,
          selectedPaymentDate: selectedPaymentDate,
          targetMonthYear: monthIterator,
          currentDateOverride: currentDateOverride,
        );

        availableMonths.add({
          'monthYear': monthIterator,
          'amount': paymentData['totalAmount'],
          'baseAmount': paymentData['baseAmount'],
          'lateFee': paymentData['lateFee'],
          'condition': paymentData['condition'],
          'description': paymentData['description'],
          'isRecommended': _isRecommendedMonth(
            monthIterator,
            subscriptionStartDate,
            selectedPaymentDate,
            paymentData['isFirstPayment'],
          ),
        });
      }

      // Move to next month
      if (monthIterator.month == 12) {
        monthIterator = DateTime(monthIterator.year + 1, 1, 1);
      } else {
        monthIterator = DateTime(monthIterator.year, monthIterator.month + 1, 1);
      }
    }

    return availableMonths;
  }

  /// Determine if a month should be recommended for selection
  static bool _isRecommendedMonth(
    DateTime monthYear,
    DateTime subscriptionStartDate,
    DateTime selectedPaymentDate,
    bool isFirstPayment,
  ) {
    final subscriptionMonth = DateTime(subscriptionStartDate.year, subscriptionStartDate.month, 1);

    if (!isFirstPayment) {
      // For regular payments, recommend current month if not too far in future
      final paymentMonth = DateTime(selectedPaymentDate.year, selectedPaymentDate.month, 1);
      return monthYear == paymentMonth;
    }

    // For first payments
    final startDay = subscriptionStartDate.day;

    if (startDay >= 1 && startDay <= 20) {
      // Recommend subscription start month only
      return monthYear == subscriptionMonth;
    } else {
      // Post-20th: recommend both current and next month
      final nextMonth = DateTime(
        subscriptionStartDate.month == 12 ? subscriptionStartDate.year + 1 : subscriptionStartDate.year,
        subscriptionStartDate.month == 12 ? 1 : subscriptionStartDate.month + 1,
        1,
      );
      return monthYear == subscriptionMonth || monthYear == nextMonth;
    }
  }

  /// Create payment record
  static Future<String> createPayment({
    required String subscriptionId,
    required DateTime monthYear,
    required double amountPaid,
    required DateTime paidDate,
    String? paymentMethod,
    String? transactionReference,
    String? notes,
    String? paymentGroupId,
  }) async {
    try {
      final response = await _supabase
          .from('payments')
          .insert({
            'subscription_id': subscriptionId,
            'month_year': monthYear.toIso8601String().split('T')[0],
            'amount_paid': amountPaid,
            'paid_date': paidDate.toIso8601String().split('T')[0],
            'payment_method': paymentMethod,
            'transaction_reference': transactionReference,
            'notes': notes,
            'payment_group_id': paymentGroupId,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Create multiple payments (for post-20th first payments)
  static Future<List<String>> createMultiplePayments({
    required String subscriptionId,
    required List<Map<String, dynamic>> paymentData,
    String? paymentGroupId,
  }) async {
    try {
      final payments = paymentData.map((data) => {
        ...data,
        'subscription_id': subscriptionId,
        'payment_group_id': paymentGroupId,
      }).toList();

      final response = await _supabase
          .from('payments')
          .insert(payments)
          .select('id');

      return response.map((row) => row['id'] as String).toList();
    } catch (e) {
      throw Exception('Failed to create multiple payments: $e');
    }
  }

  /// Get payments for a subscription
  static Future<List<Payment>> getPaymentsBySubscription(String subscriptionId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('subscription_id', subscriptionId)
          .order('month_year', ascending: false);

      return response.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Check if payment exists for specific month
  static Future<bool> hasPaymentForMonth({
    required String subscriptionId,
    required DateTime monthYear,
  }) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('id')
          .eq('subscription_id', subscriptionId)
          .eq('month_year', monthYear.toIso8601String().split('T')[0])
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check payment existence: $e');
    }
  }

  /// Utility: Get days in month
  static int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

}