import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_records_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/timeline/timeline_card.dart';
import '../widgets/common/empty_state.dart';
import 'damage_detection_screen.dart';
import 'insurance_upload_screen.dart';
import 'claim_summary_screen.dart';
import 'cost_trends_screen.dart';

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
    const InsuranceUploadScreen(),
    const CostTrendsScreen(),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Insurance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Trends',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClaimSummaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_card),
              label: const Text('Submit Claim'),
            )
          : null,
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<HealthRecordsProvider>(
        builder: (context, recordsProvider, child) {
          if (!recordsProvider.hasRecords) {
            return EmptyState(
              icon: Icons.timeline,
              title: 'No Health Records',
              message:
                  'Start tracking your vehicle\'s health by detecting damages or submitting insurance claims.',
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

          final records = recordsProvider.sortedRecords;

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
                        title: 'Total Records',
                        value: recordsProvider.recordCount.toString(),
                        color: AppColors.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.currency_rupee,
                        title: 'Total Cost',
                        value: '₹${recordsProvider.totalCost.toStringAsFixed(0)}',
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
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return TimelineCard(
                      record: records[index],
                      isFirst: index == 0,
                      isLast: index == records.length - 1,
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Vehicle Health Tracker'),
        content: const Text(
          'Track your vehicle\'s damage history, insurance claims, and repair costs. '
          'Use AI-powered damage detection and automated insurance document processing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
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
