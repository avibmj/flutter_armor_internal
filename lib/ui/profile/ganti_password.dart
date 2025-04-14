import 'package:armor_internal/logic/ganti_password.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GantiPassword extends StatefulWidget {
  const GantiPassword({super.key});

  @override
  State<GantiPassword> createState() => _GantiPasswordState();
}

class _GantiPasswordState extends State<GantiPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final passwordService = GantiPasswordService();
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final oldPassword = _oldPasswordController.text;
      final newPassword = _newPasswordController.text;

      // Panggilan ke GantiPasswordService
      final result = await GantiPasswordService().updatePassword(
        username: username,
        inputOldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result == null) {
        // Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diganti!')),
        );
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        // Gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildPasswordField(
                label: 'Password Lama',
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                toggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Password Baru',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                toggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Konfirmasi Password Baru',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Konfirmasi password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggle,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }
}
