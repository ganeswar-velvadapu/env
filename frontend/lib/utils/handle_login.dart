import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/providers/auth_provider.dart';
import '../models/user.dart';

final storage = FlutterSecureStorage();

Future<void> handleLoginResponse(Response response, AuthProvider authProvider) async {
  if (response.data['status'] == 'success') {
    final data = response.data['data'];

    // Create User model
    final user = User.fromJson(data);

    // Store token securely
    await storage.write(key: 'token', value: user.token);

    // Update provider
    authProvider.setUser(user);
  } else {
    throw Exception('Login failed: ${response.data['message']}');
  }
}
