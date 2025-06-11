// lib/screens/jadwal_screen.dart
// ignore_for_file: unused_field, unused_local_variable

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
  DateTime _selectedDate = DateTime(2025, 5, 13);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matkulController = TextEditingController();
  int? _editingIndex;
  List<String> _selectedTimeSlots = [];

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
    return [
      {
        'matkul': 'Mobile Programming',
        'waktu': ['08.00 WIB - 09.40 WIB'],
        'date': '2025-05-13',
      },
      {
        'matkul': 'Teknologi Internet of Things',
        'waktu': ['10.00 WIB - 11.40 WIB'],
        'date': '2025-05-13',
      },
      {
        'matkul': 'Teknik Kompilasi',
        'waktu': ['13.20 WIB - 15.00 WIB'],
        'date': '2025-05-13',
      },
      {
        'matkul': 'Pemrograman II',
        'waktu': ['15.30 WIB - 17.10 WIB'],
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
    _selectedTimeSlots.clear();

    if (index != null) {
      _matkulController.text = _jadwalList[index]['matkul'];
      var waktu = _jadwalList[index]['waktu'];
      if (waktu is List) {
        _selectedTimeSlots.addAll(waktu.cast<String>());
      } else {
        _selectedTimeSlots.add(waktu);
      }
      _editingIndex = index;
    } else {
      _matkulController.clear();
      _selectedTimeSlots.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(index == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
              content: SingleChildScrollView(
                child: Form(
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
                      const SizedBox(height: 16),
                      const Text(
                        'Pilih Waktu Kuliah:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _TimeSlotPicker(
                        selectedSlots: _selectedTimeSlots,
                        onSelectionChanged: (slots) {
                          setStateDialog(() {
                            _selectedTimeSlots = slots;
                          });
                        },
                      ),
                      if (_selectedTimeSlots.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Waktu Terpilih:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ..._selectedTimeSlots.map(
                          (slot) => Chip(
                            label: Text(slot),
                            onDeleted: () {
                              setStateDialog(() {
                                _selectedTimeSlots.remove(slot);
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedTimeSlots.isNotEmpty) {
                      _saveJadwalItem(index);
                      Navigator.pop(context);
                    } else if (_selectedTimeSlots.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Harap pilih minimal satu waktu kuliah',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveJadwalItem(int? index) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final newJadwal = {
      'matkul': _matkulController.text,
      'waktu': _selectedTimeSlots.length == 1
          ? _selectedTimeSlots.first
          : List.from(_selectedTimeSlots),
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
              item['matkul'] == _getJadwalForSelectedDate()[index]['matkul'] &&
              item['date'] == _getJadwalForSelectedDate()[index]['date'],
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
                final waktuList = jadwal['waktu'] is List
                    ? jadwal['waktu'].cast<String>()
                    : [jadwal['waktu']];
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
                                        item['date'] == jadwal['date'],
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
          // Navigasi berdasarkan index
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/jadwal');
          }
        },
        userRole: 'Dosen', // Atau 'mahasiswa' sesuai kebutuhan
      ),
    );
  }

  @override
  void dispose() {
    _matkulController.dispose();
    super.dispose();
  }
}

class _TimeSlotPicker extends StatelessWidget {
  final List<String> selectedSlots;
  final Function(List<String>) onSelectionChanged;

  const _TimeSlotPicker({
    required this.selectedSlots,
    required this.onSelectionChanged,
  });

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    TimeOfDay currentTime = const TimeOfDay(hour: 8, minute: 0);
    const duration = Duration(minutes: 100); // 1 jam 40 menit

    while (currentTime.hour < 16 ||
        (currentTime.hour == 16 && currentTime.minute <= 20)) {
      TimeOfDay nextTime = TimeOfDay(
        hour: currentTime.hour + (currentTime.minute + 100) ~/ 60,
        minute: (currentTime.minute + 100) % 60,
      );
      final startStr = _formatTimeOfDay(currentTime);
      final endStr = _formatTimeOfDay(nextTime);
      slots.add('$startStr WIB - $endStr WIB');
      currentTime = nextTime;
    }

    currentTime = const TimeOfDay(hour: 18, minute: 20);
    while (currentTime.hour < 22) {
      TimeOfDay nextTime = TimeOfDay(
        hour: currentTime.hour + (currentTime.minute + 100) ~/ 60,
        minute: (currentTime.minute + 100) % 60,
      );
      if (nextTime.hour >= 22) break;
      final startStr = _formatTimeOfDay(currentTime);
      final endStr = _formatTimeOfDay(nextTime);
      slots.add('$startStr WIB - $endStr WIB');
      currentTime = nextTime;
    }

    return slots;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final slot = timeSlots[index];
              final isSelected = selectedSlots.contains(slot);
              return FilterChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: (selected) {
                  final newSelection = List<String>.from(selectedSlots);
                  if (selected) {
                    newSelection.add(slot);
                  } else {
                    newSelection.remove(slot);
                  }
                  onSelectionChanged(newSelection);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
