import 'package:bbtproje/firebase_options.dart';
import 'package:bbtproje/locator.dart';
import 'package:bbtproje/presantation/home/admin_home.dart';
import 'package:bbtproje/presantation/home/user_home.dart';
import 'package:bbtproje/presantation/sign/role_select_page.dart';
import 'package:bbtproje/presantation/sign/sign_in_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  setupLocators();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    // GoRoute(path: '/', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/', builder: (context, state) => const SignInPage()),

    GoRoute(
      path: '/role',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/admin-home',
      builder: (context, state) => const AdminHomePage(),
    ),
    GoRoute(
      path: '/user-home',
      builder: (context, state) => const UserHomePage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'BBT1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
