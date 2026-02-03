import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/health_records_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/empty_state.dart';

class CostTrendsScreen extends StatelessWidget {
  const CostTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Trends & Insights'),
      ),
      body: Consumer<HealthRecordsProvider>(
        builder: (context, recordsProvider, child) {
          if (!recordsProvider.hasRecords) {
            return const EmptyState(
              icon: Icons.analytics,
              title: 'No Data Available',
              message: 'Start detecting damages and submitting claims to see cost trends and insights.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Insight Cards
                _buildInsightCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Cost Trend',
                  value: _getTrendText(recordsProvider.costTrendPercentage),
                  color: recordsProvider.costTrendPercentage >= 0
                      ? AppColors.warningOrange
                      : AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildInsightCard(
                  context,
                  icon: Icons.warning,
                  title: 'Most Frequent Damage',
                  value: recordsProvider.mostFrequentDamage,
                  color: AppColors.electricBlue,
                ),
                const SizedBox(height: 24),

                // Cost Trend Chart
                Text(
                  'Repair Cost Over Time',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildCostTrendChart(recordsProvider),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Damage Frequency Chart
                Text(
                  'Damage Frequency',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDamageFrequencyChart(recordsProvider),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendText(double percentage) {
    if (percentage == 0) return 'No change';
    final sign = percentage >= 0 ? '+' : '';
    return '${sign}${percentage.toStringAsFixed(1)}% this year';
  }

  Widget _buildCostTrendChart(HealthRecordsProvider provider) {
    final data = provider.monthlyCostData;
    
    if (data.isEmpty) {
      return const Center(child: Text('No cost data available'));
    }

    final spots = <FlSpot>[];
    var index = 0.0;
    data.forEach((month, cost) {
      spots.add(FlSpot(index, cost));
      index++;
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.glassStroke,
              strokeWidth: 1,
            );
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
              getTitlesWidget: (double value, TitleMeta meta) {
                final months = data.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  final month = months[value.toInt()].split('/')[0];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      month,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
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
              interval: 2000,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: data.values.reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: AppColors.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.electricBlue,
                  strokeWidth: 2,
                  strokeColor: AppColors.darkBackground,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlue.withOpacity(0.3),
                  AppColors.electricBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageFrequencyChart(HealthRecordsProvider provider) {
    final frequency = provider.damageFrequency;

    if (frequency.isEmpty) {
      return const Center(child: Text('No damage data available'));
    }

    final barGroups = <BarChartGroupData>[];
    var index = 0;
    frequency.forEach((type, count) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              gradient: AppColors.successGradient,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: frequency.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final type = frequency.keys.toList()[groupIndex];
              return BarTooltipItem(
                '$type\n${rod.toY.toInt()}',
                const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
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
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                final types = frequency.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < types.length) {
                  final type = types[value.toInt()];
                  final shortType = type.length > 10 
                      ? '${type.substring(0, 10)}...' 
                      : type;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      shortType,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
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
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.glassStroke,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
