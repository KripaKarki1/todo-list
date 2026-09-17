import 'package:flutter/material.dart';
import 'package:ncmt_kripa/providers/auth_provider.dart';
import 'package:ncmt_kripa/providers/theme_providers.dart';
import 'package:ncmt_kripa/screens/login_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleLogout() async {
    try {
      await context.read<AuthenticationProvider>().logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
     final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: AppBar(
          title: Text("Settings"),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _handleLogout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body:ListTile(
        leading: Icon(
          themeProvider.isDarkMode
              ? Icons.dark_mode
              : Icons.light_mode,
        ),

        title: const Text('Dark Mode'),

        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (_) {
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
      ), 
    );
  }
}
