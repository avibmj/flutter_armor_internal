import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class KunjunganPost {
  final String apiUrl = "https://armor.on.joget.cloud/jw/api/form/app001_frm028/saveOrUpdate";
  final String apiKunjungan = "https://armor.on.joget.cloud/jw/api/form/app001_frm027/addWithFiles";
  final String apiIdProspect = "API-731e7897-0f41-41ea-988a-ff53eca0ef7b";
  final String apiIdKunjungan = "API-2bc4386c-c312-4ead-8533-b2e51b323826";
  final String apiToken = "284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152";

  Future<void> postKunjungan({
    required String idProspect,
    String? noHandphone,
    String? namaPerusahaan,
    String? nik,
    String? pekerjaan,
    String? tipeProspect,
    String? tipeProspectLama,
    required String namaProspect,
    String? alamatDomisili,
    required String tanggalKunjungan,
    required String lokasiKunjungan,
    required String tipeKunjungan,
    String? catatan,
    required String marketingId,
    File? fotoKunjungan, // Untuk Mobile
    Uint8List? webImage, // Untuk Web
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('api_key');

    if (apiKey == null) {
      print("Error: API Key tidak ditemukan di SharedPreferences");
      return;
    }

    final Map<String, String> headers = {
      'api_id': apiIdProspect,
      'api_key': apiKey,
      'token': apiToken,
      'Content-Type': 'application/json'
    };

    final Map<String, dynamic> body = {
      'no_handphone': noHandphone,
      'nama_perusahaan_unit_usaha': namaPerusahaan,
      'nik': nik,
      'marketing': marketingId,
      'pekerjaan': pekerjaan,
      'nama_prospect': namaProspect,
      'alamat_domisili': alamatDomisili,
      'id': idProspect,
      // logika agar tidak null
      if ((tipeProspect ?? "").isNotEmpty)
        'tipe_prospect': tipeProspect
      else if ((tipeProspectLama ?? "").isNotEmpty)
        'tipe_prospect': tipeProspectLama,
    };


    print("Mengirim data prospect ke: $apiUrl");
    print("Payload: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('id')) {
          final reportId = responseData['id'];
          print("Prospect berhasil dikirim dengan ID: $reportId");

          // Kirim data kunjungan setelah prospect berhasil dikirim
          await postDataKunjungan(
            reportId: reportId,
            tanggalKunjungan: tanggalKunjungan,
            lokasiKunjungan: lokasiKunjungan,
            tipeKunjungan: tipeKunjungan,
            catatan: catatan ?? "",
            fotoKunjungan: fotoKunjungan,
            webImage: webImage,
            marketingId: marketingId,
            apiKey: apiKey,
          );
        } else {
          print("Error: Response tidak mengandung ID prospect");
        }
      } else {
        print("Gagal mengirim prospect: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> postDataKunjungan({
    required String reportId,
    required String tanggalKunjungan,
    required String lokasiKunjungan,
    required String tipeKunjungan,
    required String catatan,
    File? fotoKunjungan,
    Uint8List? webImage,
    required String marketingId,
    required String apiKey,
  }) async {
    final Map<String, String> headersKunjungan = {
      'api_id': apiIdKunjungan,
      'api_key': apiKey,
      'token': apiToken,
    };

    final request = http.MultipartRequest('POST', Uri.parse(apiKunjungan))
      ..headers.addAll(headersKunjungan)
      ..fields['nama_prospect'] = reportId
      ..fields['tanggal_kunjungan'] = tanggalKunjungan
      ..fields['marketing'] = marketingId
      ..fields['lokasi_kunjungan'] = lokasiKunjungan
      ..fields['tipe_kunjungan'] = tipeKunjungan
      ..fields['catatan'] = catatan;

    // Handle image upload for both platforms
    if (kIsWeb && webImage != null) {
      print("🖼️ Mengunggah gambar dari Web...");
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto_kunjungan',
          webImage,
          filename: "web_image.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );
    } else if (fotoKunjungan != null) {
      print("📸 Mengunggah gambar dari Mobile...");
      var fileStream = http.ByteStream(fotoKunjungan.openRead());
      var length = await fotoKunjungan.length();
      var multipartFile = http.MultipartFile(
        'foto_kunjungan',
        fileStream,
        length,
        filename: fotoKunjungan.path.split('/').last,
        contentType: MediaType("image", "jpeg"),
      );
      request.files.add(multipartFile);
    }

    print("🔄 Mengirim data kunjungan ke: $apiKunjungan...");
    try {
      final responseKunjungan = await request.send();
      final responseBody = await responseKunjungan.stream.bytesToString();

      print("Response Status: ${responseKunjungan.statusCode}");
      print("Response Body: $responseBody");

      if (responseKunjungan.statusCode == 200) {
        print("✅ Laporan kunjungan berhasil disimpan.");
      } else {
        print("❌ Gagal mengirim kunjungan: ${responseKunjungan.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}