import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/providers/expense_provider.dart';
import 'package:expense_tracker_app/core/constants/colors.dart';
import 'package:expense_tracker_app/data/models/expense_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses.where((e) => e.type == 'expense').toList();
    final totalExpense = expenseProvider.totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              context,
              title: 'Category Distribution',
              child: SizedBox(
                height: 300,
                child: expenses.isEmpty
                    ? const Center(child: Text('No spending data yet'))
                    : Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: _getPieSections(expenses, totalExpense),
                                centerSpaceRadius: 45,
                                sectionsSpace: 4,
                                pieTouchData: PieTouchData(
                                  enabled: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: _buildLegend(expenses, totalExpense),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              context,
              title: 'Weekly Spending Trend',
              child: Container(
                height: 220,
                padding: const EdgeInsets.only(right: 20, top: 20, left: 0, bottom: 0),
                child: expenses.isEmpty
                    ? const Center(child: Text('Add expenses to see trends'))
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (spot) => AppColors.primary.withValues(alpha: 0.8),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  return LineTooltipItem(
                                    '\$${spot.y.toStringAsFixed(2)}',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('E').format(date),
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getLineSpots(expenses),
                              isCurved: false,
                              color: AppColors.primary,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                  radius: 5,
                                  color: Theme.of(context).cardColor,
                                  strokeWidth: 3,
                                  strokeColor: AppColors.primary,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.2),
                                    AppColors.primary.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 120), 
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLegend(List<Expense> expenses, double total) {
    Map<String, double> categories = {};
    for (var e in expenses) {
      categories[e.category] = (categories[e.category] ?? 0) + e.amount;
    }

    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sorted.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: _getCategoryColor(entry.key), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key} ($percentage%)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _getPieSections(List<Expense> expenses, double total) {
    Map<String, double> categories = {};
    for (var e in expenses) {
      categories[e.category] = (categories[e.category] ?? 0) + e.amount;
    }

    return categories.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 55,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return AppColors.primary;
      case 'transport': return AppColors.secondary;
      case 'shopping': return AppColors.accent;
      case 'entertainment': return Colors.purple;
      case 'health': return AppColors.expense;
      default: return Colors.blueGrey;
    }
  }

  List<FlSpot> _getLineSpots(List<Expense> expenses) {
    Map<int, double> dailySpending = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var e in expenses) {
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      final diff = today.difference(expenseDate).inDays;
      
      if (diff >= 0 && diff < 7) {
        final xValue = 6 - diff;
        dailySpending[xValue] = (dailySpending[xValue] ?? 0) + e.amount;
      }
    }

    return List.generate(7, (i) {
      return FlSpot(i.toDouble(), dailySpending[i] ?? 0);
    });
  }
}
