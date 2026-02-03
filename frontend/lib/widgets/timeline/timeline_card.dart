import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/health_record.dart';
import '../../theme/app_colors.dart';
import 'status_indicator.dart';

class TimelineCard extends StatelessWidget {
  final HealthRecord record;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.record,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.glassStroke,
                  ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getTypeColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getTypeColor().withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.glassStroke,
                    ),
                  ),
              ],
            ),
          ),
          
          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              record.description ?? 'Vehicle Health Event',
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusIndicator(status: record.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(record.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('hh:mm a').format(record.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (record.damage != null) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: _getSeverityColor(record.damage!.severity),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.damage!.type,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Severity: ${record.damage!.severity}',
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: _getSeverityColor(record.damage!.severity),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (record.cost != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cost',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '₹${record.cost!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: AppColors.warningOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (record.type.toLowerCase()) {
      case 'damage':
        return AppColors.statusDetected;
      case 'repair':
        return AppColors.statusRepaired;
      case 'claim':
        return AppColors.statusClaimed;
      default:
        return AppColors.electricBlue;
    }
  }

  Color _getSeverityColor(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('critical')) return AppColors.severityCritical;
    if (lower.contains('severe')) return AppColors.severitySevere;
    if (lower.contains('moderate')) return AppColors.severityModerate;
    return AppColors.severityMinor;
  }
}
