import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

import 'home_screen.dart'; // Will become ScanTab
import 'history_screen.dart'; // Will become HistoryTab
import 'tabs/account_tab.dart';
import '../core/services/auth_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    HistoryScreen(),
    AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (AuthService.isAdminOffline)
            MaterialBanner(
              content: Text('وضع العرض التجريبي — البيانات مؤقتة', style: AppTextStyles.labelSmall),
              backgroundColor: AppColors.warning.withValues(alpha: 0.15),
              leading: const Icon(Icons.offline_bolt, color: AppColors.warning),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.camera),
              activeIcon: Icon(CupertinoIcons.camera_fill),
              label: 'فحص', // Scan
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.time),
              activeIcon: Icon(CupertinoIcons.time_solid),
              label: 'السجل', // History
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_solid),
              label: 'حسابي', // Account
            ),
          ],
        ),
      ),
    );
  }
}
