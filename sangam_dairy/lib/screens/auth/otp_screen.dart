import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_api_service.dart';
import '../customer/customer_details_screen.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;

  const OtpScreen({
    super.key,
    this.phoneNumber,
    this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF064D25);
  static const Color orange = Color(0xFFFFA91F);
  static const Color cream = Color(0xFFFCFAF2);
  static const Color softGreen = Color(0xFFEAF5E9);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _otpController =
  TextEditingController();

  // ============================================================
  // TIMER
  // ============================================================

  Timer? _timer;

  int _secondsRemaining = 60;

  bool _canResend = false;
  bool _isVerifying = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // ============================================================
  // START TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          setState(() {
            _canResend = true;
          });

          timer.cancel();
        }
      },
    );
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text.trim();
    final String email = widget.email?.trim() ?? '';
    if (email.isEmpty) { _showMessage('Email address is missing. Please go back and try again.'); return; }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) { _showMessage('Please enter the 6-digit OTP.'); return; }
    setState(() => _isVerifying = true);
    try {
      await AuthApiService.verifyEmailOtp(email: email, otp: otp);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sangam_verified_email', email);
      await prefs.setBool('sangam_email_verified', true);
      if (!mounted) return;
      _timer?.cancel();
      final bool profileCompleted = prefs.getBool('sangam_profile_completed') ?? false;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => profileCompleted ? const HomeScreen() : const CustomerDetailsScreen()),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    final String email = widget.email?.trim() ?? '';
    if (email.isEmpty) { _showMessage('Email address is missing.'); return; }
    try {
      await AuthApiService.requestEmailOtp(email);
      if (!mounted) return;
      _otpController.clear();
      _startTimer();
      _showMessage('A new OTP has been sent to your email.');
    } catch (error) {
      if (mounted) _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
      ),
    );
  }

  // ============================================================
  // DISPLAY ADDRESS
  // ============================================================

  String get _displayAddress {
    if (widget.email != null && widget.email!.isNotEmpty) {
      return widget.email!;
    }

    if (widget.phoneNumber != null &&
        widget.phoneNumber!.isNotEmpty) {
      return widget.phoneNumber!;
    }

    return '';
  }

  String get _loginType {
    if (widget.email != null && widget.email!.isNotEmpty) {
      return 'email';
    }

    return 'mobile number';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================================
                // BACK BUTTON
                // ======================================================

                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 46,
                      height: 46,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                // ======================================================
                // ICON
                // ======================================================

                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.email != null
                          ? Icons.mark_email_read_rounded
                          : Icons.sms_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ======================================================
                // TITLE
                // ======================================================

                const Center(
                  child: Text(
                    'Verify your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Enter the 6-digit code sent to your $_loginType',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ======================================================
                // EMAIL / PHONE
                // ======================================================

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.email != null
                              ? Icons.email_outlined
                              : Icons.phone_outlined,
                          color: primaryGreen,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            _displayAddress,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: darkGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // ======================================================
                // OTP LABEL
                // ======================================================

                const Text(
                  'Verification code',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                // ======================================================
                // OTP FIELD
                // ======================================================

                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: primaryGreen,
                      width: 1.3,
                    ),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 9,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '• • • • • •',
                      hintStyle: TextStyle(
                        color: Colors.black26,
                        fontSize: 20,
                        letterSpacing: 5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ======================================================
                // VERIFY BUTTON
                // ======================================================

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: orange.withValues(
                        alpha: 0.25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ======================================================
                // RESEND
                // ======================================================

                Center(
                  child: _canResend
                      ? TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                      : Text(
                    'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // ======================================================
                // SECURITY CARD
                // ======================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: primaryGreen,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Never share your verification code with anyone.',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 45),

                // ======================================================
                // FOOTER
                // ======================================================

                const Center(
                  child: Text(
                    'S A N G A M   D A I R Y',
                    style: TextStyle(
                      color: Color(0xFFB5B5AE),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
