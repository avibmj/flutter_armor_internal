import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Username_Data {
  Future<Map<String, dynamic>?> fetchUserData(String username) async {
    String apiUrl =
        "https://armor.on.joget.cloud/jw/api/list/list_app001_frm003?d-4723718-fn_username=$username";

    Map<String, String> headers = {
      'api_id': 'API-9bfb0dc3-5f97-4bfd-b898-03996499babd',
      'api_key': 'faff05096e6d46c78192bd67e9b77260',
      'token': 'd8d5474826665fede1527f18dc62219ed016428bf54184ffd20a6d5a824d28ce',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          Map<String, dynamic> user = data['data'][0];

          // Simpan ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', user['username']);
          await prefs.setString('password', user['password']);
          await prefs.setString('user_id', user['id']);
          await prefs.setString('api_key', user['api_key']);

          print("User Data Saved: ${user['username']}, ${user['password']}, ${user['id']}, ${user['api_key']}");
          return data;
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }
}

class Pekerjaan_Data {
  Future<Map<String, dynamic>?> fetchPekerjaanData(String username) async {
    // Ambil data user untuk mendapatkan api_key
    Username_Data userData = Username_Data();
    Map<String, dynamic>? userResponse = await userData.fetchUserData(username);

    if (userResponse == null || userResponse['data'] == null || userResponse['data'].isEmpty) {
      print("User data tidak ditemukan");
      return null;
    }

    // Ambil API key dari user data
    String apiKey = userResponse['data'][0]['api_key'];

    String apiUrl = "https://armor.on.joget.cloud/jw/api/list/list_app001_frm029";

    Map<String, String> headers = {
      'api_id': 'API-fce100df-cc6e-46a8-a15b-eef24bebc6d6',
      'api_key': apiKey, // Menggunakan api_key dari Username_Data
      'token': '7f25413723fecd4d9711a96f799b97123113b10667a695caa6a1df20a74abd22',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Kembalikan JSON sebagai Map
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }
}

class TipeKunjungan_Data {
  Future<Map<String, dynamic>?> fetchTipeKunjunganData(String username) async {
    // Ambil data user untuk mendapatkan api_key
    Username_Data userData = Username_Data();
    Map<String, dynamic>? userResponse = await userData.fetchUserData(username);

    if (userResponse == null || userResponse['data'] == null || userResponse['data'].isEmpty) {
      print("User data tidak ditemukan");
      return null;
    }

    // Ambil API key dari user data
    String apiKey = userResponse['data'][0]['api_key'];

    String apiUrl = "https://armor.on.joget.cloud/jw/api/list/list_app001_frm030";

    Map<String, String> headers = {
      'api_id': 'API-fce100df-cc6e-46a8-a15b-eef24bebc6d6',
      'api_key': apiKey, // Menggunakan api_key dari Username_Data
      'token': '7f25413723fecd4d9711a96f799b97123113b10667a695caa6a1df20a74abd22',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Kembalikan JSON sebagai Map
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }
}

class Prospect_Data {
  Future<Map<String, dynamic>> fetchProspectData(String username, {String? name, String? date, required String id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? apiKey = prefs.getString('api_key');

    if (userId == null || apiKey == null) {
      print("User ID atau API Key tidak ditemukan");
      return {"data": []};
    }

    // Base URL dengan filter ID user
    String apiUrl = "https://armor.on.joget.cloud/jw/api/list/list_app001_frm028?d-4723729-fn_marketing=$userId";

    if (name == null && date == null) {
      apiUrl += "&d-4723729-fn_tipe_prospect=Prospect";
    }

    if (name != null && name.isNotEmpty) {
      apiUrl += "&d-4723729-fn_nama_prospect=${Uri.encodeComponent(name)}";
    }
    if (date != null && date.isNotEmpty) {
      apiUrl += "&d-4723729-fn_dateCreated=${Uri.encodeComponent(date)}";
    }

    Map<String, String> headers = {
      'api_id': 'API-731e7897-0f41-41ea-988a-ff53eca0ef7b',
      'api_key': apiKey,
      'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData.containsKey("data") ? jsonData : {"data": []};
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return {"data": []};
  }

}

class Id_Prospect_Data {
  Future<Map<String, dynamic>> fetchProspectData(String username, String prospectId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? apiKey = prefs.getString('api_key');

    if (userId == null || apiKey == null) {
      print("User ID atau API Key tidak ditemukan");
      return {"data": []};
    }

    // Gunakan prospectId dalam URL
    String apiUrl = "https://armor.on.joget.cloud/jw/api/form/app001_frm028/$prospectId";

    Map<String, String> headers = {
      'api_id': 'API-731e7897-0f41-41ea-988a-ff53eca0ef7b',
      'api_key': apiKey,
      'token': '284953b07a89062f3b54a2376f45359fba189f5b76bbe5bb81d6fb982f091152',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData.containsKey("data") ? jsonData : {"data": []};
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return {"data": []};
  }
}