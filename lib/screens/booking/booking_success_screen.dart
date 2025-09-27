import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colour.dart';
import '../../services/subscription_service.dart';

class BookingSuccessScreen extends StatefulWidget {
  final String subscriptionId;

  const BookingSuccessScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  Map<String, dynamic>? _subscriptionDetails;
  bool _isLoading = true;
  String? _error;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _loadSubscriptionDetails();
  }

  Future<void> _loadSubscriptionDetails() async {
    await _loadWithRetry();
  }

  Future<void> _loadWithRetry() async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        print('Loading subscription details - Attempt ${attempt + 1}/${_maxRetries + 1}');

        final details = await SubscriptionService.getSubscriptionWithDetails(widget.subscriptionId);
        print('Subscription details loaded: $details'); // Debug output

        if (details == null) {
          throw Exception('Subscription not found - may still be processing');
        }

        // Success - update state and exit
        setState(() {
          _subscriptionDetails = details;
          _isLoading = false;
          _error = null;
          _retryCount = attempt;
        });
        return;

      } catch (e) {
        print('Attempt ${attempt + 1} failed: $e');

        if (attempt < _maxRetries) {
          // Wait before retry
          print('Retrying in ${_retryDelay.inSeconds} seconds...');
          await Future.delayed(_retryDelay);

          // Update UI to show retry attempt
          setState(() {
            _retryCount = attempt + 1;
          });
        } else {
          // Final failure
          print('All retry attempts failed');
          setState(() {
            _error = 'Failed to load subscription details after ${_maxRetries + 1} attempts: ${e.toString()}';
            _isLoading = false;
            _retryCount = attempt;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        title: Text(
          'Booking Confirmed',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: _buildBody(theme, isDark),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(theme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            const SizedBox(height: 16),
            Text(
              _retryCount == 0
                  ? 'Loading booking details...'
                  : 'Retrying... ($_retryCount/$_maxRetries)',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState(theme, isDark);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildSuccessHeader(theme, isDark),
          _buildSubscriptionCard(theme, isDark),
          _buildPaymentSummaryCard(theme, isDark),
          _buildNextStepsCard(theme, isDark),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking was successful, but we couldn\'t load the details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Subscription ID: ${widget.subscriptionId}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Booking Confirmed!',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your rental subscription has been created successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme, bool isDark) {
    if (_subscriptionDetails == null) return const SizedBox.shrink();

    final subscription = _subscriptionDetails!;

    // Handle potential data structure issues
    final room = subscription['rooms'] as Map<String, dynamic>?;
    if (room == null) {
      return _buildErrorCard('Room data not found', theme, isDark);
    }

    final building = room['buildings'] as Map<String, dynamic>?;
    if (building == null) {
      return _buildErrorCard('Building data not found', theme, isDark);
    }

    final city = building['cities'] as Map<String, dynamic>?;
    if (city == null) {
      return _buildErrorCard('City data not found', theme, isDark);
    }

    final tenant = subscription['profiles'] as Map<String, dynamic>?;
    if (tenant == null) {
      return _buildErrorCard('Tenant data not found', theme, isDark);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Subscription Details',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Subscription ID', widget.subscriptionId, theme, isDark, isMonospace: true),
          _buildDetailRow('Room', '${room['room_number']} - ${room['room_type']}', theme, isDark),
          _buildDetailRow('Building', building['name'], theme, isDark),
          _buildDetailRow('Address', building['address_line1'], theme, isDark),
          _buildDetailRow('Location', city['name'], theme, isDark),
          _buildDetailRow('Tenant', tenant['full_name'] ?? 'Unknown', theme, isDark),
          _buildDetailRow('Monthly Rent', '₹${(subscription['monthly_rent'] as num).toStringAsFixed(0)}', theme, isDark),
          _buildDetailRow('Security Deposit', '₹${(subscription['security_deposit'] as num).toStringAsFixed(0)}', theme, isDark),
          _buildDetailRow('Start Date', _formatDate(subscription['start_date']), theme, isDark),
          _buildDetailRow('Status', subscription['status'], theme, isDark, isStatus: true),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme, bool isDark) {
    if (_subscriptionDetails == null) return const SizedBox.shrink();

    final subscription = _subscriptionDetails!;
    final monthlyRent = subscription['monthly_rent'] as num;
    final securityDeposit = subscription['security_deposit'] as num;
    final totalPaid = monthlyRent + securityDeposit;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Summary',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Initial Rent Payment', '₹${monthlyRent.toStringAsFixed(0)}', theme, isDark),
          _buildPaymentRow('Security Deposit', '₹${securityDeposit.toStringAsFixed(0)}', theme, isDark),
          const Divider(height: 20),
          _buildPaymentRow('Total Paid', '₹${totalPaid.toStringAsFixed(0)}', theme, isDark, isTotal: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment successful - Subscription activated',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'What\'s Next?',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNextStepItem(
            Icons.key,
            'Collect Keys',
            'Contact the property owner to arrange key handover',
            theme,
            isDark,
          ),
          _buildNextStepItem(
            Icons.description,
            'Rental Agreement',
            'A digital rental agreement will be prepared for signing',
            theme,
            isDark,
          ),
          _buildNextStepItem(
            Icons.payment,
            'Monthly Payments',
            'Your next payment is due on the 1st of next month',
            theme,
            isDark,
          ),
          _buildNextStepItem(
            Icons.support_agent,
            'Support',
            'Contact Meypato support for any questions or assistance',
            theme,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, bool isDark, {bool isMonospace = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isStatus && value.toLowerCase() == 'active'
                    ? Colors.green
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, ThemeData theme, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal
                  ? const Color(0xFF00E676)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(IconData icon, String title, String description, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go('/profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Subscriptions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildErrorCard(String message, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
