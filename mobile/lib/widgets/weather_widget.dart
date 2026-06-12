
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _loading = true;
  String? _error;
  double? _temp;
  double? _wind;
  int? _humidity;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Coordinates for Cairo, Egypt
      const double lat = 30.0444;
      const double lon = 31.2357;
      
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,wind_speed_10m,relative_humidity_2m';
      
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final current = response.data['current'];
        if (mounted) {
          setState(() {
            _temp = (current['temperature_2m'] as num).toDouble();
            _wind = (current['wind_speed_10m'] as num).toDouble();
            _humidity = (current['relative_humidity_2m'] as num).toInt();
            _loading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch weather');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذر جلب الطقس';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, color: AppColors.danger),
            const SizedBox(width: 12),
            Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeatherItem(CupertinoIcons.thermometer, '$_temp°', 'الحرارة', AppColors.warning),
          Container(height: 40, width: 1, color: AppColors.divider),
          _buildWeatherItem(CupertinoIcons.drop, '$_humidity%', 'الرطوبة', AppColors.primary),
          Container(height: 40, width: 1, color: AppColors.divider),
          _buildWeatherItem(CupertinoIcons.wind, '$_wind كم/س', 'الرياح', Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.headlineMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
