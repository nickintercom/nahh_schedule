// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.date_range,
            color: currentIndex == 0
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.list_alt_outlined,
            color: currentIndex == 1
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          label: userRole == 'mahasiswa' ? 'Notifikasi' : 'Jadwal',
        ),
      ],
    );
  }
}
