import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', name: "home", builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/login', name: "login", builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: "signup", builder: (context, state) => const SignupScreen()),
      // GoRoute(path: '/profile', name: "profile", builder: (context, state) => ProfileScreen()),
    ],
  );
}
