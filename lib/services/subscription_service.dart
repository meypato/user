import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SubscriptionService {
  static final _supabase = Supabase.instance.client;

  /// Create a new subscription
  static Future<String> createSubscription({
    required String roomId,
    required String tenantId,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime startDate,
    String? notes,
  }) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .insert({
            'room_id': roomId,
            'tenant_id': tenantId,
            'monthly_rent': monthlyRent,
            'security_deposit': securityDeposit,
            'start_date': startDate.toIso8601String().split('T')[0],
            'is_active': true,
            'status': 'active',
            'notes': notes,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  /// Get subscription by ID
  static Future<Subscription?> getSubscriptionById(String subscriptionId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('id', subscriptionId)
          .maybeSingle();

      if (response == null) return null;
      return Subscription.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch subscription: $e');
    }
  }

  /// Get active subscription for a room
  static Future<Subscription?> getActiveSubscriptionForRoom(String roomId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('room_id', roomId)
          .eq('is_active', true)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;
      return Subscription.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch room subscription: $e');
    }
  }

  /// Get all subscriptions for a tenant
  static Future<List<Subscription>> getSubscriptionsByTenant(String tenantId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      return response.map((json) => Subscription.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tenant subscriptions: $e');
    }
  }

  /// Get active subscriptions for a tenant
  static Future<List<Subscription>> getActiveSubscriptionsByTenant(String tenantId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .eq('status', 'active')
          .order('start_date', ascending: false);

      return response.map((json) => Subscription.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch active subscriptions: $e');
    }
  }

  /// Update subscription
  static Future<void> updateSubscription({
    required String subscriptionId,
    double? monthlyRent,
    double? securityDeposit,
    bool? isActive,
    String? status,
    String? notes,
    String? agreementFileUrl,
    DateTime? terminationDate,
    String? terminatedByAgentId,
    String? terminationReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (monthlyRent != null) updateData['monthly_rent'] = monthlyRent;
      if (securityDeposit != null) updateData['security_deposit'] = securityDeposit;
      if (isActive != null) updateData['is_active'] = isActive;
      if (status != null) updateData['status'] = status;
      if (notes != null) updateData['notes'] = notes;
      if (agreementFileUrl != null) updateData['agreement_file_url'] = agreementFileUrl;
      if (terminationDate != null) {
        updateData['termination_date'] = terminationDate.toIso8601String().split('T')[0];
      }
      if (terminatedByAgentId != null) updateData['terminated_by_agent_id'] = terminatedByAgentId;
      if (terminationReason != null) updateData['termination_reason'] = terminationReason;

      await _supabase
          .from('subscriptions')
          .update(updateData)
          .eq('id', subscriptionId);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  /// Terminate subscription
  static Future<void> terminateSubscription({
    required String subscriptionId,
    required DateTime terminationDate,
    String? terminatedByAgentId,
    String? terminationReason,
  }) async {
    try {
      await updateSubscription(
        subscriptionId: subscriptionId,
        isActive: false,
        status: 'terminated',
        terminationDate: terminationDate,
        terminatedByAgentId: terminatedByAgentId,
        terminationReason: terminationReason,
      );
    } catch (e) {
      throw Exception('Failed to terminate subscription: $e');
    }
  }

  /// Check if room is available for new subscription
  static Future<bool> isRoomAvailableForSubscription(String roomId) async {
    try {
      // Check for active subscriptions
      final activeSubscription = await getActiveSubscriptionForRoom(roomId);

      // Also check room availability status
      final roomResponse = await _supabase
          .from('rooms')
          .select('availability_status')
          .eq('id', roomId)
          .single();

      final roomStatus = roomResponse['availability_status'] as String;

      return activeSubscription == null && roomStatus == 'available';
    } catch (e) {
      throw Exception('Failed to check room availability: $e');
    }
  }

  /// Get subscription with room and building details
  static Future<Map<String, dynamic>?> getSubscriptionWithDetails(String subscriptionId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('''
            *,
            rooms:room_id (
              id,
              room_number,
              room_type,
              fee,
              buildings:building_id (
                id,
                name,
                building_type,
                address_line1,
                cities:city_id (
                  id,
                  name
                )
              )
            ),
            profiles:tenant_id (
              id,
              full_name,
              phone,
              email
            )
          ''')
          .eq('id', subscriptionId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch subscription details: $e');
    }
  }

  /// Get subscription statistics for a tenant
  static Future<Map<String, dynamic>> getSubscriptionStats(String tenantId) async {
    try {
      // Get all subscriptions
      final allSubscriptions = await getSubscriptionsByTenant(tenantId);

      // Get active subscriptions
      final activeSubscriptions = allSubscriptions.where((s) => s.isActive).toList();

      // Calculate total months of tenancy
      int totalMonths = 0;
      for (final subscription in allSubscriptions) {
        totalMonths += subscription.tenancyDurationInMonths;
      }

      // Get payment statistics
      final paymentStats = await _getPaymentStats(tenantId);

      return {
        'totalSubscriptions': allSubscriptions.length,
        'activeSubscriptions': activeSubscriptions.length,
        'totalMonthsOfTenancy': totalMonths,
        'totalAmountPaid': paymentStats['totalPaid'] ?? 0.0,
        'totalPayments': paymentStats['totalPayments'] ?? 0,
        'averageMonthlyRent': activeSubscriptions.isNotEmpty
            ? activeSubscriptions.map((s) => s.monthlyRent).reduce((a, b) => a + b) / activeSubscriptions.length
            : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch subscription statistics: $e');
    }
  }

  /// Helper: Get payment statistics for tenant
  static Future<Map<String, dynamic>> _getPaymentStats(String tenantId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            amount_paid,
            subscriptions!inner(tenant_id)
          ''')
          .eq('subscriptions.tenant_id', tenantId);

      final totalPaid = response.fold<double>(
        0.0,
        (sum, payment) => sum + (payment['amount_paid'] as num).toDouble(),
      );

      return {
        'totalPaid': totalPaid,
        'totalPayments': response.length,
      };
    } catch (e) {
      return {'totalPaid': 0.0, 'totalPayments': 0};
    }
  }

  /// Upload agreement file
  static Future<void> uploadAgreementFile({
    required String subscriptionId,
    required String agreementFileUrl,
  }) async {
    try {
      await updateSubscription(
        subscriptionId: subscriptionId,
        agreementFileUrl: agreementFileUrl,
      );
    } catch (e) {
      throw Exception('Failed to upload agreement file: $e');
    }
  }

  /// Validate subscription data before creation
  static Map<String, String> validateSubscriptionData({
    required String roomId,
    required String tenantId,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime startDate,
  }) {
    final errors = <String, String>{};

    if (roomId.isEmpty) {
      errors['roomId'] = 'Room ID is required';
    }

    if (tenantId.isEmpty) {
      errors['tenantId'] = 'Tenant ID is required';
    }

    if (monthlyRent <= 0) {
      errors['monthlyRent'] = 'Monthly rent must be greater than 0';
    }

    if (securityDeposit < 0) {
      errors['securityDeposit'] = 'Security deposit cannot be negative';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    if (startDateOnly.isBefore(today)) {
      errors['startDate'] = 'Start date cannot be in the past';
    }

    return errors;
  }
}