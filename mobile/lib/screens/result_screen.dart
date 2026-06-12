import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../models/prediction_result.dart';
import '../core/constants/treatments_data.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResult result;
  final XFile imageFile;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final treatmentInfo = getTreatment(result.rawClass)!;

    final isHealthy = result.isHealthy;
    final pct = (result.confidence * 100).round();
    
    // Determine severity badge
    String severityLabel = 'متوسط';
    Color severityColor = AppColors.warning;
    Color severityBg = AppColors.warningLight;

    if (isHealthy) {
      severityLabel = 'سليم';
      severityColor = AppColors.success;
      severityBg = AppColors.successLight;
    } else if (pct > 85) {
      severityLabel = 'شديد';
      severityColor = AppColors.danger;
      severityBg = AppColors.dangerLight;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image (Top Half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: kIsWeb
                ? Image.network(
                    imageFile.path,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imageFile.path),
                    fit: BoxFit.cover,
                  ),
          ),
          
          // Back Button & Action Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Main Result Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(result.disease, style: AppTextStyles.headlineLarge),
                                    const SizedBox(height: 4),
                                    Text(result.plant, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: severityBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(severityLabel, style: AppTextStyles.labelMedium.copyWith(color: severityColor)),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (pct < 60) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.exclamationmark_triangle, color: AppColors.danger, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'نتيجة غير مؤكدة - يرجى المحاولة بصورة أوضح.',
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text('$pct%', style: AppTextStyles.labelLarge),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: result.confidence,
                                      backgroundColor: AppColors.divider,
                                      color: severityColor,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('نسبة الثقة', style: AppTextStyles.labelMedium),
                                const SizedBox(width: 4),
                                const Icon(CupertinoIcons.chart_bar_alt_fill, color: AppColors.textMuted, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Symptoms Card
                      if (!isHealthy)
                        _buildInfoCard(
                          icon: CupertinoIcons.exclamationmark_circle,
                          iconColor: AppColors.warning,
                          iconBg: AppColors.warningLight,
                          title: 'الأعراض',
                          items: treatmentInfo['symptoms'] ?? [],
                        ),

                      const SizedBox(height: 16),

                      // Causes Card
                      if (!isHealthy)
                        _buildInfoCard(
                          icon: CupertinoIcons.search,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primaryLight.withValues(alpha: 0.1),
                          title: 'الأسباب المحتملة',
                          items: treatmentInfo['causes'] ?? [],
                        ),

                      const SizedBox(height: 16),

                      // Treatment Card
                      if (!isHealthy)
                        _buildInfoCard(
                          icon: CupertinoIcons.leaf_arrow_circlepath,
                          iconColor: AppColors.success,
                          iconBg: AppColors.successLight,
                          title: 'العلاج الموصى به',
                          items: treatmentInfo['treatment'] ?? [],
                        ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.headlineMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
