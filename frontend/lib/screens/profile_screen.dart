import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final storage = FlutterSecureStorage();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await storage.delete(key: 'token');  
    context.read<AuthProvider>().setUser(null);  
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // If user is null, show login page
    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              context.push('/login');
            },
            child: const Text("Login"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('User ID: ${user.id}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
