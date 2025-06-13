// lib/services/jadwal_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jadwal.dart';

class JadwalService {
  static const _storageKey = 'jadwal_data';

  Future<List<Jadwal>> loadJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final list = json.decode(jsonString) as List;
      return list.map((e) => Jadwal.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveJadwal(List<Jadwal> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
