import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'get_external_data.dart';

class GantiPasswordService {
  final String _apiUrl = "https://armor.on.joget.cloud/jw/api/form/app001_frm003/saveOrUpdate";

  Future<String?> updatePassword({
    required String username,
    required String inputOldPassword,
    required String newPassword,
  }) async {
    // Ambil data user dari Username_Data
    final userData = await Username_Data().fetchUserData(username);

    if (userData == null || userData['data'] == null || userData['data'].isEmpty) {
      return 'Data user tidak ditemukan';
    }

    final user = userData['data'][0];
    final userId = user['id'];
    final savedPassword = user['password'];
    final apiKey = user['api_key'];

    // Validasi password lama
    if (inputOldPassword != savedPassword) {
      return 'Password lama salah';
    }

    // Buat headers seperti di class Pekerjaan_Data
    Map<String, String> headers = {
      'api_id': 'API-9bfb0dc3-5f97-4bfd-b898-03996499babd',
      'api_key': apiKey,
      'token': 'd8d5474826665fede1527f18dc62219ed016428bf54184ffd20a6d5a824d28ce',
      'Content-Type': 'application/json',
    };

    // Buat payload body
    final Map<String, dynamic> body = {
      'id': userId,
      'password': newPassword,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Simpan password baru ke SharedPreferences jika diinginkan
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('password', newPassword);

        return null; // Sukses
      } else {
        return 'Gagal mengganti password: ${response.body}';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}
