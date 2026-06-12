import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class HistoryTile extends StatelessWidget {
  final Map<String, dynamic> doc;

  const HistoryTile({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc;
    final plant = data['plant'] as String? ?? 'نبات';
    final disease = data['disease'] as String? ?? 'غير معروف';
    final isHealthy = data['isHealthy'] as bool? ?? false;
    final imagePath = data['imagePath'] as String?;
    final confidence = data['confidence'] as num? ?? 0.0;
    
    final pct = (confidence * 100).round();
    
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

    // Mock time for display (e.g. "الآن" or formatted date)
    final timeStr = 'الآن';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.chevron_left, color: AppColors.textMuted, size: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(disease, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(plant, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(timeStr, style: AppTextStyles.labelSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(severityLabel, style: AppTextStyles.labelSmall.copyWith(color: severityColor)),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (kIsWeb || (imagePath != null && File(imagePath).existsSync()))
                ? SizedBox(
                    width: 70,
                    height: 70,
                    child: kIsWeb
                        ? Image.network(imagePath!, fit: BoxFit.cover)
                        : Image.file(File(imagePath!), fit: BoxFit.cover),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: AppColors.divider,
                    child: const Icon(CupertinoIcons.photo, color: AppColors.textMuted),
                  ),
          ),
        ],
      ),
    );
  }
}
