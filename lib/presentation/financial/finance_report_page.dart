import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../data/model/financial_data.dart';
import '../../data/model/transaction.dart';
import '../../l10n/app_localizations.dart';

class FinanceReportPage extends StatefulWidget {
  const FinanceReportPage({super.key});

  @override
  State<FinanceReportPage> createState() => _FinanceReportPageState();
}

class _FinanceReportPageState extends State<FinanceReportPage> {
  String _selectedPeriod = 'M'; // Default to Monthly

  // Sample financial data
  final Map<String, double> _financialData = {
    'income': 25000000,
    'expense': 18500000,
    'balance': 6500000,
  };

  // Sample recent transactions
  final List<Transaction> _recentTransactions = [
    Transaction(
      title: 'Donasi Jumat',
      amount: 5000000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isIncome: true,
      category: 'Donation',
    ),
    Transaction(
      title: 'Pembayaran Listrik',
      amount: 1500000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      isIncome: false,
      category: 'Utilities',
    ),
    Transaction(
      title: 'Renovasi Toilet',
      amount: 8000000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      isIncome: false,
      category: 'Maintenance',
    ),
    Transaction(
      title: 'Donasi Bulanan',
      amount: 10000000,
      date: DateTime.now().subtract(const Duration(days: 7)),
      isIncome: true,
      category: 'Donation',
    ),
    Transaction(
      title: 'Gaji Imam',
      amount: 4000000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      isIncome: false,
      category: 'Salary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.financeReport),
            backgroundColor: colorScheme.primary,
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to finance settings
                },
              ),
            ],
          ),
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinancialHeader(colorScheme, screenSize),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummarySection(colorScheme),
                      const SizedBox(height: 24),
                      _buildRecentTransactionsSection(colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     // Add new transaction
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Add transaction feature coming soon')),
          //     );
          //   },
          //   backgroundColor: colorScheme.secondary,
          //   child: const Icon(Icons.add),
          // ),
        );
      },
    );
  }

  Widget _buildFinancialHeader(ColorScheme colorScheme, Size screenSize) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      color: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Financial header with gradient
          Container(
            width: screenSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                  colorScheme.primary.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          AppLocalizations.of(context)!.currentBalance,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutQuart,
                        ),
                    const SizedBox(height: 8),
                    Text(
                          currencyFormat.format(_financialData['balance']),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 200.ms,
                          curve: Curves.easeOutQuart,
                        ),
                    const SizedBox(height: 24),
                    _buildFinancialSummary(colorScheme)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          delay: 400.ms,
                          curve: Curves.easeOutQuart,
                        ),
                  ],
                ),
              ),
            ),
          ),

          // Period selector
          Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Income_vs_Expense',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodButton(
                            AppLocalizations.of(context)!.weekly_short,
                            AppLocalizations.of(context)!.weekly,
                            colorScheme,
                          ),
                          _buildPeriodButton(
                            AppLocalizations.of(context)!.monthly_short,
                            AppLocalizations.of(context)!.monthly,
                            colorScheme,
                          ),
                          _buildPeriodButton(
                            AppLocalizations.of(context)!.yearly_short,
                            AppLocalizations.of(context)!.yearly,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 600.ms)
              .slideX(begin: 0.2, end: 0, duration: 800.ms, delay: 600.ms),

          // Chart placeholder

          // Container(
          //   width: double.infinity,
          //   height: 200,
          //   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(15),
          //     color: colorScheme.surface,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.05),
          //         blurRadius: 10,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.bar_chart,
          //           size: 60,
          //           color: colorScheme.primary.withValues(alpha: 0.7),
          //         ),
          //         const SizedBox(height: 16),
          //         Text(
          //           'Financial Chart',
          //           style: TextStyle(
          //             fontSize: 16,
          //             color: colorScheme.onSurface.withValues(alpha: 0.7),
          //           ),
          //         ),
          //         Text(
          //           'Visualization of income and expenses',
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: colorScheme.onSurface.withValues(alpha: 0.5),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // )
          // .animate()
          // .fadeIn(duration: 800.ms, delay: 800.ms)
          // .scale(
          //   begin: const Offset(0.9, 0.9),
          //   end: const Offset(1, 1),
          //   duration: 800.ms,
          //   delay: 800.ms,
          // ),
          Container(
                width: double.infinity,
                height: 250,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildFinancialChart(colorScheme),
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 800.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 800.ms,
                delay: 800.ms,
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFinancialChart(ColorScheme colorScheme) {
    // Sample data for the chart
    final List<FinancialData> chartData = [
      FinancialData('Jan', 15000000, 12000000),
      FinancialData('Feb', 18000000, 14000000),
      FinancialData('Mar', 20000000, 15000000),
      FinancialData('Apr', 17000000, 16000000),
      FinancialData('May', 22000000, 18000000),
      FinancialData('Jun', 25000000, 18500000),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(locale: 'id_ID'),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: TextStyle(color: colorScheme.onSurface),
      ),
      series: <CartesianSeries>[
        ColumnSeries<FinancialData, String>(
          name: AppLocalizations.of(context)!.income,
          dataSource: chartData,
          xValueMapper: (FinancialData data, _) => data.month,
          yValueMapper: (FinancialData data, _) => data.income,
          color: Colors.green.shade400,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          width: 0.4,
          spacing: 0.2,
        ),
        ColumnSeries<FinancialData, String>(
          name: AppLocalizations.of(context)!.expense,
          dataSource: chartData,
          xValueMapper: (FinancialData data, _) => data.month,
          yValueMapper: (FinancialData data, _) => data.expense,
          color: Colors.red.shade400,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          width: 0.4,
          spacing: 0.2,
        ),
      ],
    );
  }

  Widget _buildPeriodButton(
    String value,
    String tooltip,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedPeriod == value;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(ColorScheme colorScheme) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryItem(
          AppLocalizations.of(context)!.income,
          currencyFormat.format(_financialData['income']),
          Icons.arrow_upward,
          Colors.green,
          colorScheme,
        ),
        Container(
          height: 50,
          width: 1,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        _buildSummaryItem(
          AppLocalizations.of(context)!.expense,
          currencyFormat.format(_financialData['expense']),
          Icons.arrow_downward,
          Colors.red,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    String title,
    String amount,
    IconData icon,
    Color iconColor,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.summary,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                AppLocalizations.of(context)!.totalIncome,
                'Rp 25,000,000',
                Icons.arrow_circle_up,
                Colors.green,
                colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                AppLocalizations.of(context)!.totalExpense,
                'Rp 18,500,000',
                Icons.arrow_circle_down,
                Colors.red,
                colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color iconColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.recentTransaction,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all transactions
              },
              child: Text(
                AppLocalizations.of(context)!.see_all,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recentTransactions.isEmpty
            ? _buildEmptyTransactions(colorScheme)
            : Column(
              children:
                  _recentTransactions
                      .map(
                        (transaction) =>
                            _buildTransactionItem(transaction, colorScheme),
                      )
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildEmptyTransactions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_transactions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   'Add your first transaction by tapping the + button',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     color: colorScheme.onBackground.withValues(alpha: 0.6),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    ColorScheme colorScheme,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  transaction.isIncome
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: transaction.isIncome ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${transaction.isIncome ? "+" : "-"}${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'donation':
        return Icons.volunteer_activism;
      case 'utilities':
        return Icons.bolt;
      case 'maintenance':
        return Icons.build;
      case 'salary':
        return Icons.payments;
      case 'food':
        return Icons.restaurant;
      case 'education':
        return Icons.school;
      case 'charity':
        return Icons.favorite;
      default:
        return Icons.attach_money;
    }
  }
}
