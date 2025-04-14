import 'package:flutter/material.dart';
import 'package:armor_internal/logic/auth_service.dart';
import 'package:armor_internal/ui/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _secureText = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = "v${info.version}";
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      // Mengambil hasil login dari AuthService
      final result = await AuthService().login(username, password);

      // Cek jika login berhasil
      if (result['success']) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('user', json.encode(result['user']));  // Menyimpan data user
        localStorage.setString('user_id', result['user']['id']);       // Menyimpan user_id
        localStorage.setString('token', result['token'] ?? '');        // Menyimpan token jika ada

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showMsg(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showMsg("An error occurred, please check your internet connection.");
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: "Username",
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Please enter username' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _secureText,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    prefixIcon: Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: _togglePasswordVisibility,
                                      icon: Icon(_secureText
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Please enter password' : null,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text("Forgot password?"),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    ),
                                    child: Text(
                                      _isLoading ? 'Processing...' : 'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _appVersion,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}