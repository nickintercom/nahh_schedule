// lib/screens/jadwal_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/jadwal.dart';
import '../services/jadwal_service.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/bottom_nav_bar.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  _JadwalScreenState createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final _service = JadwalService();
  List<Jadwal> _data = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  final _formKey = GlobalKey<FormState>();
  final _matkulCtrl = TextEditingController();
  String? _selectedTime;
  DateTime? _dialogDate;
  int? _editIndex;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _data = await _service.loadJadwal();
    if (_data.isEmpty) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _data = [
        Jadwal(
          matkul: 'Mobile Programming',
          waktu: ['08.00 WIB - 09.40 WIB'],
          date: today,
        ),
        // ... default items
      ];
      await _service.saveJadwal(_data);
    }
    setState(() => _loading = false);
  }

  List<Jadwal> get _filtered => _data
      .where((j) => j.date == DateFormat('yyyy-MM-dd').format(_selectedDate))
      .toList();

  void _selectDate(DateTime d) => setState(() => _selectedDate = d);

  Future<void> _showDialog({int? idx, DateTime? date}) async {
    _dialogDate = date ?? _selectedDate;
    _selectedTime = null;
    _matkulCtrl.clear();
    _editIndex = null;

    if (idx != null) {
      final j = _filtered[idx];
      _matkulCtrl.text = j.matkul;
      _selectedTime = j.waktu.isNotEmpty ? j.waktu.first : null;
      _editIndex = _data.indexOf(j);
      _dialogDate = DateFormat('yyyy-MM-dd').parse(j.date);
    }

    final slots = _generateTimeSlots();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(idx == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _matkulCtrl,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Isi nama matkul' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTime,
                  decoration: const InputDecoration(labelText: 'Waktu Kuliah'),
                  items: slots
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTime = v),
                  validator: (v) => v == null ? 'Pilih waktu' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newJ = Jadwal(
                    matkul: _matkulCtrl.text,
                    waktu: [_selectedTime!],
                    date: DateFormat('yyyy-MM-dd').format(_dialogDate!),
                  );
                  setState(() {
                    if (_editIndex != null)
                      _data[_editIndex!] = newJ;
                    else
                      _data.add(newJ);
                  });
                  await _service.saveJadwal(_data);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    TimeOfDay current = const TimeOfDay(hour: 8, minute: 0);
    while (current.hour < 22) {
      final next = TimeOfDay(
        hour: (current.hour + (current.minute + 100) ~/ 60),
        minute: (current.minute + 100) % 60,
      );
      final start =
          '${current.hour.toString().padLeft(2, '0')}.${current.minute.toString().padLeft(2, '0')}';
      final end =
          '${next.hour.toString().padLeft(2, '0')}.${next.minute.toString().padLeft(2, '0')}';
      slots.add('$start WIB - $end WIB');
      current = next;
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Kelola Jadwal Kuliah',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpeg'),
              radius: 18,
            ),
            padding: const EdgeInsets.only(right: 14),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: _selectDate,
            ),
            ..._filtered.asMap().entries.map((e) {
              final j = e.value;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(j.matkul),
                  subtitle: Text(j.waktu.first),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showDialog(idx: e.key),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          setState(() => _data.remove(j));
                          await _service.saveJadwal(_data);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () => _showDialog(),
              child: const Text(
                'Tambah Jadwal',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) Navigator.pushNamed(context, '/home');
          if (i == 1) Navigator.pushNamed(context, '/jadwal');
        },
        userRole: 'Dosen',
      ),
    );
  }
}
