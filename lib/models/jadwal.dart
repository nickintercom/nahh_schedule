// lib/models/jadwal.dart
// ignore_for_file: unused_import

import 'package:intl/intl.dart';

class Jadwal {
  final String matkul;
  final List<String> waktu;
  final String date;

  Jadwal({required this.matkul, required this.waktu, required this.date});

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    final waktuJson = json['waktu'];
    late List<String> waktuList;
    if (waktuJson is String) {
      waktuList = [waktuJson];
    } else if (waktuJson is List) {
      waktuList = List<String>.from(waktuJson);
    } else {
      waktuList = [];
    }
    return Jadwal(
      matkul: json['matkul'] as String,
      waktu: waktuList,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'matkul': matkul,
    'waktu': waktu,
    'date': date,
  };
}
