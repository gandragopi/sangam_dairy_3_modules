import 'package:flutter/material.dart';
import 'screens/auth/admin_login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/admin_shell.dart';

void main() {
  runApp(const SangamDairyAdminApp());
}

const brandGreen = Color(0xFF087A35);
const deepGreen = Color(0xFF054526);
const pageBackground = Color(0xFFF3F7F4);

class SangamDairyAdminApp extends StatelessWidget {
  const SangamDairyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sangam Dairy Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFCFA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE6DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE6DE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: brandGreen, width: 1.8),
          ),
        ),
      ),
      home: ListenableBuilder(
        listenable: AuthService(),
        builder: (context, child) {
          if (AuthService().isAuthenticated) {
            return const AdminShell();
          }
          return const AdminLoginScreen();
        },
      ),
    );
  }
}
