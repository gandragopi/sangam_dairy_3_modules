import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'gandragopigandra123@gmail.com');
  final _passwordController = TextEditingController(text: 'Gandra@2003');

  bool _hidePassword = true;
  bool _loading = false;
  bool _useBackendServer = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await AuthService().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      tryBackendServerFirst: _useBackendServer,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (!result.success) {
      setState(() {
        _errorMessage = result.message;
      });
    } else if (result.message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  void _fillDemoCredentials() {
    _emailController.text = 'gandragopigandra123@gmail.com';
    _passwordController.text = 'Gandra@2003';
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    const deepGreen = Color(0xFF064E2B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 850;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(desktop ? 32 : 18),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2EBE3)),
                    boxShadow: [
                      BoxShadow(
                        color: deepGreen.withValues(alpha: 0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: desktop
                      ? Row(
                          children: [
                            const Expanded(child: _BrandPanel()),
                            Expanded(child: _buildLoginForm(brandGreen)),
                          ],
                        )
                      : Column(
                          children: [
                            const _BrandPanel(compact: true),
                            _buildLoginForm(brandGreen),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(Color brandGreen) {
    final apiUrl = AuthService().authApiUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BACKEND SECURED LOGIN',
                  style: TextStyle(
                    color: brandGreen,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _fillDemoCredentials,
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Fill Admin Credentials', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: brandGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Administrator Sign In',
              style: TextStyle(
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17251B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connects directly to REST API ($apiUrl)',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF6B7A70),
              ),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF8B4B4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Email address',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                hintText: 'Enter admin email',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Email is required';
                if (!email.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                hintText: 'Enter password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Mode Selector Switch
            SwitchListTile(
              title: const Text('Real Backend Server Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                _useBackendServer
                    ? 'Verify via Spring Boot POST $apiUrl'
                    : 'Verify via registered admin credentials',
                style: const TextStyle(fontSize: 11),
              ),
              value: _useBackendServer,
              activeColor: brandGreen,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _useBackendServer = val),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : _signIn,
                style: FilledButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Authenticate & Enter Admin Portal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_clock_outlined, size: 15, color: brandGreen),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Sangam Dairy Secured REST API Auth',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718076),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final bool compact;

  const _BrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 220 : 640),
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 28 : 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A853C), Color(0xFF054526)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            height: 85,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/sangam_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.local_drink_rounded,
                  size: 42,
                  color: brandGreen,
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sangam Dairy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Freshness you trust.\nQuality you deserve.',
            style: TextStyle(
              color: Color(0xFFE2F3E7),
              height: 1.6,
              fontSize: 16,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 48),
            const _FeatureLine(
              icon: Icons.security_rounded,
              text: 'Backend Authentication & Token Security',
            ),
            const SizedBox(height: 18),
            const _FeatureLine(
              icon: Icons.inventory_2_outlined,
              text: 'Real-time Product & Inventory Control',
            ),
            const SizedBox(height: 18),
            const _FeatureLine(
              icon: Icons.shopping_bag_outlined,
              text: 'Order Tracking & Delivery Operations',
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFB9E8C8), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
