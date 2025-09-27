import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_colour.dart';
import '../providers/booking_provider.dart';

class PaymentCalculationCard extends StatelessWidget {
  const PaymentCalculationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingMonths) {
          return _buildLoadingCard(theme, isDark);
        }

        if (provider.availableMonths.isEmpty) {
          return _buildEmptyCard(theme, isDark);
        }

        return Container(
          margin: const EdgeInsets.all(16),
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
              _buildHeader(theme, isDark),
              const SizedBox(height: 16),
              _buildMonthSelection(provider, theme, isDark),
              if (provider.selectedMonths.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCostSummary(provider, theme, isDark),
                if (provider.hasLateFees()) ...[
                  const SizedBox(height: 12),
                  _buildLateFeeWarning(theme, isDark),
                ],
                const SizedBox(height: 16),
                _buildTotalCost(provider, theme, isDark),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryBlue,
            strokeWidth: 2,
          ),
          const SizedBox(height: 12),
          Text(
            'Loading available months...',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          Icon(
            Icons.calendar_month,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Please select a start date to view available payment months',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          color: AppColors.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Select Payment Months',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelection(BookingProvider provider, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Months',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.availableMonths.map((month) => _buildMonthCheckbox(month, provider, theme, isDark)),
      ],
    );
  }

  Widget _buildMonthCheckbox(MonthSelection month, BookingProvider provider, ThemeData theme, bool isDark) {
    final monthName = _getMonthName(month.monthYear.month);
    final year = month.monthYear.year;
    final hasLateFee = month.lateFee > 0;
    final conditionColor = provider.getConditionColor(month.condition);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: month.isSelected
            ? conditionColor.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: month.isSelected
              ? conditionColor.withValues(alpha: 0.3)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          width: month.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => provider.toggleMonthSelection(month, !month.isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Checkbox(
              value: month.isSelected,
              onChanged: (selected) => provider.toggleMonthSelection(month, selected),
              activeColor: conditionColor,
              checkColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$monthName $year',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildConditionBadge(month.condition, provider),
                      if (month.isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    month.description,
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (hasLateFee) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Late fee: ₹${month.lateFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${month.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: hasLateFee ? Colors.red : AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (month.baseAmount != month.amount) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Base: ₹${month.baseAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionBadge(String condition, BookingProvider provider) {
    final badgeText = provider.getConditionBadgeText(condition);
    final badgeColor = provider.getConditionColor(condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCostSummary(BookingProvider provider, ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildCostRow(
          'Rent Amount',
          '₹${provider.totalSelectedAmount.toStringAsFixed(0)}',
          theme,
          isDark,
        ),
        if (provider.hasLateFees())
          _buildCostRow(
            'Late Fees',
            '₹${provider.getTotalLateFees().toStringAsFixed(0)}',
            theme,
            isDark,
            isError: true,
          ),
        _buildCostRow(
          'Security Deposit',
          '₹${provider.securityDeposit.toStringAsFixed(0)}',
          theme,
          isDark,
        ),
        const Divider(height: 20),
      ],
    );
  }

  Widget _buildCostRow(String label, String amount, ThemeData theme, bool isDark, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isError
                  ? Colors.red
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateFeeWarning(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Late fees apply (0.8% daily after 3rd of month)',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCost(BookingProvider provider, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Upfront Cost',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.selectedMonths.length} month(s) selected',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹',
                  style: TextStyle(
                    color: const Color(0xFF00E676),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: provider.totalUpfrontCost.toStringAsFixed(0),
                  style: TextStyle(
                    color: const Color(0xFF00E676),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month];
  }
}