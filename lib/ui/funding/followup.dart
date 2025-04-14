import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armor_internal/ui/funding/detail.dart';
import 'package:armor_internal/ui/funding/laporan_kunjungan.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../logic/get_external_data.dart';

class Followup extends StatefulWidget {
  @override
  _FollowupState createState() => _FollowupState();
}

class _FollowupState extends State<Followup> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> apiData = [];
  bool isLoading = false;
  String username = "test1";

  @override
  void initState() {
    super.initState();
    _getProspectData();
  }

  void _getProspectData({String? name, String? date}) async {
    setState(() {
      isLoading = true;
    });

    var response = await Prospect_Data().fetchProspectData(username, name: name, date: date, id: '');

    setState(() {
      apiData = response.containsKey("data") && response["data"] is List
          ? List<Map<String, dynamic>>.from(response["data"])
          : [];
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(
              primary: Colors.indigoAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    if (phoneNumber.startsWith("08")) {
      phoneNumber = phoneNumber.substring(1);
    }

    String url = "https://wa.me/62$phoneNumber";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }

  void _showNoPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nomor HP Tidak Tersedia", style: TextStyle(fontWeight: FontWeight.w500)),
          content: const Text("Nomor HP tidak ditemukan. Silakan periksa kembali data prospect."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.indigoAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Follow Up", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Masukkan Nama Nasabah",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ""
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                      decoration: InputDecoration(
                        hintText: "Pilih Tanggal (dd/mm/yyyy)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range, color: Colors.indigoAccent),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _getProspectData(
                          name: _nameController.text.isNotEmpty ? _nameController.text : null,
                          date: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
                        );
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text("Cari Prospect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                  : apiData.isEmpty
                      ? Center(
                          child: Text(
                            "Data prospect tidak ditemukan",
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: apiData.length,
                          itemBuilder: (context, index) {
                            var prospect = apiData[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: Text(prospect['nama_prospect'] ?? "No Name", style: const TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                  "${prospect['tipe_prospect']} - ${prospect['dateCreated']}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow("No. HP", prospect['no_handphone']),
                                        _buildDetailRow("Alamat", prospect['alamat_domisili']),
                                        _buildDetailRow("Pekerjaan", prospect['pekerjaan']),
                                        _buildDetailRow("Perusahaan", prospect['nama_perusahaan_unit_usaha']),
                                        _buildDetailRow("Tanggal Dibuat", prospect['dateCreated']),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _buildActionButton("Lihat Detail", Colors.indigo, () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Detail(prospect: prospect),
                                                ),
                                              );
                                            }),
                                            _buildActionButton("Telp. WA", Colors.green, () {
                                              String? phoneNumber = prospect['no_handphone'];
                                              if (phoneNumber != null && phoneNumber.isNotEmpty) {
                                                _launchWhatsApp(phoneNumber);
                                              } else {
                                                _showNoPhoneDialog(context);
                                              }
                                            }),
                                            _buildActionButton("Laporan Kunjungan", Colors.blueAccent, () async {
                                              final updatedData = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => LaporanKunjungan(prospect: prospect),
                                                ),
                                              );
                                              if (updatedData != null) {
                                                setState(() {
                                                  prospect.addAll(updatedData);
                                                });
                                              }
                                            }),
                                            _buildActionButton("Buka Tabungan", Colors.orange, () {}),
                                            _buildActionButton("Buka Deposito", Colors.deepOrange, () {}),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label:", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? "-", style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        elevation: 1,
      ),
      child: Text(text),
    );
  }
}