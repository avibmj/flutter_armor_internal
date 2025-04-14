import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  final Map<String, dynamic> prospect;

  Detail({required this.prospect});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Ambil ukuran layar

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Kunjungan"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // Agar bisa di-scroll di layar kecil
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 600 ? 100 : 16, // Sesuaikan padding berdasarkan layar
            vertical: 20,
          ),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox( // Agar tidak terlalu melebar di layar besar
                constraints: BoxConstraints(
                  maxWidth: 600, // Batasi lebar maksimum agar tidak terlalu lebar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Data Prospect",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField("Nama Prospect", prospect['nama_prospect']),
                    _buildTextField("NIK", prospect['nik']),
                    _buildTextField("No HP", prospect['no_handphone']),
                    _buildTextField("Alamat", prospect['alamat_domisili']),
                    _buildTextField("Nama Perusahaan/Unit Usaha", prospect['nama_perusahaan_unit_usaha']),
                    _buildTextField("Pekerjaan", prospect['pekerjaan']),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft, // Posisi tombol ke kiri
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Kembali", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: value ?? "-",
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
