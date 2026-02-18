import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/damage_provider.dart';
import '../providers/damage_history_provider.dart';
import '../services/image_picker_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/detection/bounding_box_painter.dart';

class DamageDetectionScreen extends StatefulWidget {
  const DamageDetectionScreen({super.key});

  @override
  State<DamageDetectionScreen> createState() => _DamageDetectionScreenState();
}

class _DamageDetectionScreenState extends State<DamageDetectionScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DamageProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Damage Detection'),
          actions: [
            Consumer<DamageProvider>(
              builder: (context, provider, _) {
                if (provider.selectedImage != null) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      provider.reset();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<DamageProvider>(
          builder: (context, damageProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Selection / Preview
                  if (damageProvider.selectedImage == null) ...[
                    _buildImageSelectionCard(context),
                  ] else ...[
                    if (damageProvider.hasDamages)
                      _buildImageWithBoundingBoxes(context, damageProvider)
                    else
                      _buildImagePreview(context, damageProvider.selectedImage!),
                    const SizedBox(height: 16),
                    
                    // Detect Button
                    if (!damageProvider.isLoading && !damageProvider.hasDamages)
                      CustomButton(
                        text: 'Detect Damage',
                        icon: Icons.search,
                        onPressed: () => _detectDamage(context),
                      ),
                  ],

                  // Loading State
                  if (damageProvider.isLoading) ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing image...'),
                        ],
                      ),
                    ),
                  ],

                  // Error State
                  if (damageProvider.error != null) ...[
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
                              damageProvider.error!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Results
                  if (damageProvider.hasDamages) ...[
                    const SizedBox(height: 24),
                    _buildDamageResults(context, damageProvider),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSelectionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: AppColors.electricBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Vehicle Image',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo of the damaged area or select from gallery',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Camera',
                    icon: Icons.camera_alt,
                    onPressed: () => _pickFromCamera(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Gallery',
                    icon: Icons.photo_library,
                    onPressed: () => _pickFromGallery(context),
                    backgroundColor: AppColors.softPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, File image) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.file(
              image,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<DamageProvider>().reset();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithBoundingBoxes(BuildContext context, DamageProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BoundingBoxImage(
          imageFile: provider.selectedImage!,
          damages: provider.detectedDamages,
          imageWidth: provider.imageWidth,
          imageHeight: provider.imageHeight,
        ),
      ),
    );
  }

  Widget _buildDamageResults(BuildContext context, DamageProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Detected Damages (${provider.detectedDamages.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...provider.detectedDamages.map((damageMap) {
          final type = damageMap['type'] as String? ?? 'Unknown';
          final severity = damageMap['severity'] as String? ?? 'Unknown';
          final confidence = (damageMap['confidence'] as num?)?.toDouble() ?? 0.0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: _getSeverityColor(severity),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Severity: $severity',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: _getSeverityColor(severity),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: AppColors.surfaceLightColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Save to Timeline',
          icon: Icons.save,
          onPressed: () => _saveToTimeline(context, provider),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('critical')) return AppColors.severityCritical;
    if (lower.contains('severe')) return AppColors.severitySevere;
    if (lower.contains('moderate')) return AppColors.severityModerate;
    return AppColors.severityMinor;
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final image = await _imagePickerService.pickFromCamera();
      if (image != null && mounted) {
        context.read<DamageProvider>().setSelectedImage(image);
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final image = await _imagePickerService.pickFromGallery();
      if (image != null && mounted) {
        context.read<DamageProvider>().setSelectedImage(image);
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _detectDamage(BuildContext context) async {
    await context.read<DamageProvider>().detectDamage();
  }

  Future<void> _saveToTimeline(BuildContext context, DamageProvider provider) async {
    if (provider.detectedDamages.isNotEmpty) {
      final historyProvider = context.read<DamageHistoryProvider>();
      
      print('🔍 Attempting to save detection...');
      print('   Damages count: ${provider.detectedDamages.length}');
      print('   Image path: ${provider.selectedImage?.path}');
      print('   Image dimensions: ${provider.imageWidth} x ${provider.imageHeight}');
      
      try {
        await historyProvider.saveDetection(
          damages: provider.detectedDamages,
          imagePath: provider.selectedImage?.path,
          imageWidth: provider.imageWidth,
          imageHeight: provider.imageHeight,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detection saved to timeline'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }

        provider.reset();
      } catch (e) {
        print('❌ Save failed: $e');
        if (mounted) {
          _showError(context, 'Failed to save: ${e.toString()}');
        }
      }
    }
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
