// lib/screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_nav_bar.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  int _currentIndex = 2; // Assuming notifications is the 3rd tab
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // Mock data - in a real app, this would come from an API or database
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    setState(() {
      _notifications = [
        // Today's notifications
        {
          'title': 'Kelas Mobile Programming',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': now.subtract(const Duration(minutes: 5)),
          'isRead': false,
          'group': 'Hari Ini',
        },
        {
          'title': 'Kelas Mobile Programming',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': now.subtract(const Duration(minutes: 30)),
          'isRead': false,
          'group': 'Hari Ini',
        },
        {
          'title': 'Kelas Teknik Kompilasi',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': now.subtract(const Duration(hours: 1)),
          'isRead': false,
          'group': 'Hari Ini',
        },
        {
          'title': 'Kelas Teknologi Internet of Things',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': now.subtract(const Duration(hours: 2)),
          'isRead': false,
          'group': 'Hari Ini',
        },
        {
          'title': 'Kelas Mobile Programming',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': now.subtract(const Duration(hours: 5)),
          'isRead': false,
          'group': 'Hari Ini',
        },
        // Yesterday's notifications
        {
          'title': 'Kelas Mobile Programming',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': yesterday.subtract(const Duration(minutes: 5)),
          'isRead': false,
          'group': 'Kemarin',
        },
        {
          'title': 'Kelas Mobile Programming',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': yesterday.subtract(const Duration(minutes: 30)),
          'isRead': false,
          'group': 'Kemarin',
        },
        {
          'title': 'Kelas Teknik Kompilasi',
          'message': 'Jangan lupa untuk mengikuti materi hari ini',
          'time': yesterday.subtract(const Duration(hours: 1)),
          'isRead': false,
          'group': 'Kemarin',
        },
      ];
    });
  }

  void _toggleReadStatus(int index, bool? value) {
    setState(() {
      _notifications[index]['isRead'] = value ?? false;
    });
    // In a real app, you would save this change to your database/API
  }

  Widget _buildNotificationGroup(String groupTitle) {
    final groupNotifications = _notifications
        .where((notification) => notification['group'] == groupTitle)
        .toList();

    if (groupNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                groupTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    for (var i = 0; i < _notifications.length; i++) {
                      if (_notifications[i]['group'] == groupTitle) {
                        _notifications[i]['isRead'] = true;
                      }
                    }
                  });
                },
                child: const Text(
                  'Tandai Sudah Baca',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        ...groupNotifications.asMap().entries.map((entry) {
          final index = _notifications.indexWhere((n) => n == entry.value);
          return NotificationItem(
            title: entry.value['title'],
            message: entry.value['message'],
            time: entry.value['time'],
            isRead: entry.value['isRead'],
            onChanged: (value) => _toggleReadStatus(index, value),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNotificationGroup('Hari Ini'),
            _buildNotificationGroup('Kemarin'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigation logic would go here
        },
        userRole: 'Dosen',
      ),
    );
  }
}
