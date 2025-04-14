import 'package:flutter/material.dart';
import 'package:armor_internal/ui/home.dart';
import 'package:armor_internal/ui/setting/setting.dart';
import 'package:armor_internal/ui/profile/profile.dart';


class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BuildContext context;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });

  void _handleNavigation(int index) {
    if (index == 0) {
      if (currentIndex == 0) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        (route) => false,
      );
    } else if (index == 1) {
      if (currentIndex == 1) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
        (route) => false,
      );
    } else if (index == 2) {
      if (currentIndex == 2) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex >= 0 && currentIndex < 3 ? currentIndex : 0;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: _handleNavigation,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xff3572EF),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

}
