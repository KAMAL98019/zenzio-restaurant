import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/analytics.dart'; // Add this import
import '../../viewmodels/analytics_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalyticsViewModel>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Sales & Analytics'),
      body: Consumer<AnalyticsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.analytics == null) {
            return const Center(child: Text('No data available'));
          }

          final analytics = viewModel.analytics!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: viewModel.selectedPeriod,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                      isExpanded: true,
                      items: viewModel.periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period, style: AppTextStyles.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          viewModel.changePeriod(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Sales',
                        value: '₹${analytics.totalSales.toStringAsFixed(0)}',
                        change: analytics.salesGrowth,
                        isPositive: analytics.salesGrowth > 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Orders',
                        value: '${analytics.totalOrders}',
                        change: analytics.ordersGrowth,
                        isPositive: analytics.ordersGrowth > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Average Order',
                        value: '₹${analytics.averageOrder.toStringAsFixed(2)}',
                        change: analytics.averageOrderGrowth,
                        isPositive: analytics.averageOrderGrowth > 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Bookings',
                        value: '${analytics.totalBookings}',
                        change: analytics.bookingsGrowth,
                        isPositive: analytics.bookingsGrowth > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Sales Trend Chart
                Text('Sales Trend', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _SalesTrendChart(data: analytics.salesTrend),
                const SizedBox(height: 32),

                // Popular Dishes
                Text('Popular Dishes', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _PopularDishesChart(dishes: analytics.popularDishes),
                const SizedBox(height: 32),

                // Order Breakdown
                Text('Order Breakdown', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _OrderBreakdownChart(breakdown: analytics.orderBreakdown),
                const SizedBox(height: 24),

                // Download Report Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download, color: AppColors.primary),
                    label: const Text(
                      'Download Sales Report',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double change;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sales Trend Chart Widget
class _SalesTrendChart extends StatelessWidget {
  final List<SalesTrendData> data;

  const _SalesTrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 900,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.border, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data[value.toInt()].day,
                        style: AppTextStyles.caption,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 900,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${(value ~/ 1000)}k', // Changed $ to ₹
                    style: AppTextStyles.caption,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: data.length - 1.0,
          minY: 0,
          maxY: 3600,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// Popular Dishes Chart Widget
class _PopularDishesChart extends StatelessWidget {
  final List<PopularDish> dishes;

  const _PopularDishesChart({required this.dishes});

  @override
  Widget build(BuildContext context) {
    // Fixed: Removed nullable operator
    final maxRevenue = dishes
        .map((d) => d.revenue)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: dishes.map((dish) {
          // Fixed: Removed nullable operator
          final percentage = (dish.revenue / maxRevenue * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Order Breakdown Pie Chart Widget
class _OrderBreakdownChart extends StatelessWidget {
  final OrderBreakdown breakdown;

  const _OrderBreakdownChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: [
                  PieChartSectionData(
                    color: AppColors.primary,
                    value: breakdown.delivery.toDouble(),
                    title: '',
                    radius: 100,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF64B5F6),
                    value: breakdown.pickup.toDouble(),
                    title: '',
                    radius: 100,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFDD835),
                    value: breakdown.dineIn.toDouble(),
                    title: '',
                    radius: 100,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                color: AppColors.primary,
                label: 'Delivery',
                value: '${breakdown.delivery}%',
              ),
              _LegendItem(
                color: const Color(0xFF64B5F6),
                label: 'Pickup',
                value: '${breakdown.pickup}%',
              ),
              _LegendItem(
                color: const Color(0xFFFDD835),
                label: 'Dine-in',
                value: '${breakdown.dineIn}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
