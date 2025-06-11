// lib/screens/home_screen.dart
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
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  List<Map<String, dynamic>> _jadwalList = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeDateFormatting('id_ID', null);
    await _loadJadwal();
    setState(() => _isLoading = false);
  }

  Future<void> _loadJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final jadwalData = prefs.getString('jadwal_data');

    if (jadwalData != null) {
      setState(() {
        _jadwalList = List<Map<String, dynamic>>.from(
          json
              .decode(jadwalData)
              .map((item) => Map<String, dynamic>.from(item)),
        );
      });
    } else {
      setState(() {
        _jadwalList = _getDefaultJadwal();
      });
      _saveJadwal();
    }
  }

  List<Map<String, dynamic>> _getDefaultJadwal() {
    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);
    return [
      {
        'matkul': 'Mobile Programming',
        'waktu': ['08.00 WIB - 10.00 WIB'],
        'date': dateStr,
      },
      {
        'matkul': 'Teknologi Internet of Things',
        'waktu': ['10.00 WIB - 12.00 WIB'],
        'date': dateStr,
      },
      {
        'matkul': 'Teknik Kompilasi',
        'waktu': ['13.20 WIB - 15.00 WIB'],
        'date': dateStr,
      },
      {
        'matkul': 'Pemrograman II',
        'waktu': ['15.30 WIB - 17.00 WIB'],
        'date': dateStr,
      },
    ];
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

  List<Map<String, dynamic>> _getJadwalForSelectedDate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _jadwalList.where((jadwal) => jadwal['date'] == dateStr).toList();
  }

  Widget _buildJadwalHarian() {
    final jadwalHariIni = _getJadwalForSelectedDate();
    final dateFormat = DateFormat('d MMMM y', 'id_ID');
    final dateStr = dateFormat.format(_selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (jadwalHariIni.isNotEmpty)
                Column(
                  children: jadwalHariIni.map((jadwal) {
                    final waktuList = jadwal['waktu'] is List
                        ? jadwal['waktu'].cast<String>()
                        : [jadwal['waktu']];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jadwal['matkul'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...waktuList.map(
                            (waktu) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                waktu,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/jadwal');
          }
        },
        userRole: 'Dosen',
      ),
    );
  }
}
