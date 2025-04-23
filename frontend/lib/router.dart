import 'package:frontend/layout.dart';
import 'package:frontend/screens/add_a_report.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', name: "home", builder: (context, state) => const Layout()),
      GoRoute(path: '/reports', name: "homescreen", builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', name: "login", builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: "signup", builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/profile', name: "profile", builder: (context, state) => ProfileScreen()),
      GoRoute(path: '/report/add',name: "add report",builder: (context,state)=> AddReportScreen())
    ],
  );
}
