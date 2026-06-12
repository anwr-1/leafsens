import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/pb_service.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حسابي', style: AppTextStyles.appBarTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Icon(CupertinoIcons.person_solid, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              (PbService.pb.authStore.record?.getStringValue('name') ?? '').isNotEmpty
                  ? PbService.pb.authStore.record!.getStringValue('name')
                  : 'مستخدم LeafSense',
              style: AppTextStyles.headlineMedium,
            ),
            Text(
              PbService.pb.authStore.record?.getStringValue('email') ?? 'غير متوفر',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            _buildListTile(CupertinoIcons.settings, 'الإعدادات'),
            _buildListTile(CupertinoIcons.bell, 'الإشعارات'),
            _buildListTile(CupertinoIcons.question_circle, 'المساعدة والدعم'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  PbService.pb.authStore.clear();
                  Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
                },
                child: Text('تسجيل الخروج', style: AppTextStyles.buttonText.copyWith(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.labelLarge),
        trailing: const Icon(CupertinoIcons.chevron_left, color: AppColors.textMuted, size: 20),
        onTap: () {},
      ),
    );
  }
}
