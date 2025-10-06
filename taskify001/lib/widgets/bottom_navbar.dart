import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';

class TakifyBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const TakifyBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
