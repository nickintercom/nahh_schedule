import 'package:flutter/material.dart';
import 'package:nahh_schedule/screens/splash_screen.dart';
import 'package:nahh_schedule/screens/auth_screen.dart';
import 'package:nahh_schedule/screens/home_screen.dart';
import 'package:nahh_schedule/screens/jadwal_screen.dart';
import 'package:nahh_schedule/screens/notifikasi_screen.dart';
import 'package:nahh_schedule/screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String jadwal = '/jadwal';
  static const String tambahJadwal = '/jadwal/tambah';
  static const String updateJadwal = '/jadwal/update';
  static const String notifikasi = '/notifikasi';
  static const String profile = '/profile';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    auth: (context) => const AuthScreen(),
    home: (context) => const HomeScreen(),
    jadwal: (context) => const JadwalScreen(),
    notifikasi: (context) => const NotifikasiScreen(),
    profile: (context) => ProfileScreen(),
  };
}
