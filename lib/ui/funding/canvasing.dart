import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/post_external_data.dart';
import '../../logic/get_external_data.dart';

class Canvasing extends StatefulWidget {
  @override
  _CanvasingState createState() => _CanvasingState();
}

class _CanvasingState extends State<Canvasing> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _namaProspectController = TextEditingController();
  TextEditingController _nikController = TextEditingController();
  TextEditingController _noHpController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _perusahaanController = TextEditingController();
  TextEditingController _tanggalKunjunganController = TextEditingController();
  
  File? _image;
  Uint8List? _webImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final PostExternalData _apiService = PostExternalData();
  final Username_Data _usernameData = Username_Data();
  
  String? _marketingId;
  List<Map<String, dynamic>> _listPekerjaan = [];
  String? _selectedPekerjaan;
  final Pekerjaan_Data _pekerjaanData = Pekerjaan_Data();

  @override
  void initState() {
    super.initState();
    _tanggalKunjunganController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchMarketingId();
    _fetchPekerjaan();
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

  Future<void> _fetchMarketingId() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? username = localStorage.getString('username');
    
    if (username != null) {
      var userData = await _usernameData.fetchUserData(username);
      
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
        _webImage = await pickedFile.readAsBytes();
        print("📸 Gambar dipilih untuk web!");
      } else {
        _image = File(pickedFile.path);
        print("📸 Gambar dipilih untuk mobile: ${_image?.path}");
      }
      setState(() {});
    } else {
      print("⚠️ Tidak ada gambar yang dipilih!");
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Layanan lokasi tidak aktif. Silakan aktifkan GPS')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin lokasi ditolak oleh pengguna')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin lokasi ditolak permanen, silakan aktifkan di pengaturan')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() || (_image == null && _webImage == null) || _marketingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua data dan pilih foto kunjungan!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Position? position = await _determinePosition();
    if (position == null) {
      setState(() => _isLoading = false);
      return;
    }

    String lokasi = '${position.latitude}, ${position.longitude}';

    Map<String, dynamic> prospectData = {
      'nama_prospect': _namaProspectController.text,
      'nik': _nikController.text,
      'no_handphone': _noHpController.text,
      'alamat_domisili': _alamatController.text,
      'pekerjaan': _selectedPekerjaan,
      'nama_perusahaan_unit_usaha': _perusahaanController.text,
      'tipe_prospect': 'Prospect',
      'marketing': _marketingId,
    };

    Map<String, dynamic> kunjunganData = {
      'tanggal_kunjungan': _tanggalKunjunganController.text,
      'marketing': _marketingId,
      'lokasi_kunjungan': lokasi,
      'tipe_kunjungan': 'b50c1acf-92db-4348-b6bb-86330869739a',
    };
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username tidak ditemukan!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    var response = await _apiService.sendData(username, prospectData, kunjunganData, _image, _webImage);

    setState(() => _isLoading = false);

    if (response != null) {
      setState(() {
        _namaProspectController.clear();
        _nikController.clear();
        _noHpController.clear();
        _alamatController.clear();
        _perusahaanController.clear();
        _selectedPekerjaan = null;
        _image = null;
        _webImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil dikirim!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data Canvasing', 
          style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _namaProspectController,
                label: 'Nama Prospect',
                isRequired: true,
                validator: (value) => value!.isEmpty ? 'Harap isi nama' : null,
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _nikController,
                label: 'NIK',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _noHpController,
                label: 'No HP (08xxxxxx)',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _alamatController,
                label: 'Alamat',
              ),
              SizedBox(height: 16),
              _buildDropdownField(),
              SizedBox(height: 16),
              _buildInputField(
                controller: _perusahaanController,
                label: 'Nama Perusahaan/Unit Usaha',
              ),
              SizedBox(height: 16),
              _buildInputField(
                controller: _tanggalKunjunganController,
                label: 'Tanggal Kunjungan',
                isReadOnly: true,
              ),
              SizedBox(height: 24),
              _buildImageSection(),
              SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isReadOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      readOnly: isReadOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedPekerjaan,
      decoration: InputDecoration(
        labelText: 'Pekerjaan',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('- Pilih Pekerjaan -', 
            style: TextStyle(color: Colors.grey[600])),
        ),
        ..._listPekerjaan.map((item) => DropdownMenuItem(
          value: item['id'],
          child: Text(item['pekerjaan']),
        )),
      ],
      onChanged: (value) => setState(() => _selectedPekerjaan = value),
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto Kunjungan', 
          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: _image == null && _webImage == null
              ? Center(child: Text('Belum ada gambar',
                  style: TextStyle(color: Colors.grey[500])))
              : kIsWeb
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_webImage!, fit: BoxFit.cover))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_image!, fit: BoxFit.cover)),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.camera_alt, size: 18),
            label: Text('Ambil Foto'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue[800]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _pickImage,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue[800]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Kembali', 
              style: TextStyle(color: Colors.blue[800])),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _submitData,
                  child: Text('Kirim', 
                    style: TextStyle(color: Colors.white)),
                ),
        ),
      ],
    );
  }
}