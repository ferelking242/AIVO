import 'package:flutter/material.dart';
import '../sign_in/sign_in_screen.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionTitle("Preferences"),
          _buildSwitchTile(
            title: "Push Notifications",
            subtitle: "Receive push notifications",
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          _buildSwitchTile(
            title: "Email Notifications",
            subtitle: "Receive email updates",
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          _buildSwitchTile(
            title: "Dark Mode",
            subtitle: "Enable dark theme",
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionTitle("Account"),
          _buildSettingsTile(
            title: "Change Password",
            icon: Icons.lock,
            onTap: () {
              // TODO: Implement change password
            },
          ),
          _buildSettingsTile(
            title: "Privacy Policy",
            icon: Icons.privacy_tip,
            onTap: () {
              // TODO: Implement privacy policy
            },
          ),
          _buildSettingsTile(
            title: "Terms & Conditions",
            icon: Icons.description,
            onTap: () {
              // TODO: Implement terms & conditions
            },
          ),
          const SizedBox(height: 16),
          _buildSectionTitle("About"),
          _buildSettingsTile(
            title: "App Version",
            subtitle: "1.0.0",
            icon: Icons.info,
            onTap: () {},
          ),
          _buildSettingsTile(
            title: "Contact Us",
            icon: Icons.email,
            onTap: () {
              // TODO: Implement contact us
            },
          ),
          const SizedBox(height: 16),
          _buildSectionTitle("Authentication"),
          _buildAuthenticationSection(),
        ],
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    final authService = AuthService();
    final isAuthenticated = authService.isAuthenticated();
    
    if (!isAuthenticated) {
      return _buildSettingsTile(
        title: "Sign In",
        icon: Icons.login,
        onTap: () {
          Navigator.pushNamed(context, SignInScreen.routeName);
        },
      );
    } else {
      return Column(
        children: [
          _buildSettingsTile(
            title: "Current User",
            subtitle: authService.getCurrentUserEmail() ?? "Unknown",
            icon: Icons.account_circle,
            onTap: () {},
          ),
          _buildSettingsTile(
            title: "Sign Out",
            icon: Icons.logout,
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Sign Out"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await AuthService().signOut();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Signed out successfully")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign out failed: ${e.toString()}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text("Sign Out"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
