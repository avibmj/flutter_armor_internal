import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = "https://armor.on.joget.cloud/jw/api/list/list_app001_frm003";
  final Map<String, String> _headers = {
    'api_id': 'API-9bfb0dc3-5f97-4bfd-b898-03996499babd',
    'api_key': 'faff05096e6d46c78192bd67e9b77260',
    'token': 'd8d5474826665fede1527f18dc62219ed016428bf54184ffd20a6d5a824d28ce',
  };

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse("$_baseUrl?d-4723718-fn_username=$username");

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['data'] != null && body['data'].isNotEmpty) {
          final user = body['data'].firstWhere(
            (u) => u['username'] == username && u['password'] == password,
            orElse: () => null,
          );

          if (user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_id', user['id']);
            await prefs.setString('username', user['username']);
            await prefs.setString('nama_karyawan', user['nama_karyawan'] ?? '');
            await prefs.setString('user_group', user['user_group'] ?? '');
            await prefs.setString('initial', user['initial'] ?? '');
            await prefs.setString('isFundingActivityReportApps', user['IsFundingActivityReportApps']?.toString() ?? '0');

            return {
              'success': true,
              'user': user,
              'message': 'Login berhasil'
            };
          }
        } else {
          return {
            'success': false,
            'message': 'User tidak ditemukan'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Gagal menghubungi server (${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e'
      };
    }

    // Tambahkan ini sebagai fallback terakhir
    return {
      'success': false,
      'message': 'Terjadi kesalahan yang tidak diketahui'
    };
  }

}
