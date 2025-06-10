// lib/screens/kelola_jadwal_screen.dart
// ignore_for_file: unused_field

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/bottom_nav_bar.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _currentIndex = 1;
  List<Map<String, dynamic>> _jadwalList = [];
  DateTime _selectedDate = DateTime(2025, 5, 13); // Default to May 13, 2025
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matkulController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final jadwalData = prefs.getString('jadwal_data');

    if (jadwalData != null) {
      setState(() {
        _jadwalList = List<Map<String, dynamic>>.from(
          (json.decode(jadwalData) as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      });
    } else {
      // Default data if nothing in SharedPreferences
      setState(() {
        _jadwalList = _getDefaultJadwal();
      });
      _saveJadwal();
    }
  }

  List<Map<String, dynamic>> _getDefaultJadwal() {
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

  void _showEditDialog([int? index]) {
    if (index != null) {
      _matkulController.text = _jadwalList[index]['matkul'];
      _waktuController.text = _jadwalList[index]['waktu'];
      _editingIndex = index;
    } else {
      _matkulController.clear();
      _waktuController.clear();
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _matkulController,
                  decoration: InputDecoration(labelText: 'Mata Kuliah'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi nama mata kuliah';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _waktuController,
                  decoration: InputDecoration(
                    labelText: 'Waktu (e.g., 08.00 WIB - 10.00 WIB)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi waktu kuliah';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveJadwalItem(index);
                  Navigator.pop(context);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _saveJadwalItem(int? index) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final newJadwal = {
      'matkul': _matkulController.text,
      'waktu': _waktuController.text,
      'date': dateStr,
    };

    setState(() {
      if (index != null) {
        _jadwalList[index] = newJadwal;
      } else {
        _jadwalList.add(newJadwal);
      }
      _saveJadwal();
    });
  }

  void _deleteJadwal(int index) {
    final globalIndex =
        _jadwalList.indexWhere(
          (item) =>
              item['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate),
        ) +
        index;

    setState(() {
      _jadwalList.removeAt(globalIndex);
      _saveJadwal();
    });
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
              ...List.generate(jadwalHariIni.length, (index) {
                final jadwal = jadwalHariIni[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            jadwal['matkul'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _showEditDialog(
                                  _jadwalList.indexWhere(
                                    (item) =>
                                        item['matkul'] == jadwal['matkul'] &&
                                        item['waktu'] == jadwal['waktu'],
                                  ),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _deleteJadwal(index),
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jadwal['waktu'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              })
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Tidak ada jadwal kuliah hari ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () => _showEditDialog(),
                child: const Text('Tambah Jadwal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal Kuliah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
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

  @override
  void dispose() {
    _matkulController.dispose();
    _waktuController.dispose();
    super.dispose();
  }
}
