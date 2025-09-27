import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'subscription_service.dart';
import 'payment_service.dart';

class BookingService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Complete booking flow: Create subscription + payments + update room
  static Future<Map<String, dynamic>> createBooking({
    required String roomId,
    required String tenantId,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime startDate,
    required DateTime paymentDate,
    required List<Map<String, dynamic>> paymentCalculations,
    String? notes,
    String? paymentMethod,
  }) async {
    // Validate inputs
    final validationErrors = SubscriptionService.validateSubscriptionData(
      roomId: roomId,
      tenantId: tenantId,
      monthlyRent: monthlyRent,
      securityDeposit: securityDeposit,
      startDate: startDate,
    );

    if (validationErrors.isNotEmpty) {
      throw Exception('Validation failed: ${validationErrors.values.join(', ')}');
    }

    // Check room availability
    final isAvailable = await SubscriptionService.isRoomAvailableForSubscription(roomId);
    if (!isAvailable) {
      throw Exception('Room is not available for subscription');
    }

    // Start database transaction
    try {
      final result = await _supabase.rpc('create_booking_transaction', params: {
        'p_room_id': roomId,
        'p_tenant_id': tenantId,
        'p_monthly_rent': monthlyRent,
        'p_security_deposit': securityDeposit,
        'p_start_date': startDate.toIso8601String().split('T')[0],
        'p_notes': notes,
        'p_payment_data': paymentCalculations,
        'p_payment_date': paymentDate.toIso8601String().split('T')[0],
        'p_payment_method': paymentMethod,
      });

      if (result != null && result['success'] == true) {
        return {
          'success': true,
          'subscriptionId': result['subscription_id'],
          'paymentIds': result['payment_ids'],
          'message': 'Booking created successfully',
        };
      } else {
        throw Exception(result?['error'] ?? 'Unknown error during booking');
      }
    } catch (e) {
      // Fallback to manual transaction if RPC doesn't exist
      return await _createBookingManual(
        roomId: roomId,
        tenantId: tenantId,
        monthlyRent: monthlyRent,
        securityDeposit: securityDeposit,
        startDate: startDate,
        paymentDate: paymentDate,
        paymentCalculations: paymentCalculations,
        notes: notes,
        paymentMethod: paymentMethod,
      );
    }
  }

  /// Manual booking creation (fallback)
  static Future<Map<String, dynamic>> _createBookingManual({
    required String roomId,
    required String tenantId,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime startDate,
    required DateTime paymentDate,
    required List<Map<String, dynamic>> paymentCalculations,
    String? notes,
    String? paymentMethod,
  }) async {
    String? subscriptionId;
    List<String> paymentIds = [];

    try {
      // Step 1: Create subscription
      subscriptionId = await SubscriptionService.createSubscription(
        roomId: roomId,
        tenantId: tenantId,
        monthlyRent: monthlyRent,
        securityDeposit: securityDeposit,
        startDate: startDate,
        notes: notes,
      );

      // Step 2: Create payment group ID for multiple payments
      final paymentGroupId = paymentCalculations.length > 1 ? _uuid.v4() : null;

      // Step 3: Create payments
      for (final calc in paymentCalculations) {
        final paymentId = await PaymentService.createPayment(
          subscriptionId: subscriptionId,
          monthYear: calc['monthYear'],
          amountPaid: calc['totalAmount'],
          paidDate: paymentDate,
          paymentMethod: paymentMethod,
          notes: calc['description'],
          paymentGroupId: paymentGroupId,
        );
        paymentIds.add(paymentId);
      }

      // Step 4: Update room availability
      await _updateRoomAvailability(roomId, 'occupied');

      return {
        'success': true,
        'subscriptionId': subscriptionId,
        'paymentIds': paymentIds,
        'message': 'Booking created successfully',
      };
    } catch (e) {
      // Rollback on error
      await _rollbackBooking(subscriptionId, paymentIds, roomId);
      throw Exception('Booking failed: $e');
    }
  }

  /// Calculate complete booking costs
  static Future<Map<String, dynamic>> calculateBookingCosts({
    required String roomId,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime startDate,
    required DateTime paymentDate,
    DateTime? currentDateOverride,
  }) async {
    try {
      // Get available months for payment selection
      final availableMonths = await PaymentService.getAvailableMonthsForPayment(
        subscriptionId: null, // New subscription
        subscriptionStartDate: startDate,
        monthlyRent: monthlyRent,
        selectedPaymentDate: paymentDate,
        currentDateOverride: currentDateOverride,
      );

      // Calculate totals from available months
      List<Map<String, dynamic>> monthlyCalculations = [];
      double totalRentAmount = 0.0;
      double totalLateFees = 0.0;

      for (final monthData in availableMonths) {
        if (monthData['isRecommended'] == true) {
          final calc = {
            'monthYear': monthData['monthYear'],
            'baseAmount': monthData['baseAmount'],
            'lateFee': monthData['lateFee'],
            'totalAmount': monthData['amount'],
            'condition': monthData['condition'],
            'description': monthData['description'],
            'formattedTotal': '₹${(monthData['amount'] as double).toStringAsFixed(0)}',
          };

          monthlyCalculations.add(calc);
          totalRentAmount += monthData['baseAmount'];
          totalLateFees += monthData['lateFee'];
        }
      }

      final totalUpfrontCost = totalRentAmount + totalLateFees + securityDeposit;

      return {
        'monthlyCalculations': monthlyCalculations,
        'totalRentAmount': totalRentAmount,
        'totalLateFees': totalLateFees,
        'securityDeposit': securityDeposit,
        'totalUpfrontCost': totalUpfrontCost,
        'formattedTotalRent': '₹${totalRentAmount.toStringAsFixed(0)}',
        'formattedTotalLateFees': totalLateFees > 0 ? '₹${totalLateFees.toStringAsFixed(0)}' : null,
        'formattedSecurityDeposit': '₹${securityDeposit.toStringAsFixed(0)}',
        'formattedTotalUpfront': '₹${totalUpfrontCost.toStringAsFixed(0)}',
        'availableMonths': availableMonths,
      };
    } catch (e) {
      throw Exception('Failed to calculate booking costs: $e');
    }
  }

  /// Update room availability status
  static Future<void> _updateRoomAvailability(String roomId, String status) async {
    try {
      await _supabase
          .from('rooms')
          .update({'availability_status': status})
          .eq('id', roomId);
    } catch (e) {
      throw Exception('Failed to update room availability: $e');
    }
  }

  /// Rollback booking on error
  static Future<void> _rollbackBooking(
    String? subscriptionId,
    List<String> paymentIds,
    String roomId,
  ) async {
    try {
      // Delete payments
      if (paymentIds.isNotEmpty) {
        await _supabase
            .from('payments')
            .delete()
            .inFilter('id', paymentIds);
      }

      // Delete subscription
      if (subscriptionId != null) {
        await _supabase
            .from('subscriptions')
            .delete()
            .eq('id', subscriptionId);
      }

      // Reset room availability
      await _updateRoomAvailability(roomId, 'available');
    } catch (e) {
      // Log rollback error but don't throw (original error is more important)
      print('Rollback error: $e');
    }
  }

  /// Validate booking prerequisites
  static Future<Map<String, dynamic>> validateBookingPrerequisites({
    required String roomId,
    required String tenantId,
  }) async {
    try {
      final issues = <String>[];
      final warnings = <String>[];

      // Check room availability
      final isRoomAvailable = await SubscriptionService.isRoomAvailableForSubscription(roomId);
      if (!isRoomAvailable) {
        issues.add('Room is not available for booking');
      }

      // Check if tenant has other active subscriptions
      final activeSubscriptions = await SubscriptionService.getActiveSubscriptionsByTenant(tenantId);
      if (activeSubscriptions.isNotEmpty) {
        warnings.add('Tenant has ${activeSubscriptions.length} active subscription(s)');
      }

      // Check tenant profile completeness (though UI should already handle this)
      // This is just a safety check
      final profileResponse = await _supabase
          .from('profiles')
          .select('full_name, date_of_birth, phone, email')
          .eq('id', tenantId)
          .maybeSingle();

      if (profileResponse == null) {
        issues.add('Tenant profile not found');
      } else {
        final missingFields = <String>[];
        if (profileResponse['full_name'] == null || (profileResponse['full_name'] as String).isEmpty) {
          missingFields.add('full name');
        }
        if (profileResponse['phone'] == null || (profileResponse['phone'] as String).isEmpty) {
          missingFields.add('phone number');
        }
        if (profileResponse['date_of_birth'] == null) {
          missingFields.add('date of birth');
        }
        if (profileResponse['email'] == null || (profileResponse['email'] as String).isEmpty) {
          missingFields.add('email');
        }
        // Temporarily disabled identification requirement for easier testing
        // if (profileResponse['identification_file_url'] == null) {
        //   missingFields.add('identification document');
        // }

        if (missingFields.isNotEmpty) {
          issues.add('Profile incomplete: missing ${missingFields.join(', ')}');
        }
      }

      return {
        'canProceed': issues.isEmpty,
        'issues': issues,
        'warnings': warnings,
      };
    } catch (e) {
      return {
        'canProceed': false,
        'issues': ['Failed to validate prerequisites: $e'],
        'warnings': <String>[],
      };
    }
  }

  /// Get booking summary for confirmation
  static Future<Map<String, dynamic>> getBookingSummary({
    required String roomId,
    required String tenantId,
    required DateTime startDate,
    required DateTime paymentDate,
    DateTime? currentDateOverride,
  }) async {
    try {
      // Get room details
      final roomResponse = await _supabase
          .from('rooms')
          .select('''
            id,
            room_number,
            room_type,
            fee,
            security_deposit,
            buildings:building_id (
              id,
              name,
              address,
              cities:city_id (name)
            )
          ''')
          .eq('id', roomId)
          .single();

      // Get tenant details
      final tenantResponse = await _supabase
          .from('profiles')
          .select('id, full_name, email, phone')
          .eq('id', tenantId)
          .single();

      final monthlyRent = (roomResponse['fee'] as num).toDouble();
      final securityDeposit = roomResponse['security_fee'] != null
          ? (roomResponse['security_fee'] as num).toDouble()
          : 0.0;

      // Calculate costs
      final costs = await calculateBookingCosts(
        roomId: roomId,
        monthlyRent: monthlyRent,
        securityDeposit: securityDeposit,
        startDate: startDate,
        paymentDate: paymentDate,
        currentDateOverride: currentDateOverride,
      );

      return {
        'room': roomResponse,
        'tenant': tenantResponse,
        'monthlyRent': monthlyRent,
        'securityDeposit': securityDeposit,
        'startDate': startDate,
        'paymentDate': paymentDate,
        'costs': costs,
        'formattedStartDate': '${startDate.day}/${startDate.month}/${startDate.year}',
        'formattedPaymentDate': '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}',
      };
    } catch (e) {
      throw Exception('Failed to generate booking summary: $e');
    }
  }
}