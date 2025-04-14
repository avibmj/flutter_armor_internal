import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';
import 'ganti_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String userGroup = '';
  final Color primaryBlue = Colors.blue.shade700;
  final Color lightBlue = Colors.blue.shade100;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user') ?? '{}');

    setState(() {
      name = user['nama_karyawan'] ?? 'Nama Tidak Diketahui';
      userGroup = user['user_group'] ?? 'User Group';
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                SharedPreferences localStorage = await SharedPreferences.getInstance();
                await localStorage.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
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
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: lightBlue,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  userGroup,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // Edit profile action
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: primaryBlue,
                    ),
                  ),
                  child: Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader('Akun'),
              _buildProfileTile(
                icon: Icons.edit,
                title: 'Edit Profil',
                onTap: () {},
              ),
              _buildProfileTile(
                icon: Icons.lock,
                title: 'Ganti Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GantiPassword()),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryBlue,
        ),
        title: Text(title),
        trailing: Icon(Icons.chevron_right, color: primaryBlue),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _confirmLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBlue,
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Log Out'),
      ),
    );
  }
}