import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/damage_history_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/empty_state.dart';
import 'damage_detection_screen.dart';
import '../services/auth_service.dart';
import '../models/damage_detection.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _TimelineView(),
    const DamageDetectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Detect',
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damage Detection History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = AuthService();
              await auth.logout();
            },
          ),
        ],
      ),
      body: Consumer<DamageHistoryProvider>(
        builder: (context, historyProvider, child) {
          if (!historyProvider.hasDetections) {
            return EmptyState(
              icon: Icons.timeline,
              title: 'No Detections Yet',
              message:
                  'Start detecting vehicle damages to build your detection history.',
              actionText: 'Detect Damage',
              onActionPressed: () {
                // Navigate to damage detection (switch tab)
                final scaffoldState = context.findAncestorStateOfType<_DashboardScreenState>();
                scaffoldState?.setState(() {
                  scaffoldState._selectedIndex = 1;
                });
              },
            );
          }

          final detections = historyProvider.detections;

          return Column(
            children: [
              // Summary Cards
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.assignment_outlined,
                        title: 'Total Detections',
                        value: historyProvider.detectionCount.toString(),
                        color: AppColors.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Total Damages',
                        value: historyProvider.totalDamagesDetected.toString(),
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: detections.length,
                  itemBuilder: (context, index) {
                    return _DetectionCard(
                      detection: detections[index],
                      isFirst: index == 0,
                      isLast: index == detections.length - 1,
                      onDelete: () {
                        historyProvider.deleteDetection(detections[index].id);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DetectionCard extends StatelessWidget {
  final DamageDetection detection;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;

  const _DetectionCard({
    required this.detection,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: isLast ? 16 : 12,
        top: isFirst ? 0 : 0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with timestamp and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatTimestamp(detection.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image preview (if available)
            if (detection.imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  detection.imageFile!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Damages list
            Text(
              'Detected Damages (${detection.damageCount})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...detection.damages.map((damageMap) {
              final type = damageMap['type'] as String? ?? 'Unknown';
              final confidence = (damageMap['confidence'] as num?)?.toDouble() ?? 0.0;
              final severity = damageMap['severity'] as String? ?? 'Unknown';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: _getSeverityColor(severity),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$type - ${(confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      severity,
                      style: TextStyle(
                        color: _getSeverityColor(severity),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
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
