import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final storage = FlutterSecureStorage();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await storage.delete(key: 'token');
    context.read<AuthProvider>().setUser(null);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    
    if (user == null) {
      return Center(
        child: GestureDetector(
          onTap: () {
            context.push('/login');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: textColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Login",
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: textColor),
              ),
              child: Icon(
                Icons.person,
                size: 50,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
  onPressed: () {
    if (user.userType == UserType.normal) {
      context.push('/get-ngo-status'); // Navigate to some page
    } else {
      context.push('/ngo'); // Navigate to NGO-related page
    }
  },
  child: Text(
    user.userType == UserType.ngo ? 'Get NGO Status' : 'NGO',
    style: TextStyle(
      fontSize: 16,
      color: textColor.withOpacity(0.7),
    ),
  ),
),

            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                context.push('/my-reports');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report, color: textColor),
                    const SizedBox(width: 8),
                    Text(
                      "My Reports",
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}