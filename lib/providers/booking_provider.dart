import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';

class MonthSelection {
  final DateTime monthYear;
  final double amount;
  final double baseAmount;
  final double lateFee;
  final String condition;
  final String description;
  final bool isSelected;
  final bool isRecommended;

  const MonthSelection({
    required this.monthYear,
    required this.amount,
    required this.baseAmount,
    required this.lateFee,
    required this.condition,
    required this.description,
    required this.isSelected,
    required this.isRecommended,
  });

  MonthSelection copyWith({bool? isSelected}) {
    return MonthSelection(
      monthYear: monthYear,
      amount: amount,
      baseAmount: baseAmount,
      lateFee: lateFee,
      condition: condition,
      description: description,
      isSelected: isSelected ?? this.isSelected,
      isRecommended: isRecommended,
    );
  }
}

class BookingProvider extends ChangeNotifier {
  // Booking state
  RoomDetail? _roomDetail;
  String? _tenantId;
  DateTime? _startDate;
  DateTime? _paymentDate; // When payment is being made
  DateTime? _currentDateOverride;

  // Month selection (admin-style)
  List<MonthSelection> _availableMonths = [];
  List<MonthSelection> _selectedMonths = [];

  // UI state
  bool _isLoadingMonths = false;
  bool _isBooking = false;
  String? _error;
  String? _successMessage;

  // Getters
  RoomDetail? get roomDetail => _roomDetail;
  String? get tenantId => _tenantId;
  DateTime? get startDate => _startDate;
  DateTime? get paymentDate => _paymentDate;
  DateTime? get currentDateOverride => _currentDateOverride;
  List<MonthSelection> get availableMonths => _availableMonths;
  List<MonthSelection> get selectedMonths => _selectedMonths;
  bool get isLoadingMonths => _isLoadingMonths;
  bool get isBooking => _isBooking;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Computed properties
  bool get canLoadMonths => _roomDetail != null && _startDate != null && _paymentDate != null;
  bool get canBook => _selectedMonths.isNotEmpty && !_isBooking;
  double get monthlyRent => _roomDetail?.fee ?? 0.0;
  double get securityDeposit => _roomDetail?.securityFee ?? 0.0;
  double get totalSelectedAmount => _selectedMonths.fold(0.0, (sum, month) => sum + month.amount);
  double get totalUpfrontCost => totalSelectedAmount + securityDeposit;

  /// Initialize booking with room details
  void initializeBooking({
    required RoomDetail roomDetail,
    required String tenantId,
    DateTime? startDate,
  }) {
    _roomDetail = roomDetail;
    _tenantId = tenantId;
    _startDate = startDate ?? DateTime.now();
    _paymentDate = DateTime.now(); // When payment is being made
    _error = null;
    _successMessage = null;
    _availableMonths = [];
    _selectedMonths = [];
    notifyListeners();

    // Auto-load available months
    if (canLoadMonths) {
      loadAvailableMonths();
    }
  }

  /// Update start date
  void updateStartDate(DateTime date) {
    _startDate = date;
    _error = null;
    notifyListeners();

    if (canLoadMonths) {
      loadAvailableMonths();
    }
  }

  /// Update payment date (when payment is being made)
  void updatePaymentDate(DateTime date) {
    _paymentDate = date;
    _error = null;
    notifyListeners();

    if (canLoadMonths) {
      loadAvailableMonths();
    }
  }

  /// Set current date override for testing
  void setCurrentDateOverride(DateTime? date) {
    _currentDateOverride = date;
    notifyListeners();

    if (canLoadMonths) {
      loadAvailableMonths();
    }
  }

  /// Load available months for payment selection (admin-style)
  Future<void> loadAvailableMonths() async {
    if (!canLoadMonths) return;

    _isLoadingMonths = true;
    _error = null;
    notifyListeners();

    try {
      final availableMonthsData = await PaymentService.getAvailableMonthsForPayment(
        subscriptionId: null, // New subscription
        subscriptionStartDate: _startDate!,
        monthlyRent: monthlyRent,
        selectedPaymentDate: _paymentDate!,
        currentDateOverride: _currentDateOverride,
      );

      _availableMonths = availableMonthsData.map((data) {
        return MonthSelection(
          monthYear: data['monthYear'],
          amount: data['amount'],
          baseAmount: data['baseAmount'],
          lateFee: data['lateFee'],
          condition: data['condition'],
          description: data['description'],
          isSelected: data['isRecommended'], // Auto-select recommended months
          isRecommended: data['isRecommended'],
        );
      }).toList();

      _selectedMonths = _availableMonths.where((month) => month.isSelected).toList();
    } catch (e) {
      _error = 'Failed to load available months: $e';
      _availableMonths = [];
      _selectedMonths = [];
    } finally {
      _isLoadingMonths = false;
      notifyListeners();
    }
  }

  /// Toggle month selection
  void toggleMonthSelection(MonthSelection month, bool? selected) {
    final index = _availableMonths.indexWhere((m) => m.monthYear == month.monthYear);
    if (index != -1) {
      _availableMonths[index] = month.copyWith(isSelected: selected);
      _selectedMonths = _availableMonths.where((month) => month.isSelected).toList();
      _error = null;
      notifyListeners();
    }
  }

  /// Get condition color for UI
  Color getConditionColor(String condition) {
    switch (condition) {
      case 'first_payment_prorated':
        return Colors.green;
      case 'first_payment_post_20th_current':
      case 'first_payment_post_20th_next':
        return Colors.orange;
      case 'regular_with_late_fee':
        return Colors.red;
      case 'regular':
      default:
        return Colors.blue;
    }
  }

  /// Get condition badge text
  String getConditionBadgeText(String condition) {
    switch (condition) {
      case 'first_payment_prorated':
        return 'FIRST';
      case 'first_payment_post_20th_current':
        return 'FIRST (PRORATED)';
      case 'first_payment_post_20th_next':
        return 'FIRST (FULL)';
      case 'regular_with_late_fee':
        return 'LATE';
      case 'regular':
      default:
        return 'REGULAR';
    }
  }

  /// Validate booking prerequisites
  Future<Map<String, dynamic>> validatePrerequisites() async {
    if (_roomDetail == null || _tenantId == null) {
      return {
        'canProceed': false,
        'issues': ['Missing room or tenant information'],
        'warnings': <String>[],
      };
    }

    try {
      return await BookingService.validateBookingPrerequisites(
        roomId: _roomDetail!.id,
        tenantId: _tenantId!,
      );
    } catch (e) {
      return {
        'canProceed': false,
        'issues': ['Validation failed: $e'],
        'warnings': <String>[],
      };
    }
  }

  /// Create booking with selected months
  Future<String?> createBooking({
    String? notes,
    String? paymentMethod,
  }) async {
    if (!canBook || _tenantId == null || _selectedMonths.isEmpty) {
      _error = 'Cannot create booking: missing required data';
      notifyListeners();
      return null;
    }

    _isBooking = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Validate prerequisites first
      final validation = await validatePrerequisites();
      if (!validation['canProceed']) {
        final issues = validation['issues'] as List<String>;
        throw Exception(issues.join(', '));
      }

      // Prepare payment calculations from selected months
      final monthlyCalcs = _selectedMonths.map((month) => {
        'monthYear': month.monthYear,
        'totalAmount': month.amount,
        'description': month.description,
      }).toList();

      // Create booking
      final result = await BookingService.createBooking(
        roomId: _roomDetail!.id,
        tenantId: _tenantId!,
        monthlyRent: monthlyRent,
        securityDeposit: securityDeposit,
        startDate: _startDate!,
        paymentDate: _paymentDate!,
        paymentCalculations: monthlyCalcs,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      if (result['success'] == true) {
        _successMessage = result['message'];
        final subscriptionId = result['subscriptionId'] as String;
        return subscriptionId;
      } else {
        throw Exception('Booking failed: ${result['message']}');
      }
    } catch (e) {
      _error = 'Booking failed: $e';
      return null;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Reset booking state
  void reset() {
    _roomDetail = null;
    _tenantId = null;
    _startDate = null;
    _paymentDate = null;
    _currentDateOverride = null;
    _availableMonths = [];
    _selectedMonths = [];
    _isLoadingMonths = false;
    _isBooking = false;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Check if has late fees in selected months
  bool hasLateFees() {
    return _selectedMonths.any((month) => month.lateFee > 0);
  }

  /// Get total late fees
  double getTotalLateFees() {
    return _selectedMonths.fold(0.0, (sum, month) => sum + month.lateFee);
  }

  /// Get formatted late fees
  String? getFormattedLateFees() {
    if (!hasLateFees()) return null;
    return '₹${getTotalLateFees().toStringAsFixed(0)}';
  }

  /// Get formatted total upfront cost
  String getFormattedTotalUpfrontCost() {
    return '₹${totalUpfrontCost.toStringAsFixed(0)}';
  }
}