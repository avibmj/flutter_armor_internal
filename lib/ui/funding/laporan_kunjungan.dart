import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:armor_internal/logic/get_external_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/kunjungan_post.dart';
import 'package:geolocator/geolocator.dart';

class LaporanKunjungan extends StatefulWidget {
  final Map<String, dynamic> prospect;

  const LaporanKunjungan({Key? key, required this.prospect}) : super(key: key);

  @override
  _LaporanKunjunganState createState() => _LaporanKunjunganState();
}

class _LaporanKunjunganState extends State<LaporanKunjungan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalKunjunganController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  Uint8List? _webImage;
  List<Map<String, dynamic>> _listPekerjaan = [];
  List<Map<String, dynamic>> _listTipeKunjungan = [];
  String? _selectedPekerjaan;
  String? _selectedTipeKunjungan;
  String? _marketingId;
  final Pekerjaan_Data _pekerjaanData = Pekerjaan_Data();
  final TipeKunjungan_Data _tipeKunjunganData = TipeKunjungan_Data();
  bool _isLoading = false;
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _namaProspectController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _namaPerusahaanController = TextEditingController();
  Position? _currentPosition; // ✅ Simpan posisi pengguna
  final KunjunganPost _kunjunganPost = KunjunganPost(); // ✅ Buat instance

  @override
  void initState() {
    super.initState();
    _tanggalKunjunganController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _namaProspectController.text = widget.prospect['nama_prospect'] ?? '';
    _nikController.text = widget.prospect['nik'] ?? '';
    _noHpController.text = widget.prospect['no_handphone'] ?? '';
    _alamatController.text = widget.prospect['alamat_domisili'] ?? '';
    _namaPerusahaanController.text = widget.prospect['nama_perusahaan_unit_usaha'] ?? '';

    _fetchMarketingId();
    _fetchPekerjaan();
    _getCurrentLocation();
    _fetchTipeKunjungan();
  }

  @override
  void dispose() {
    _tanggalKunjunganController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchPekerjaan() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      print("Username tidak ditemukan, tidak dapat fetch data pekerjaan.");
      return;
    }

    var pekerjaanData = await _pekerjaanData.fetchPekerjaanData(username);

    if (pekerjaanData != null && pekerjaanData.containsKey('data')) {
      setState(() {
        _listPekerjaan = List<Map<String, dynamic>>.from(pekerjaanData['data']);
      });
    } else {
      setState(() {
        _listPekerjaan = [];
      });
      print("Data pekerjaan tidak ditemukan atau terjadi kesalahan.");
    }
  }

  Future<void> _fetchTipeKunjungan() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      print("Username tidak ditemukan, tidak dapat fetch data tipe kunjungan.");
      return;
    }

    var tipeKunjunganData = await _tipeKunjunganData.fetchTipeKunjunganData(username);

    if (tipeKunjunganData != null && tipeKunjunganData.containsKey('data')) {
      setState(() {
        _listTipeKunjungan = List<Map<String, dynamic>>.from(tipeKunjunganData['data']);
      });
    } else {
      setState(() {
        _listTipeKunjungan = [];
      });
      print("Data tipe kunjungan tidak ditemukan atau terjadi kesalahan.");
    }
  }

  Future<void> _fetchMarketingId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      var userData = await Username_Data().fetchUserData(username);

      if (userData != null && userData.containsKey('data') && userData['data'].isNotEmpty) {
        setState(() {
          _marketingId = userData['data'][0]['id'].toString();
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes(); // Simpan dalam Uint8List
        print("📸 Gambar dipilih untuk web!");
      } else {
        _image = File(pickedFile.path);
        print("📸 Gambar dipilih untuk mobile: ${_image?.path}");
      }
      setState(() {}); // Memastikan UI diperbarui
    } else {
      print("⚠️ Tidak ada gambar yang dipilih!");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak permanen');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_selectedTipeKunjungan == null) {
      _showSnackBar('Tipe Kunjungan wajib dipilih!');
      return;
    }

    if (_currentPosition == null) {
      _showSnackBar('Lokasi wajib tersedia!');
      return;
    }

    if (_image == null && _webImage == null) {
      _showSnackBar('Foto Kunjungan wajib diambil!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String lokasiKunjungan = "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
      String namaProspect = _namaProspectController.text.isNotEmpty
          ? _namaProspectController.text
          : widget.prospect['nama_prospect'] ?? '';

      if (namaProspect.isEmpty) {
        _showSnackBar('Nama Prospect wajib diisi!');
        return;
      }

      // Platform-specific image handling
      if (kIsWeb) {
        await _kunjunganPost.postKunjungan(
          idProspect: widget.prospect['id'].toString(),
          marketingId: _marketingId!,
          namaProspect: namaProspect,
          tanggalKunjungan: _tanggalKunjunganController.text,
          lokasiKunjungan: lokasiKunjungan,
          tipeKunjungan: _selectedTipeKunjungan!,
          noHandphone: _noHpController.text,
          namaPerusahaan: _namaPerusahaanController.text,
          nik: _nikController.text,
          pekerjaan: _selectedPekerjaan ?? '',
          alamatDomisili: _alamatController.text,
          catatan: _catatanController.text,
          webImage: _webImage, // Pass Uint8List directly for web
          fotoKunjungan: null, // Null for web
        );
      } else {
        await _kunjunganPost.postKunjungan(
          idProspect: widget.prospect['id'].toString(),
          marketingId: _marketingId!,
          namaProspect: namaProspect,
          tanggalKunjungan: _tanggalKunjunganController.text,
          lokasiKunjungan: lokasiKunjungan,
          tipeKunjungan: _selectedTipeKunjungan!,
          noHandphone: _noHpController.text,
          namaPerusahaan: _namaPerusahaanController.text,
          nik: _nikController.text,
          pekerjaan: _selectedPekerjaan ?? '',
          alamatDomisili: _alamatController.text,
          catatan: _catatanController.text,
          fotoKunjungan: _image, // Pass File directly for mobile
          webImage: null, // Null for mobile
        );
      }
      _showSnackBar('Data berhasil disimpan');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      print('Error submitting form: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kunjungan", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Prospect Data Section
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "Data Prospect",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 97, 97, 97)),
                      ),
                    ),
                    _buildInputField("Nama Prospect *", _namaProspectController),
                    _buildInputField("NIK", _nikController),
                    _buildInputField("No HP", _noHpController),
                    _buildInputField("Alamat", _alamatController),
                    _buildInputField("Nama Perusahaan/Unit Usaha", _namaPerusahaanController),
                    _buildDropdownPekerjaan(),

                    const SizedBox(height: 20),

                    // Visit Data Section
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 12.0),
                      child: Text(
                        "Data Kunjungan",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 108, 108, 108)),
                      ),
                    ),
                    _buildDropdownTipeKunjungan(),
                    _buildDatePickerField("Tanggal Kunjungan *"),
                    _buildInputField("Catatan", _catatanController, maxLines: 3),

                    const SizedBox(height: 20),

                    Text(
                      'Foto Kunjungan *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: _image == null && _webImage == null
                          ? const Text('Belum ada foto', style: TextStyle(color: Colors.grey))
                          : SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.memory(_webImage!, fit: BoxFit.cover)
                                    : Image.file(_image!, fit: BoxFit.cover),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ambil Foto Kunjungan'),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text("Simpan Laporan"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: (value) {
          if (label.contains("*") && (value == null || value.isEmpty)) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownPekerjaan() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedPekerjaan,
        decoration: InputDecoration(
          labelText: 'Pekerjaan',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: _listPekerjaan.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['pekerjaan']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedPekerjaan = value;
          });
        },
      ),
    );
  }

  Widget _buildDatePickerField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _tanggalKunjunganController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
        ),
        validator: (value) {if (value == null || value.isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light().copyWith(
                    primary: Colors.blueAccent,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            setState(() {
              _tanggalKunjunganController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }

  Widget _buildDropdownTipeKunjungan() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedTipeKunjungan,
        decoration: InputDecoration(
          labelText: 'Tipe Kunjungan *',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: (value) => value == null ? 'Pilih tipe kunjungan' : null,
        items: _listTipeKunjungan.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['tipe_kunjungan']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTipeKunjungan = value;
          });
        },
      ),
    );
  }
}