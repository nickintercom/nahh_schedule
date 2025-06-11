// lib/services/jadwal_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/jadwal.dart';

class JadwalService {
  static const String _storageKey = 'jadwal_data';

  Future<List<Jadwal>> loadJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List list = json.decode(jsonString) as List;
      return list.map((e) => Jadwal.fromJson(e)).toList();
    } else {
      final defaultList = _getDefaultJadwal();
      saveJadwal(defaultList);
      return defaultList;
    }
  }

  Future<void> saveJadwal(List<Jadwal> jadwalList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(jadwalList.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  List<Jadwal> _getDefaultJadwal() {
    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);
    return [
      Jadwal(
        matkul: 'Mobile Programming',
        waktu: ['08.00 WIB - 10.00 WIB'],
        date: dateStr,
      ),
      Jadwal(
        matkul: 'Teknologi Internet of Things',
        waktu: ['10.00 WIB - 12.00 WIB'],
        date: dateStr,
      ),
      Jadwal(
        matkul: 'Teknik Kompilasi',
        waktu: ['13.20 WIB - 15.00 WIB'],
        date: dateStr,
      ),
      Jadwal(
        matkul: 'Pemrograman II',
        waktu: ['15.30 WIB - 17.00 WIB'],
        date: dateStr,
      ),
    ];
  }
}
