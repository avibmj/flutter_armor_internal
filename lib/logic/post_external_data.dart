import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:armor_internal/logic/get_external_data.dart';

class PostExternalData {
  final String apiProspectUrl =
      "https://armor.on.joget.cloud/jw/api/form/app001_frm028/saveOrUpdate";
  final String apiKunjunganUrl =
      "https://armor.on.joget.cloud/jw/api/form/app001_frm027/addWithFiles";

  Future<Map<String, String>> getHeadersProspect(String username) async {
    Username_Data userData = Username_Data();
    Map<String, dynamic>? user;
    
    try {
      var userDataResponse = await userData.fetchUserData(username);

      // Ambil data pertama dari array "data"
      if (userDataResponse != null && userDataResponse.containsKey('data') && userDataResponse['data'] is List) {
        List<dynamic> dataList = userDataResponse['data'];
        if (dataList.isNotEmpty) {
          user = dataList.first; // Ambil elemen pertama dari list
        }
      }
    } catch (e) {
      print("❌ Error saat mengambil data user: $e");
    }

    if (user == null || !user.containsKey('api_key') || user['api_key'] == null) {
      print("❌ API Key tidak ditemukan untuk user: $username");
      return {
        'api_id': 'API-731e7897-0f41-41ea-988a-ff53eca0ef7b',
        'api_key': '',
        'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
        'Content-Type': 'application/json'
      };
    }

    return {
      'api_id': 'API-731e7897-0f41-41ea-988a-ff53eca0ef7b',
      'api_key': user['api_key'],
      'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
      'Content-Type': 'application/json'
    };
  }

  Future<Map<String, String>> getHeadersKunjungan(String username) async {
    Username_Data userData = Username_Data();
    Map<String, dynamic>? user;

    try {
      var userDataResponse = await userData.fetchUserData(username);

      // Ambil data pertama dari array "data"
      if (userDataResponse != null && userDataResponse.containsKey('data') && userDataResponse['data'] is List) {
        List<dynamic> dataList = userDataResponse['data'];
        if (dataList.isNotEmpty) {
          user = dataList.first; // Ambil elemen pertama dari list
        }
      }
    } catch (e) {
      print("❌ Error saat mengambil data user: $e");
    }

    if (user == null || !user.containsKey('api_key') || user['api_key'] == null) {
      print("❌ API Key tidak ditemukan untuk user: $username");
      return {
        'api_id': 'API-2bc4386c-c312-4ead-8533-b2e51b323826',
        'api_key': '',
        'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
      };
    }

    return {
      'api_id': 'API-2bc4386c-c312-4ead-8533-b2e51b323826',
      'api_key': user['api_key'],
      'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
    };
  }

  Future<File?> compressImage(File imageFile) async {
    try {
      print("📷 Memulai kompresi gambar...");
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print("❌ Gagal mendekode gambar.");
        return null;
      }

      img.Image resizedImage = img.copyResize(image, width: 800);
      Uint8List compressedBytes = img.encodeJpg(resizedImage, quality: 75);

      Directory tempDir = await getTemporaryDirectory();
      File compressedFile = File('${tempDir.path}/compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);
      
      print("✅ Gambar berhasil dikompresi: \${compressedFile.path}");
      return compressedFile;
    } catch (e) {
      print("❌ Error compressing image: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendData(
  String username, Map<String, dynamic> prospectData, Map<String, dynamic> kunjunganData, File? imageFile, Uint8List? webImage) async {
    try {
      print("📤 Mengirim data prospect ke API...");
      print("📝 Data yang dikirim: ${jsonEncode(prospectData)}");

      final headersProspect = await getHeadersProspect(username);
      
      if (headersProspect['api_key'] == null || headersProspect['api_key']!.isEmpty) {
        print("❌ API Key tidak ditemukan!");
        return {"success": false, "message": "API Key tidak ditemukan"};
      }

      final response = await http.post(
        Uri.parse(apiProspectUrl),
        headers: headersProspect,
        body: jsonEncode(prospectData),
      );

      if (response.statusCode != 200) {
        print("❌ Gagal mengirim data prospect! Status: ${response.statusCode}");
        return {
          "success": false,
          "message": "Gagal mengirim data prospect",
          "status_code": response.statusCode,
          "response_body": response.body,
        };
      }

      final responseData = jsonDecode(response.body);
      String? reportId = responseData['id'];

      if (reportId == null) {
        print("❌ Gagal mendapatkan Report ID dari API Prospect.");
        return {"success": false, "message": "Gagal mendapatkan Report ID"};
      }

      print("✅ Data prospect berhasil dikirim, Report ID: $reportId");

      Map<String, String> kunjunganData = {
        'nama_prospect': reportId,
        'tanggal_kunjungan': prospectData['tanggal_kunjungan'],
        'marketing': prospectData['marketing'],
        'lokasi_kunjungan': prospectData['lokasi_kunjungan'],
        'tipe_kunjungan': prospectData['tipe_kunjungan'],
      };
      
      kunjunganData['nama_prospect'] = reportId;

      print("📤 Mengirim data kunjungan ke API...");
      print("📝 Data yang dikirim: $kunjunganData");

      var request = http.MultipartRequest("POST", Uri.parse(apiKunjunganUrl))
        ..headers.addAll(await getHeadersKunjungan(username))
        ..fields.addAll(kunjunganData);

      if (imageFile != null) {
        File? compressedImage = await compressImage(imageFile);
        if (compressedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath('foto_kunjungan', compressedImage.path),
          );
          print("📷 Foto dari perangkat berhasil ditambahkan.");
        } else {
          print("⚠️ Gagal mengompresi atau membaca gambar dari perangkat.");
        }
      } else if (webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto_kunjungan',
            webImage,
            filename: "web_uploaded.jpg",
          ),
        );
        print("📷 Foto dari web berhasil ditambahkan.");
      } else {
        print("⚠️ Tidak ada foto yang dikirim.");
      }

      final responseKunjungan = await request.send();
      final responseString = await responseKunjungan.stream.bytesToString();

      if (responseKunjungan.statusCode != 200) {
        print("❌ Gagal mengirim data kunjungan!");
        return {
          "success": false,
          "message": "Gagal mengirim data kunjungan",
          "status_code": responseKunjungan.statusCode,
          "response_body": responseString,
        };
      }

      print("✅ Data kunjungan berhasil dikirim.");
      return jsonDecode(responseString);

    } catch (e) {
      print("❌ Terjadi error: $e");
      return {"success": false, "message": "Terjadi error", "error_detail": e.toString()};
    }
  }

}
