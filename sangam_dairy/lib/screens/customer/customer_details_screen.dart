import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState
    extends State<CustomerDetailsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);

  // ============================================================
  // CUSTOMER NAME
  // ============================================================

  String _customerName = 'Valued Customer';

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _mobileController =
  TextEditingController();

  final TextEditingController _addressController =
  TextEditingController();

  final TextEditingController _cityController =
  TextEditingController();

  final TextEditingController _pincodeController =
  TextEditingController();

  bool _saving = false;

  // ============================================================
  // INIT & DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('sangam_customer_name') ??
        prefs.getString('sangam_signup_name');
    final mobile = prefs.getString('sangam_customer_mobile') ??
        prefs.getString('sangam_signup_mobile');
    final address = prefs.getString('sangam_customer_address');
    final city = prefs.getString('sangam_customer_city');
    final pincode = prefs.getString('sangam_customer_pincode');

    if (!mounted) return;

    setState(() {
      if (name != null && name.isNotEmpty) {
        _customerName = name;
      }
      if (mobile != null && mobile.isNotEmpty) {
        _mobileController.text = mobile;
      }
      if (address != null) _addressController.text = address;
      if (city != null) _cityController.text = city;
      if (pincode != null) _pincodeController.text = pincode;
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE DETAILS
  // ============================================================

  Future<void> _saveDetails() async {
    final mobile = _mobileController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final pincode = _pincodeController.text.trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    if (address.isEmpty) {
      _showMessage(
        'Please enter your delivery address.',
      );
      return;
    }

    if (city.isEmpty) {
      _showMessage(
        'Please enter your city.',
      );
      return;
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode)) {
      _showMessage(
        'Please enter a valid 6-digit pincode.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    // ------------------------------------------------------------
    // SAVE TO SHARED PREFERENCES
    // ------------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'sangam_customer_mobile',
      mobile,
    );

    await prefs.setString(
      'sangam_customer_address',
      address,
    );

    await prefs.setString(
      'sangam_customer_city',
      city,
    );

    await prefs.setString(
      'sangam_customer_pincode',
      pincode,
    );

    // ------------------------------------------------------------
    // IMPORTANT:
    // CUSTOMER DETAILS COMPLETED
    // ------------------------------------------------------------

    await prefs.setBool(
      'sangam_profile_completed',
      true,
    );

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    // ------------------------------------------------------------
    // GO TO HOME
    // ------------------------------------------------------------

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(
        color: darkGreen,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: primaryGreen,
          size: 21,
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE0E7E1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        30,
        24,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075C2A),
            Color(0xFF087A35),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // LOGO
          // ------------------------------------------------------

          Container(
            width: 82,
            height: 82,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sangam_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons.local_drink_rounded,
                    color: primaryGreen,
                    size: 42,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Welcome to Sangam Dairy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tell us where we should deliver your fresh products.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER CARD
  // ============================================================

  Widget _buildCustomerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: primaryGreen,
                size: 23,
              ),
              SizedBox(width: 9),
              Text(
                'Customer Details',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'Your name is already registered with your account.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // NAME
          // ------------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F0),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE0E7E1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: primaryGreen,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _customerName,
                        style: const TextStyle(
                          color: darkGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.black38,
                  size: 18,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // MOBILE
          // ------------------------------------------------------

          _buildInputField(
            controller: _mobileController,
            label: 'Mobile Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // ADDRESS
          // ------------------------------------------------------

          _buildInputField(
            controller: _addressController,
            label: 'Delivery Address',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // CITY
          // ------------------------------------------------------

          _buildInputField(
            controller: _cityController,
            label: 'City',
            icon: Icons.location_city_outlined,
          ),

          const SizedBox(height: 15),

          // ------------------------------------------------------
          // PINCODE
          // ------------------------------------------------------

          _buildInputField(
            controller: _pincodeController,
            label: 'Pincode',
            icon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),

          const SizedBox(height: 22),

          // ------------------------------------------------------
          // CONTINUE BUTTON
          // ------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                primaryGreen.withValues(alpha: 0.55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    'SAVE & CONTINUE',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BENEFITS
  // ============================================================

  Widget _buildBenefits() {
    return Row(
      children: [
        Expanded(
          child: _buildBenefitItem(
            Icons.local_shipping_outlined,
            'Easy Delivery',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBenefitItem(
            Icons.verified_outlined,
            'Trusted Quality',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBenefitItem(
            Icons.lock_outline_rounded,
            'Secure Details',
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 21,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >= 900;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                    isDesktop ? 760 : 600,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),

                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 0 : 16,
                          24,
                          isDesktop ? 0 : 16,
                          30,
                        ),
                        child: Column(
                          children: [
                            _buildCustomerCard(),

                            const SizedBox(height: 18),

                            _buildBenefits(),

                            const SizedBox(height: 20),

                            const Text(
                              'You only need to enter these details once.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
