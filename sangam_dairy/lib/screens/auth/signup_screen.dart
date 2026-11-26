import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart';

// ============================================================
// GLOBAL COLORS
// ============================================================

const Color primaryGreen = Color(0xFF087A35);
const Color darkGreen = Color(0xFF173B20);
const Color lightGreen = Color(0xFFE8F5E9);
const Color cream = Color(0xFFFFFCF5);
const Color orange = Color(0xFFFFA916);
const Color textGrey = Color(0xFF69736B);

// ============================================================
// SIGNUP SCREEN
// ============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// ============================================================
// SIGNUP STATE
// ============================================================

class _SignupScreenState extends State<SignupScreen> {
  // ============================================================
  // LOGO
  // ============================================================

  static const String sangamLogo =
      'assets/images/sangam_logo.png';

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _mobileController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  // ============================================================
  // FOCUS NODES
  // ============================================================

  final FocusNode _nameFocusNode = FocusNode();

  final FocusNode _emailFocusNode = FocusNode();

  final FocusNode _mobileFocusNode = FocusNode();

  final FocusNode _passwordFocusNode = FocusNode();

  // ============================================================
  // STATE
  // ============================================================

  bool _obscurePassword = true;

  bool _isLoading = false;

  bool _acceptedTerms = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_onPasswordChanged);
  }

  // ============================================================
  // PASSWORD LISTENER
  // ============================================================

  void _onPasswordChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  int get _passwordStrength {
    final String password = _passwordController.text;

    if (password.isEmpty) {
      return 0;
    }

    int score = 0;

    if (password.length >= 8) {
      score++;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }

    if (RegExp(
      r'''[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];`~]''',
    ).hasMatch(password)) {
      score++;
    }

    return score;
  }

  // ============================================================
  // PASSWORD STRENGTH TEXT
  // ============================================================

  String get _passwordStrengthText {
    switch (_passwordStrength) {
      case 1:
      case 2:
        return 'Weak';

      case 3:
      case 4:
        return 'Medium';

      case 5:
        return 'Strong';

      default:
        return '';
    }
  }

  // ============================================================
  // PASSWORD STRENGTH COLOR
  // ============================================================

  Color get _passwordStrengthColor {
    switch (_passwordStrength) {
      case 1:
      case 2:
        return Colors.redAccent;

      case 3:
      case 4:
        return orange;

      case 5:
        return primaryGreen;

      default:
        return Colors.transparent;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);

    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
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
  // SIGNUP
  // ============================================================

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    final String name = _nameController.text.trim();

    final String email = _emailController.text.trim();

    final String mobile = _mobileController.text.trim();

    final String password = _passwordController.text;

    // ------------------------------------------------------------
    // NAME VALIDATION
    // ------------------------------------------------------------

    if (name.isEmpty) {
      _showMessage(
        'Please enter your full name.',
      );

      _nameFocusNode.requestFocus();

      return;
    }

    // ------------------------------------------------------------
    // EMAIL VALIDATION
    // ------------------------------------------------------------

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email address.',
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

    // ------------------------------------------------------------
    // MOBILE VALIDATION
    // ------------------------------------------------------------

    if (mobile.isEmpty) {
      _showMessage(
        'Please enter your mobile number.',
      );

      _mobileFocusNode.requestFocus();

      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
      );

      _mobileFocusNode.requestFocus();

      return;
    }

    // ------------------------------------------------------------
    // PASSWORD VALIDATION
    // ------------------------------------------------------------

    if (password.isEmpty) {
      _showMessage(
        'Please create a password.',
      );

      _passwordFocusNode.requestFocus();

      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must contain at least 6 characters.',
      );

      _passwordFocusNode.requestFocus();

      return;
    }

    // ------------------------------------------------------------
    // TERMS VALIDATION
    // ------------------------------------------------------------

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms & Conditions to continue.',
      );

      return;
    }

    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    setState(() {
      _isLoading = true;
    });

    // ------------------------------------------------------------
    // SAVE ACCOUNT LOCALLY
    // ------------------------------------------------------------

    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        'sangam_signup_name',
        name,
      );

      await prefs.setString(
        'sangam_signup_email',
        email,
      );

      await prefs.setString(
        'sangam_signup_mobile',
        mobile,
      );

      await prefs.setString(
        'sangam_signup_password',
        password,
      );

      await prefs.setBool(
        'sangam_account_created',
        true,
      );

      await prefs.setString(
        'sangam_customer_mobile',
        mobile,
      );

      await prefs.setBool(
        'sangam_profile_completed',
        false,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Account created successfully!',
        success: true,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to create account. Please try again.',
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) {
      return;
    }

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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              BuildContext context,
              BoxConstraints constraints,
              ) {
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
  // DESKTOP LAYOUT
  // ============================================================

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 1180,
          constraints: const BoxConstraints(
            minHeight: 700,
          ),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 35,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              42,
              30,
              42,
              36,
            ),
            child: _buildDesktopContent(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP CONTENT
  // ============================================================

  Widget _buildDesktopContent() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Center(
          child: _buildLogo(
            size: 92,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Create your account',
          style: TextStyle(
            color: darkGreen,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Join Sangam Dairy and enjoy fresh products every day.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 28),

        _buildNameField(),

        const SizedBox(height: 20),

        _buildEmailField(),

        const SizedBox(height: 20),

        _buildMobileField(),

        const SizedBox(height: 20),

        _buildPasswordField(),

        const SizedBox(height: 10),

        _buildPasswordStrength(),

        const SizedBox(height: 22),

        _buildTerms(),

        const SizedBox(height: 20),

        _buildSignupButton(),

        const SizedBox(height: 18),

        _buildBackToLogin(),

        const SizedBox(height: 30),

        _buildTrustRow(),
      ],
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        28,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: _buildLogo(
              size: 82,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Create your account',
            style: TextStyle(
              color: darkGreen,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Join Sangam Dairy and enjoy fresh products every day.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          _buildNameField(),

          const SizedBox(height: 18),

          _buildEmailField(),

          const SizedBox(height: 18),

          _buildMobileField(),

          const SizedBox(height: 18),

          _buildPasswordField(),

          const SizedBox(height: 10),

          _buildPasswordStrength(),

          const SizedBox(height: 22),

          _buildTerms(),

          const SizedBox(height: 20),

          _buildSignupButton(),

          const SizedBox(height: 18),

          _buildBackToLogin(),

          const SizedBox(height: 28),

          _buildTrustRow(),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo({
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD8E9DD),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(
              alpha: 0.10,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.asset(
          sangamLogo,
          fit: BoxFit.contain,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            return Container(
              color: lightGreen,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: primaryGreen,
                size: 38,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // NAME FIELD
  // ============================================================

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      label: 'Full name',
      hint: 'Enter your full name',
      icon: Icons.person_outline_rounded,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) {
        _emailFocusNode.requestFocus();
      },
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      label: 'Email address',
      hint: 'Enter your email address',
      icon: Icons.mail_outline_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) {
        _mobileFocusNode.requestFocus();
      },
    );
  }

  // ============================================================
  // MOBILE FIELD
  // ============================================================

  Widget _buildMobileField() {
    return _buildTextField(
      controller: _mobileController,
      focusNode: _mobileFocusNode,
      label: 'Mobile number',
      hint: 'Enter mobile number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
      prefixText: '+91',
      onSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField() {
    final bool hasPassword =
        _passwordController.text.isNotEmpty;

    return _buildTextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      label: 'Password',
      hint: 'Create a password',
      icon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      focused: hasPassword,
      suffixIcon: IconButton(
        tooltip: _obscurePassword
            ? 'Show password'
            : 'Hide password',
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
          color: Colors.grey.shade500,
          size: 23,
        ),
      ),
    );
  }

  // ============================================================
  // COMMON TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    String? prefixText,
    int? maxLength,
    bool focused = false,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: focused
                  ? primaryGreen
                  : const Color(0xFFE0E7E1),
              width: focused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 17),

              Icon(
                icon,
                color: primaryGreen,
                size: 23,
              ),

              const SizedBox(width: 14),

              if (prefixText != null) ...[
                Text(
                  prefixText,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Container(
                  height: 32,
                  width: 1,
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  color:
                  const Color(0xFFE2E7E3),
                ),
              ],

              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  maxLength: maxLength,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                    const TextStyle(
                      color: Color(0xFFB8BDBA),
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isCollapsed: true,
                  ),
                ),
              ),

              ?suffixIcon,
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  Widget _buildPasswordStrength() {
    final int strength = _passwordStrength;

    if (strength == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: List.generate(
              5,
                  (int index) {
                final bool filled =
                    index < strength;

                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      right:
                      index == 4 ? 0 : 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color: filled
                          ? _passwordStrengthColor
                          : const Color(
                        0xFFE1E5E2,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 14),

        AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: _passwordStrengthColor
                .withValues(alpha: 0.10),
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: Text(
            _passwordStrengthText,
            style: TextStyle(
              color: _passwordStrengthColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: primaryGreen,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(5),
            ),
            onChanged: (bool? value) {
              setState(() {
                _acceptedTerms =
                    value ?? false;
              });
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Wrap(
            children: [
              const Text(
                'By continuing, you agree to our ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              GestureDetector(
                onTap: _showTerms,
                child: const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),

              const Text(
                ' and ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              GestureDetector(
                onTap: _showPrivacy,
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SIGNUP BUTTON
  // ============================================================

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
        _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          disabledBackgroundColor:
          primaryGreen.withValues(
            alpha: 0.55,
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 23,
          height: 23,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .person_add_alt_1_rounded,
              size: 21,
            ),
            SizedBox(width: 9),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  Widget _buildBackToLogin() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRUST ROW
  // ============================================================

  Widget _buildTrustRow() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD6E8DC),
        ),
      ),
      child: Wrap(
        alignment:
        WrapAlignment.spaceEvenly,
        runSpacing: 14,
        children: const [
          _TrustItem(
            icon: Icons.verified_user_outlined,
            title: 'Trusted',
            subtitle: 'Quality products',
          ),
          _TrustItem(
            icon: Icons.local_shipping_outlined,
            title: 'Fresh Delivery',
            subtitle: 'At your doorstep',
          ),
          _TrustItem(
            icon: Icons.lock_outline_rounded,
            title: 'Secure',
            subtitle: 'Your data stays private',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS DIALOG
  // ============================================================

  void _showTerms() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content:
          const SingleChildScrollView(
            child: Text(
              'By creating an account with Sangam Dairy, '
                  'you agree to provide accurate account information '
                  'and use the application responsibly.\n\n'
                  'Product availability, prices and delivery times '
                  'may change from time to time.\n\n'
                  'Please review your information before placing orders.',
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIVACY DIALOG
  // ============================================================

  void _showPrivacy() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content:
          const SingleChildScrollView(
            child: Text(
              'Sangam Dairy respects your privacy. '
                  'The information provided during account creation '
                  'is used for authentication, shopping and delivery services.\n\n'
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
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// TRUST ITEM
// ================================================================

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
    return SizedBox(
      width: 145,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(
                  0xFFD5E7DB,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 19,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 11.5,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
