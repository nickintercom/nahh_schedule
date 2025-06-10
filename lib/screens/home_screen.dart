// lib/screens/jadwal_screen.dart
// ignore_for_file: unused_element, unnecessary_to_list_in_spreads

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  List<Map<String, String>> _jadwalList = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true; //

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeDateFormatting('id_ID', null); // Initialize ID locale
    await _loadJadwal();
    setState(() => _isLoading = false);
  }

  Future<void> _loadJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final jadwalData = prefs.getString('jadwal_data');

    if (jadwalData != null) {
      setState(() {
        _jadwalList = List<Map<String, String>>.from(
          (json.decode(jadwalData) as List).map(
            (item) => Map<String, String>.from(item),
          ),
        );
      });
    } else {
      // Default data if nothing in SharedPreferences
      setState(() {
        _jadwalList = _getDefaultJadwal(_selectedDate);
      });
      _saveJadwal();
    }
  }

  List<Map<String, String>> _getDefaultJadwal(DateTime date) {
    // Only show default schedule for May 13, 2025 (as in the mockup)
    if (date.year == 2025 && date.month == 5 && date.day == 13) {
      return [
        {
          'matkul': 'Mobile Programming',
          'waktu': '08.00 WIB - 10.00 WIB',
          'date': '2025-05-13',
        },
        {
          'matkul': 'Teknologi Internet of Things',
          'waktu': '10.00 WIB - 12.00 WIB',
          'date': '2025-05-13',
        },
        {
          'matkul': 'Teknik Kompilasi',
          'waktu': '13.20 WIB - 15.00 WIB',
          'date': '2025-05-13',
        },
        {
          'matkul': 'Pemrograman II',
          'waktu': '15.30 WIB - 17.00 WIB',
          'date': '2025-05-13',
        },
      ];
    }
    return [];
  }

  Future<void> _saveJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jadwal_data', json.encode(_jadwalList));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<Map<String, String>> _getJadwalForSelectedDate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _jadwalList.where((jadwal) => jadwal['date'] == dateStr).toList();
  }

  Widget _buildJadwalHarian() {
    final jadwalHariIni = _getJadwalForSelectedDate();
    final dateFormat = DateFormat('d MMMM y', 'id_ID');
    final dateStr = dateFormat.format(_selectedDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (jadwalHariIni.isNotEmpty)
              ...jadwalHariIni
                  .map(
                    (jadwal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal['matkul']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            jadwal['waktu']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Tidak ada jadwal kuliah hari ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kuliah')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ),
            _buildJadwalHarian(),
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
