import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricAuth = false;

  @override
  Widget build(BuildContext context) {
    // Define blue color scheme
    final Color primaryBlue = Colors.blue.shade700;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionHeader('Preferences', primaryBlue),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  value: _darkMode,
                  iconColor: primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'Notifications',
                  value: _notificationsEnabled,
                  iconColor: primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  value: _biometricAuth,
                  iconColor: primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _biometricAuth = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionHeader('Support', primaryBlue),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'Privacy Policy'),
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & FAQ',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'Help & FAQ'),
                ),
                _buildSettingsTile(
                  icon: Icons.support_agent,
                  title: 'Contact Support',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'Contact Support'),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionHeader('About', primaryBlue),
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'About App',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'About App'),
                ),
                _buildSettingsTile(
                  icon: Icons.update,
                  title: 'Check for Updates',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'Check for Updates'),
                ),
                _buildSettingsTile(
                  icon: Icons.star_rate,
                  title: 'Rate App',
                  iconColor: primaryBlue,
                  onTap: () => _navigateTo(context, 'Rate App'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color iconColor,
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
          color: iconColor,
        ),
        title: Text(title),
        trailing: Icon(Icons.chevron_right, color: iconColor),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
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
          color: iconColor,
        ),
        title: Text(title),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: iconColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String title) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text('$title Page'),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}