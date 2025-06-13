import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('https://your-api-endpoint/user'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), centerTitle: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return Center(child: Text('Failed to load profile data'));
    }

    if (userData == null) {
      return Center(child: Text('No user data available'));
    }

    // Determine if the user is a lecturer or student
    final isLecturer = userData!['jabatan'] != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(isLecturer),
          SizedBox(height: 24),
          _buildProfileDetails(isLecturer),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isLecturer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLecturer ? userData!['nama'] ?? 'No Name' : 'Profil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Data ${isLecturer ? 'Dosen' : 'Pribadi'}',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Divider(thickness: 1),
      ],
    );
  }

  Widget _buildProfileDetails(bool isLecturer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLecturer) ...[
          _buildDetailItem('Nama', userData!['nama'] ?? 'Inosikacho'),
          SizedBox(height: 16),
        ],
        _buildDetailItem(
          isLecturer ? 'NIDN' : 'NIM',
          userData!['id'] ?? (isLecturer ? '221011405098' : '221011409887'),
        ),
        SizedBox(height: 16),
        _buildDetailItem(
          'Email',
          userData!['email'] ??
              (isLecturer
                  ? 'adeputraprimasuhendri_apps@gmail.com'
                  : 'inosikacho8@gmail.com'),
        ),
        SizedBox(height: 16),
        _buildDetailItem(
          'Nomor Telepon',
          userData!['phone'] ?? (isLecturer ? '081250731243' : '081250731255'),
        ),
        SizedBox(height: 16),
        _buildDetailItem(
          'Tanggal Lahir',
          userData!['birthdate'] ??
              (isLecturer ? '25 Juni 1999' : '25 Maret 2004'),
        ),
        SizedBox(height: 16),
        if (isLecturer)
          _buildDetailItem(
            'Jabatan',
            userData!['jabatan'] ?? 'Kepala Prodi Teknik Informatika',
          ),
        if (!isLecturer)
          _buildDetailItem('Kelas', userData!['kelas'] ?? '06TPLM001'),
        SizedBox(height: 16),
        _buildDetailItem(
          isLecturer ? 'Status Dosen' : 'Status Mahasiswa',
          userData!['status'] ?? 'Aktif',
          isStatus: true,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        SizedBox(height: 4),
        if (isStatus)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value.toLowerCase() == 'aktif'
                  ? Colors.green[100]
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: value.toLowerCase() == 'aktif'
                    ? Colors.green[800]
                    : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        Divider(thickness: 1),
      ],
    );
  }
}

// // lib/screens/profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ProfileScreen extends StatelessWidget {
//   final String userRole; // 'dosen' or 'mahasiswa'
//   final String name;
//   final String id;
//   final String email;
//   final String phone;
//   final DateTime birthDate;
//   final String? kelas;
//   final String? jabatan;
//   final bool isActive;

//   const ProfileScreen({
//     Key? key,
//     required this.userRole,
//     required this.name,
//     required this.id,
//     required this.email,
//     required this.phone,
//     required this.birthDate,
//     this.kelas,
//     this.jabatan,
//     required this.isActive,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final statusText = isActive ? 'Aktif' : 'Tidak Aktif';
//     final statusColor = isActive ? Colors.green : Colors.red;
//     final dateFormat = DateFormat('d MMMM y', 'id_ID');
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 0,
//         title: const Text('Profil', style: TextStyle(color: Colors.blue)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pushNamed(context, '/profileData'),
//             child: const Text('Data Pribadi', style: TextStyle(color: Colors.blue)),
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFE6E8FF),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEBEEFF),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: AssetImage('assets/images/profile.jpg'),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(name,
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Text(id, style: const TextStyle(color: Colors.black54)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildField('Email', email),
//             const SizedBox(height: 16),
//             _buildField('Nomor Telepon', phone),
//             const SizedBox(height: 16),
//             _buildField('Tanggal Lahir', dateFormat.format(birthDate)),
//             const SizedBox(height: 16),
//             if (userRole == 'mahasiswa') ...[
//               _buildField('Kelas', kelas ?? '-'),
//               const SizedBox(height: 16),
//               _buildField('Status Mahasiswa', statusText, valueColor: statusColor),
//             ] else ...[
//               _buildField('Jabatan', jabatan ?? '-'),
//               const SizedBox(height: 16),
//               _buildField('Status Dosen', statusText, valueColor: statusColor),
//             ],
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: handle logout
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 minimumSize: const Size.fromHeight(48),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Logout'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildField(String label, String value, {Color? valueColor}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             value,
//             style: TextStyle(fontSize: 14, color: valueColor ?? Colors.black),
//           ),
//         ),
//       ],
//     );
//   }
// }
