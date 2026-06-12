import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الطقس', style: AppTextStyles.appBarTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'بنها',
              textAlign: TextAlign.end,
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
            const SizedBox(height: 10),
            
            // Main Weather Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.weatherGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(CupertinoIcons.cloud, color: Colors.white, size: 80),
                  const SizedBox(height: 10),
                  Text(
                    '29°',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 80,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'صافِ غالباً',
                    style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'الإحساس 26°',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Metrics Row
            Row(
              children: [
                _buildMetricCard(CupertinoIcons.drop, 'الرطوبة', '22%'),
                const SizedBox(width: 12),
                _buildMetricCard(CupertinoIcons.wind, 'الرياح', '7 كم/س'),
                const SizedBox(width: 12),
                _buildMetricCard(CupertinoIcons.sun_max, 'الأشعة', '0'),
              ],
            ),
            const SizedBox(height: 24),

            // Plant Tip Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                border: Border.all(color: AppColors.primaryLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.leaf_arrow_circlepath, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نصيحة لنباتاتك', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          'الجو مناسب لرعاية نباتاتك. هذا وقت ممتاز للري والتقليم الخفيف.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Forecast
            Text('توقعات الأيام القادمة', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildForecastRow('اليوم', '34°', '15°', CupertinoIcons.cloud_sun, '3%'),
                  const Divider(height: 1),
                  _buildForecastRow('الأحد', '27°', '16°', CupertinoIcons.cloud, ''),
                  const Divider(height: 1),
                  _buildForecastRow('الإثنين', '27°', '16°', CupertinoIcons.cloud, ''),
                  const Divider(height: 1),
                  _buildForecastRow('الثلاثاء', '30°', '15°', CupertinoIcons.cloud, ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(String day, String high, String low, IconData icon, String chance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(day, style: AppTextStyles.labelLarge)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                if (chance.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(chance, style: TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(low, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                const SizedBox(width: 16),
                Text(high, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
