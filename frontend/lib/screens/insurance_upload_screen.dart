import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/insurance_provider.dart';
import '../services/file_picker_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/skeleton_loader.dart';

class InsuranceUploadScreen extends StatefulWidget {
  const InsuranceUploadScreen({super.key});

  @override
  State<InsuranceUploadScreen> createState() => _InsuranceUploadScreenState();
}

class _InsuranceUploadScreenState extends State<InsuranceUploadScreen> {
  final FilePickerService _filePickerService = FilePickerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InsuranceProvider>().reset();
            },
          ),
        ],
      ),
      body: Consumer<InsuranceProvider>(
        builder: (context, insuranceProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PDF Selection
                if (insuranceProvider.selectedPdf == null) ...[
                  _buildPdfSelectionCard(context),
                ] else ...[
                  _buildPdfPreview(context, insuranceProvider.selectedPdf!),
                  const SizedBox(height: 16),

                  // Process Button
                  if (!insuranceProvider.isLoading && !insuranceProvider.hasInsurance)
                    CustomButton(
                      text: 'Process Document',
                      icon: Icons.auto_fix_high,
                      onPressed: () => _processInsurance(context),
                    ),
                ],

                // Loading State with Skeleton
                if (insuranceProvider.isLoading) ...[
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      const Text('Processing insurance document...'),
                      const SizedBox(height: 16),
                      const SkeletonCard(),
                      const SizedBox(height: 12),
                      const SkeletonCard(),
                    ],
                  ),
                ],

                // Error State
                if (insuranceProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            insuranceProvider.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Results
                if (insuranceProvider.hasInsurance) ...[
                  const SizedBox(height: 24),
                  _buildInsuranceResults(context, insuranceProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfSelectionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: AppColors.warningOrange.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Insurance Document',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select your insurance policy PDF for automated processing',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Select PDF File',
              icon: Icons.upload_file,
              onPressed: () => _pickPdfFile(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview(BuildContext context, File pdf) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: AppColors.warningOrange,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected PDF',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    pdf.path.split('/').last,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<InsuranceProvider>().reset();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceResults(BuildContext context, InsuranceProvider provider) {
    final insurance = provider.insuranceInfo!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Insurance Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Provider Card
        _InfoCard(
          icon: Icons.business,
          title: 'Insurance Provider',
          value: insurance.provider,
          color: AppColors.electricBlue,
        ),
        const SizedBox(height: 12),

        // Policy Number Card
        _InfoCard(
          icon: Icons.confirmation_number,
          title: 'Policy Number',
          value: insurance.policyNumber,
          color: AppColors.softPurple,
        ),
        const SizedBox(height: 12),

        // Coverage Card
        _InfoCard(
          icon: Icons.shield,
          title: 'Coverage Amount',
          value: '₹${NumberFormat('#,##,###').format(insurance.coverage)}',
          color: AppColors.neonGreen,
        ),
        const SizedBox(height: 12),

        // Expiry Card
        _InfoCard(
          icon: Icons.calendar_today,
          title: 'Expiry Date',
          value: DateFormat('MMM dd, yyyy').format(insurance.expiryDate),
          subtitle: insurance.isExpired
              ? 'Expired'
              : '${insurance.daysUntilExpiry} days remaining',
          color: insurance.isExpired ? AppColors.error : AppColors.warningOrange,
        ),
        const SizedBox(height: 12),

        // Claim Limit Card
        _InfoCard(
          icon: Icons.account_balance_wallet,
          title: 'Claim Limit',
          value: '₹${NumberFormat('#,##,###').format(insurance.claimLimit)}',
          color: AppColors.electricBlue,
        ),

        const SizedBox(height: 24),
        const Text(
          'Insurance details saved and ready to use for claims',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.success),
        ),
      ],
    );
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      final pdf = await _filePickerService.pickPdfFile();
      if (pdf != null && mounted) {
        context.read<InsuranceProvider>().setSelectedPdf(pdf);
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _processInsurance(BuildContext context) async {
    await context.read<InsuranceProvider>().processInsurance();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
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
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: color,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
