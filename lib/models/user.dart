class User {
  final String id;
  final String nama;
  final String email;
  final String phone;
  final String birthdate;
  final String? jabatan;
  final String? kelas;
  final String status;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.phone,
    required this.birthdate,
    this.jabatan,
    this.kelas,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        nama: json['nama'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        birthdate: json['birthdate'] as String,
        jabatan: json['jabatan'] as String?,
        kelas: json['kelas'] as String?,
        status: json['status'] as String? ?? 'Aktif',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'email': email,
        'phone': phone,
        'birthdate': birthdate,
        'jabatan': jabatan,
        'kelas': kelas,
        'status': status,
      };
}
