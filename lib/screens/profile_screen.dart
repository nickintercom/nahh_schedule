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
