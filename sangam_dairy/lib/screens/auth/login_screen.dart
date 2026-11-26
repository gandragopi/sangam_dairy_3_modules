import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_screen.dart';
import '../../services/auth_api_service.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFEAF6EE);
  static const Color cream = Color(0xFFFFFCF5);
  static const Color orange = Color(0xFFFFAA16);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _mobileController =
  TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();

  final FocusNode _passwordFocusNode = FocusNode();

  final FocusNode _mobileFocusNode = FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  int _loginMode = 0; // 0 = Email & Password, 1 = Mobile & OTP

  bool _obscurePassword = true;

  bool _isLoading = false;

  bool _isGoogleLoading = false;

  bool _isAppleLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN (EMAIL & OTP)
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final String email = _emailController.text.trim();
    if (email.isEmpty) { _showMessage('Please enter your email address.'); _emailFocusNode.requestFocus(); return; }
    if (!_isValidEmail(email)) { _showMessage('Please enter a valid email address.'); _emailFocusNode.requestFocus(); return; }

    setState(() => _isLoading = true);
    try {
      await AuthApiService.requestEmailOtp(email);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OtpScreen(email: email)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // LOGIN WITH MOBILE & PASSWORD (STRICT VALIDATION)
  // ============================================================

  Future<void> _loginWithMobilePassword() async {
    FocusScope.of(context).unfocus();
    final String mobile = _mobileController.text.trim();
    final String password = _passwordController.text;

    if (mobile.isEmpty) {
      _showMessage('Please enter your mobile number.');
      _mobileFocusNode.requestFocus();
      return;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      _showMessage('Please enter a valid 10-digit mobile number.');
      _mobileFocusNode.requestFocus();
      return;
    }
    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Fixed default test credentials or registered credentials
      final savedMobile = prefs.getString('sangam_signup_mobile') ?? '9390736087';
      final savedPassword = prefs.getString('sangam_signup_password') ?? 'Gandra@2003';

      // Strict check: must match fixed/registered mobile and password
      if (mobile != savedMobile || password != savedPassword) {
        throw Exception('Invalid mobile number or password. Please check your credentials.');
      }

      await prefs.setBool('sangam_is_logged_in', true);
      await prefs.setString('sangam_customer_mobile', mobile);

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return emailRegex.hasMatch(email);
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    final String email =
    _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Enter your email address first.',
      );

      _emailFocusNode.requestFocus();

      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(
        'Please enter a valid email address.',
      );

      _emailFocusNode.requestFocus();

      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.lock_reset_rounded,
                color: primaryGreen,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'Forgot Password',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: const Text(
            'Password reset is currently available in local '
                'demo mode. Email/SMTP service can be connected '
                'later when the backend is added.',
            style: TextStyle(
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _googleLogin() async {
    if (_isLoading ||
        _isGoogleLoading ||
        _isAppleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _isGoogleLoading = false;
    });

    _showMessage(
      'Google login will be connected later.',
    );
  }

  // ============================================================
  // APPLE LOGIN
  // ============================================================

  Future<void> _appleLogin() async {
    if (_isLoading ||
        _isGoogleLoading ||
        _isAppleLoading) {
      return;
    }

    setState(() {
      _isAppleLoading = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _isAppleLoading = false;
    });

    _showMessage(
      'Apple login will be connected later.',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
          success ? primaryGreen : darkGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  void _openSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  void _showTerms() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'By using Sangam Dairy, you agree to use the '
                  'application responsibly and provide accurate '
                  'account information.\n\n'
                  'Product availability, prices and delivery '
                  'times may change from time to time.\n\n'
                  'Please review all information before placing '
                  'an order.',
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  void _showPrivacy() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Sangam Dairy respects your privacy.\n\n'
                  'Your information is used only for providing '
                  'the application experience.\n\n'
                  'Your password is not displayed to other users.',
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >= 900;

            if (isDesktop) {
              return _buildDesktopLayout();
            }

            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 1100,
        height: 720,
        margin: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 35,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 47,
              child: _buildBrandPanel(),
            ),
            Expanded(
              flex: 53,
              child: _buildLoginPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BRAND PANEL
  // ============================================================

  Widget _buildBrandPanel() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/sangam_farm.png',
          fit: BoxFit.cover,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            return Container(
              color: darkGreen,
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                darkGreen.withValues(alpha: 0.28),
                darkGreen.withValues(alpha: 0.48),
                Colors.black.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            38,
            38,
            38,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildBrandLogo(
                light: true,
                size: 82,
              ),
              const Spacer(),
              const Text(
                'Pure Dairy.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Every Day.',
                style: TextStyle(
                  color: orange,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 390,
                child: Text(
                  'Fresh and trusted dairy products '
                      'delivered with care to your doorstep.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildTrustCard(),
              const SizedBox(height: 25),
              const Text(
                '© 2026 Sangam Dairy. All rights reserved.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRUST CARD
  // ============================================================

  Widget _buildTrustCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.eco_rounded,
              title: '100% Fresh',
              subtitle: 'Farm Fresh',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_rounded,
              title: 'Trusted',
              subtitle: 'Hygienic & Safe',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.favorite_rounded,
              title: 'Pure & Natural',
              subtitle: 'Goodness Inside',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN MODE SELECTOR & FORM CONTENT
  // ============================================================

  Widget _buildLoginModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _loginMode = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginMode == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _loginMode == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Email & OTP',
                    style: TextStyle(
                      color: _loginMode == 0 ? primaryGreen : Colors.black54,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _loginMode = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginMode == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _loginMode == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Mobile & Password',
                    style: TextStyle(
                      color: _loginMode == 1 ? primaryGreen : Colors.black54,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileField() {
    return TextField(
      controller: _mobileController,
      focusNode: _mobileFocusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
      onSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Enter 10-digit mobile number',
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_android_rounded,
                color: primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                '+91',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 20,
                color: const Color(0xFFDDE8E0),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        _buildLoginModeSelector(),
        const SizedBox(height: 24),
        if (_loginMode == 0) ...[
          _buildFieldLabel('Email address'),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 12),
          const Text(
            'We will send a one-time code to your email address.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
        ] else ...[
          _buildFieldLabel('Mobile number'),
          const SizedBox(height: 8),
          _buildMobileField(),
          const SizedBox(height: 16),
          _buildFieldLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildLoginButton(),
      ],
    );
  }

  // ============================================================
  // LOGIN PANEL
  // ============================================================

  Widget _buildLoginPanel() {
    return Container(
      color: cream,
      padding: const EdgeInsets.fromLTRB(
        54,
        30,
        54,
        24,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildBrandLogo(
              light: false,
              size: 76,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome back! 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen,
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Login to continue shopping fresh dairy products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            _buildFormContent(),
            const SizedBox(height: 25),
            _buildOrDivider(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildGoogleButton(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildAppleButton(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSignupCard(),
            const SizedBox(height: 16),
            _buildTerms(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildBrandLogo(
              light: false,
              size: 78,
            ),
            const SizedBox(height: 18),
            const Text(
              'Welcome back! 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Login to continue shopping fresh dairy products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            _buildFormContent(),
            const SizedBox(height: 24),
            _buildOrDivider(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildGoogleButton(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAppleButton(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSignupCard(),
            const SizedBox(height: 15),
            _buildTerms(),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BRAND LOGO
  // ============================================================

  Widget _buildBrandLogo({
    required bool light,
    required double size,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: light
                ? Colors.white
                : primaryGreen,
            borderRadius: BorderRadius.circular(18),
            border: light
                ? Border.all(
              color: orange,
              width: 2,
            )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              'assets/images/sangam_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return Icon(
                  Icons.water_drop_rounded,
                  color: light
                      ? primaryGreen
                      : Colors.white,
                  size: size * 0.48,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 18),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'SANGAM',
              style: TextStyle(
                color: light
                    ? Colors.white
                    : darkGreen,
                fontSize: 29,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'D A I R Y',
              style: TextStyle(
                color: light
                    ? Colors.white
                    : primaryGreen,
                fontSize: 13,
                letterSpacing: 4.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'FARM FRESH. PURE ALWAYS.',
              style: TextStyle(
                color: light
                    ? orange
                    : primaryGreen,
                fontSize: 9.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
      decoration: InputDecoration(
        hintText: 'Enter your email',
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.mail_outline_rounded,
          color: primaryGreen,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        _login();
      },
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: primaryGreen,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword =
              !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.black38,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFDDE8E0),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    final bool isMobileMode = _loginMode == 1;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (isMobileMode ? _loginWithMobilePassword : _login),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          primaryGreen.withValues(alpha: 0.55),
          elevation: 4,
          shadowColor:
          primaryGreen.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 23,
          height: 23,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              isMobileMode ? 'Login' : 'Send OTP',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OR DIVIDER
  // ============================================================

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFDDE4DE),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: Colors.black.withValues(
                alpha: 0.45,
              ),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFDDE4DE),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GOOGLE BUTTON
  // ============================================================

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed:
        _isGoogleLoading ? null : _googleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: darkGreen,
          side: const BorderSide(
            color: Color(0xFFD8E4DC),
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryGreen,
          ),
        )
            : const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            GoogleLogo(),
            SizedBox(width: 10),
            Text(
              'Google',
              style: TextStyle(
                color: darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APPLE BUTTON
  // ============================================================

  Widget _buildAppleButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed:
        _isAppleLoading ? null : _appleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: lightGreen,
          foregroundColor: darkGreen,
          side: const BorderSide(
            color: Color(0xFFC9DDD0),
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAppleLoading
            ? const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryGreen,
          ),
        )
            : const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              color: Colors.black,
              size: 23,
            ),
            SizedBox(width: 10),
            Text(
              'Apple',
              style: TextStyle(
                color: darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SIGNUP CARD
  // ============================================================

  Widget _buildSignupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        17,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD3E7D9),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'New to Sangam?',
            style: TextStyle(
              color: darkGreen,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Create an account to start your fresh dairy journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _openSignup,
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 19,
                color: primaryGreen,
              ),
              label: const Text(
                'Sign Up',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFD5E5DA),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text(
          'By continuing, you agree to our ',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 11.5,
          ),
        ),
        GestureDetector(
          onTap: _showTerms,
          child: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Text(
          ' and ',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 11.5,
          ),
        ),
        GestureDetector(
          onTap: _showPrivacy,
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TRUST ITEM
// ============================================================

class _TrustItem extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.15,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// GOOGLE LOGO
// ============================================================

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

// ============================================================
// GOOGLE LOGO PAINTER
// ============================================================

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final double w = size.width;

    final double h = size.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromLTWH(
      w * 0.10,
      h * 0.10,
      w * 0.80,
      h * 0.80,
    );

    // BLUE

    paint.color = const Color(0xFF4285F4);

    canvas.drawArc(
      rect,
      -0.20,
      1.55,
      false,
      paint,
    );

    // RED

    paint.color = const Color(0xFFEA4335);

    canvas.drawArc(
      rect,
      -2.95,
      1.65,
      false,
      paint,
    );

    // YELLOW

    paint.color = const Color(0xFFFBBC05);

    canvas.drawArc(
      rect,
      2.30,
      1.05,
      false,
      paint,
    );

    // GREEN

    paint.color = const Color(0xFF34A853);

    canvas.drawArc(
      rect,
      1.15,
      1.20,
      false,
      paint,
    );

    // BLUE HORIZONTAL BAR

    paint.color = const Color(0xFF4285F4);

    paint.style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        w * 0.48,
        h * 0.43,
        w * 0.38,
        h * 0.18,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}
