import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/damage_provider.dart';
import '../providers/insurance_provider.dart';
import '../providers/health_records_provider.dart';
import '../services/image_picker_service.dart';
import '../services/file_picker_service.dart';
import '../services/api_service.dart';
import '../models/damage.dart';
import '../models/insurance.dart';
import '../models/bill.dart';
import '../theme/app_colors.dart';
import '../widgets/common/custom_button.dart';

class ClaimSummaryScreen extends StatefulWidget {
  const ClaimSummaryScreen({super.key});

  @override
  State<ClaimSummaryScreen> createState() => _ClaimSummaryScreenState();
}

class _ClaimSummaryScreenState extends State<ClaimSummaryScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FilePickerService _filePickerService = FilePickerService();
  final ApiService _apiService = ApiService();

  File? _vehicleImage;
  File? _insuranceDoc;
  List<Damage>? _damages;
  Insurance? _policy;
  Bill? _bill;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Claim'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Documents',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Vehicle Image
                    ListTile(
                      leading: Icon(
                        _vehicleImage != null ? Icons.check_circle : Icons.image,
                        color: _vehicleImage != null ? AppColors.success : AppColors.textTertiary,
                      ),
                      title: const Text('Vehicle Image'),
                      subtitle: Text(_vehicleImage != null ? 'Selected' : 'Not selected'),
                      trailing: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: _pickVehicleImage,
                      ),
                    ),
                    
                    // Insurance Document
                    ListTile(
                      leading: Icon(
                        _insuranceDoc != null ? Icons.check_circle : Icons.description,
                        color: _insuranceDoc != null ? AppColors.success : AppColors.textTertiary,
                      ),
                      title: const Text('Insurance Document'),
                      subtitle: Text(_insuranceDoc != null ? 'Selected' : 'Not selected'),
                      trailing: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: _pickInsuranceDoc,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Submit Button
            if (_vehicleImage != null && _insuranceDoc != null && _bill == null)
              CustomButton(
                text: 'Process Claim',
                icon: Icons.send,
                isLoading: _isLoading,
                onPressed: _submitClaim,
              ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
            ],

            // Results
            if (_damages != null && _policy != null && _bill != null) ...[
              const SizedBox(height: 24),
              _buildClaimResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClaimResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Claim Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Damages Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Detected Damages',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._damages!.map((damage) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.electricBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${damage.type} (${damage.severity})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Insurance Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, color: AppColors.neonGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Insurance Policy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow('Provider', _policy!.provider),
                _infoRow('Policy No.', _policy!.policyNumber),
                _infoRow('Coverage', '₹${NumberFormat('#,##,###').format(_policy!.coverage)}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bill Section
        Card(
          color: AppColors.surfaceLightColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.electricBlue),
                    const SizedBox(width: 8),
                    Text(
                      'Bill Breakdown',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _billRow('Parts Cost', _bill!.partsCost),
                const SizedBox(height: 8),
                _billRow('Labor Cost', _bill!.laborCost),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _billRow('Total Cost', _bill!.totalCost, isTotal: true),
                const SizedBox(height: 8),
                _billRow(
                  'Insurance Covered',
                  _bill!.insuranceCovered,
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _billRow(
                  'You Pay',
                  _bill!.userPayable,
                  color: AppColors.warningOrange,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        CustomButton(
          text: 'Save to Timeline',
          icon: Icons.save,
          onPressed: _saveToTimeline,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _billRow(String label, double value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: (isTotal
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.bodyMedium)!
              .copyWith(color: color ?? AppColors.textPrimary),
        ),
      ],
    );
  }

  Future<void> _pickVehicleImage() async {
    final image = await _imagePickerService.pickFromGallery();
    if (image != null) {
      setState(() {
        _vehicleImage = image;
      });
    }
  }

  Future<void> _pickInsuranceDoc() async {
    final doc = await _filePickerService.pickPdfFile();
    if (doc != null) {
      setState(() {
        _insuranceDoc = doc;
      });
    }
  }

  Future<void> _submitClaim() async {
    if (_vehicleImage == null || _insuranceDoc == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.submitClaim(_vehicleImage!, _insuranceDoc!);

      setState(() {
        _damages = result['damages'] as List<Damage>;
        _policy = result['policy'] as Insurance;
        _bill = result['bill'] as Bill;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _saveToTimeline() {
    if (_damages != null && _bill != null) {
      final recordsProvider = context.read<HealthRecordsProvider>();

      for (final damage in _damages!) {
        recordsProvider.addClaim(
          damage,
          _bill!.userPayable,
          imagePath: _vehicleImage?.path,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim saved to timeline'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }
}
