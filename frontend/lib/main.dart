import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _checkToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: FutureBuilder(
        future: _checkToken(),
        builder: (context, snapshot) {
          final initialLocation =
              snapshot.connectionState == ConnectionState.done && snapshot.data != null
                  ? '/'
                  : '/login';

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: createRouter(initialLocation),
          );
        },
      ),
    );
  }
}
