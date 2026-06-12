
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/services/api_service.dart';
import '../core/services/history_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/history_tile.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _analyzing = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      _analyze(picked);
    } catch (e) {
      _showError('تعذر الوصول للكاميرا/المعرض: $e');
    }
  }

  Future<void> _analyze(XFile imageFile) async {
    setState(() => _analyzing = true);

    try {
      final result = await ApiService.predict(imageFile);
      
      // Save locally only if online
      if (await ApiService.isOnline()) {
        await HistoryService.saveScan(result, imageFile.path);
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imageFile: imageFile,
          ),
        ),
      );
      setState(() => _analyzing = false);
    } catch (e) {
      if (mounted) {
        setState(() => _analyzing = false);
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _analyzeAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    _analyze(XFile(tempFile.path));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.leaf_arrow_circlepath, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 8),
            Text('LeafSense', style: AppTextStyles.appBarTitle.copyWith(color: AppColors.textDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.time, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pushNamed('/history'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Green Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طبيب النباتات',
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'صوّر ورقة.\nاحصل على التشخيص.',
                        style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'وجّه الكاميرا نحو أي نبات سليم أو مريض ودع الذكاء الاصطناعي يكتشف المشكلة والحل في ثوانٍ.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(CupertinoIcons.camera, color: AppColors.primary),
                        label: Text('التقط صورة', style: AppTextStyles.buttonText.copyWith(color: AppColors.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(CupertinoIcons.photo, color: Colors.white),
                        label: const Text('اختر من المعرض'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildDemoSection(),
                const SizedBox(height: 32),

                // Tips Section
                Text('نصائح للحصول على أفضل نتيجة', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 16),
                _buildTipCard(CupertinoIcons.sun_max, 'استخدم إضاءة جيدة', 'ضوء النهار الطبيعي يعطي تحليلاً أكثر دقة.'),
                _buildTipCard(CupertinoIcons.crop, 'ركّز على الورقة', 'اقترب من المنطقة المصابة للحصول على تفاصيل أوضح.'),
                _buildTipCard(CupertinoIcons.photo, 'تجنّب الاهتزاز', 'ثبّت الهاتف وانقر للتركيز قبل التصوير.'),
                
                const SizedBox(height: 32),

                // Recent Scans Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الفحوصات الأخيرة', style: AppTextStyles.headlineMedium),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/history'),
                      child: Text('عرض الكل', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecentScans(),
              ],
            ),
          ),
          if (_analyzing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTipCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: HistoryService.getHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل الفحوصات'));
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('لا توجد فحوصات سابقة', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
          );
        }

        return Column(
          children: docs.map((doc) => HistoryTile(doc: doc)).toList(),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text('جاري التحليل...', style: AppTextStyles.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoSection() {
    final demos = [
      {'label': 'طماطم سليمة',    'asset': 'assets/demo/tomato_healthy.jpg'},
      {'label': 'لفحة المتأخرة',   'asset': 'assets/demo/tomato_late_blight.jpg'},
      {'label': 'جرب التفاح',      'asset': 'assets/demo/apple_scab.jpg'},
      {'label': 'بقعة البطاطس',    'asset': 'assets/demo/potato_early_blight.jpg'},
      {'label': 'عفن العنب',       'asset': 'assets/demo/grape_black_rot.jpg'},
      {'label': 'صدأ الذرة',       'asset': 'assets/demo/corn_rust.jpg'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('جرّب صوراً نموذجية', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: demos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => _analyzeAsset(demos[i]['asset']!),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(demos[i]['asset']!, width: 64, height: 64, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 6),
                    Text(demos[i]['label']!, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
