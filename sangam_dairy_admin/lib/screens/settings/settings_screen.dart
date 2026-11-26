import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/product_api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController =
      TextEditingController(text: ProductApiService().baseUrl);
  final _authUrlController =
      TextEditingController(text: AuthService().authApiUrl);

  @override
  void dispose() {
    _apiUrlController.dispose();
    _authUrlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ProductApiService().baseUrl = _apiUrlController.text.trim();
    AuthService().authApiUrl = _authUrlController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backend API settings updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin & System Settings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172D1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure REST API backend endpoints and administrator profile.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Administrator Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: brandGreen,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0] : 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${user?.email} • ${user?.role}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // API Endpoints Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REST API Backend Endpoints',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'Specify Spring Boot / Node.js API endpoints for authentication and products management.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Auth Endpoint
                  TextFormField(
                    controller: _authUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Auth Login Endpoint (POST)',
                      prefixIcon: Icon(Icons.security_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Products Endpoint
                  TextFormField(
                    controller: _apiUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Products API Base URL (GET/POST/PUT/DELETE)',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _saveSettings,
                    style: FilledButton.styleFrom(
                      backgroundColor: brandGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Backend Settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
