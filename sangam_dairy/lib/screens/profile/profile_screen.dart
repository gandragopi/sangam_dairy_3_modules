import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../support/help_support_screen.dart';
import '../wallet/wallet_screen.dart';
import '../referral/referral_screen.dart';
import '../rewards/rewards_coupons_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);

  // ============================================================
  // CUSTOMER DETAILS
  // ============================================================

  static const String customerName = 'Gopi Gandra';

  String _mobile = '';
  String _address = '';
  String _city = '';
  String _pincode = '';

  bool _loading = true;

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

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _mobile = prefs.getString('sangam_customer_mobile') ?? '';
      _address = prefs.getString('sangam_customer_address') ?? '';
      _city = prefs.getString('sangam_customer_city') ?? '';
      _pincode = prefs.getString('sangam_customer_pincode') ?? '';
      _loading = false;
    });
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile({
    required String mobile,
    required String address,
    required String city,
    required String pincode,
  }) async {
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

    if (!mounted) return;

    setState(() {
      _mobile = mobile;
      _address = address;
      _city = city;
      _pincode = pincode;
    });
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _showEditProfileDialog() async {
    _mobileController.text = _mobile;
    _addressController.text = _address;
    _cityController.text = _city;
    _pincodeController.text = _pincode;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: darkGreen,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Update your delivery details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // NAME
                  // ==================================================

                  _buildInputField(
                    controller: TextEditingController(
                      text: customerName,
                    ),
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                    enabled: false,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // MOBILE
                  // ==================================================

                  _buildInputField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // ADDRESS
                  // ==================================================

                  _buildInputField(
                    controller: _addressController,
                    label: 'Delivery Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // CITY + PINCODE
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _pincodeController,
                          label: 'Pincode',
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SAVE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: () async {
                          final mobile =
                          _mobileController.text.trim();

                          final address =
                          _addressController.text.trim();

                          final city =
                          _cityController.text.trim();

                          final pincode =
                          _pincodeController.text.trim();

                          if (mobile.isNotEmpty &&
                              !RegExp(r'^[0-9]{10}$')
                                  .hasMatch(mobile)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid 10-digit mobile number.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (pincode.isNotEmpty &&
                              !RegExp(r'^[0-9]{6}$')
                                  .hasMatch(pincode)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid 6-digit pincode.',
                                ),
                              ),
                            );
                            return;
                          }

                          await _saveProfile(
                            mobile: mobile,
                            address: address,
                            city: city,
                            pincode: pincode,
                          );

                          if (!dialogContext.mounted) return;

                          Navigator.of(dialogContext).pop();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile updated successfully.',
                              ),
                              backgroundColor: primaryGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkGreen,
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
        fillColor: enabled
            ? const Color(0xFFF8FAF8)
            : const Color(0xFFF0F2F0),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E7E2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E7E2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E7E2),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADDRESS TEXT
  // ============================================================

  String get _fullAddress {
    final parts = <String>[];

    if (_address.trim().isNotEmpty) {
      parts.add(_address.trim());
    }

    if (_city.trim().isNotEmpty) {
      parts.add(_city.trim());
    }

    if (_pincode.trim().isNotEmpty) {
      parts.add(_pincode.trim());
    }

    if (parts.isEmpty) {
      return 'Add your delivery address';
    }

    return parts.join(', ');
  }

  // ============================================================
  // ACCOUNT ITEM
  // ============================================================

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: primaryGreen,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade500,
                    size: 25,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 85),
            child: Divider(
              height: 1,
              color: Color(0xFFE4E9E5),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: darkGreen,
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'About Sangam Dairy',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: darkGreen,
            ),
          ),
          content: const Text(
            'Sangam Dairy provides quality milk, dairy products, sweets, drinks and other food products.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: darkGreen,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            90,
            30,
            28,
            30,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
          child: Row(
            children: [
              // ======================================================
              // LOGO
              // ======================================================

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

              const SizedBox(width: 18),

              // ======================================================
              // USER DETAILS
              // ======================================================

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      customerName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // EDIT PROFILE
              // ======================================================

              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: _showEditProfileDialog,
                  tooltip: 'Edit Profile',
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ============================================================
        // BACK BUTTON
        // ============================================================

        Positioned(
          left: 18,
          top: 18,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.white.withValues(alpha: 0.20),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DELIVERY ADDRESS
  // ============================================================

  Widget _buildDeliveryAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: primaryGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fullAddress,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_mobile.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _mobile,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // ==========================================================
          // CHANGE
          // ==========================================================

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: _showEditProfileDialog,
              child: const Text(
                'Change',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      body: Stack(
        children: [
          // ============================================================
          // EXISTING PROFILE SCREEN
          // ============================================================

          SafeArea(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop =
                    constraints.maxWidth >= 900;

                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                        isDesktop ? 1180 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // PROFILE HEADER
                          // ==================================================

                          _buildProfileHeader(),

                          // ==================================================
                          // CONTENT
                          // ==================================================

                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 0 : 16,
                              22,
                              isDesktop ? 0 : 16,
                              35,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // ==================================================
                                // DELIVERY ADDRESS
                                // ==================================================

                                _buildDeliveryAddress(),

                                const SizedBox(height: 32),

                                // ==================================================
                                // MY ACCOUNT
                                // ==================================================

                                _buildSectionTitle(
                                  'My Account',
                                ),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE0E7E1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // ==========================================
                                      // MY ORDERS
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .receipt_long_outlined,
                                        title: 'My Orders',
                                        subtitle:
                                        'View and track your orders',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const OrdersScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // WISHLIST
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .favorite_border_rounded,
                                        title: 'Wishlist',
                                        subtitle:
                                        'Your saved favourite products',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const WishlistScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // WALLET
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        title: 'Wallet & Loyalty',
                                        subtitle:
                                        'Manage wallet balance and rewards',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const WalletScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // REWARDS & GIFT CARDS (COMING SOON)
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .card_giftcard_rounded,
                                        title: 'Rewards & Gift Cards',
                                        subtitle:
                                        'Loyalty points & coupons (Coming Soon)',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const RewardsCouponsScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // NOTIFICATIONS
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .notifications_none_rounded,
                                        title: 'Notifications',
                                        subtitle:
                                        'Latest offers and updates',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const NotificationsScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // REFER & EARN
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .card_giftcard_rounded,
                                        title: 'Refer & Earn',
                                        subtitle:
                                        'Invite friends and earn rewards',
                                        showDivider: false,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const ReferralScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ==================================================
                                // SUPPORT
                                // ==================================================

                                _buildSectionTitle(
                                  'Support & Information',
                                ),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE0E7E1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // ==========================================
                                      // ABOUT
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .info_outline_rounded,
                                        title:
                                        'About Sangam Dairy',
                                        subtitle:
                                        'Quality milk and dairy products',
                                        onTap:
                                        _showAboutDialog,
                                      ),

                                      // ==========================================
                                      // HELP & SUPPORT
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons
                                            .help_outline_rounded,
                                        title: 'Help & Support',
                                        subtitle:
                                        'Get help with your orders',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const HelpSupportScreen(),
                                            ),
                                          );
                                        },
                                      ),

                                      // ==========================================
                                      // LOGOUT
                                      // ==========================================

                                      _buildAccountItem(
                                        icon: Icons.logout_rounded,
                                        title: 'Logout',
                                        subtitle:
                                        'Sign out of your account',
                                        showDivider: false,
                                        onTap: _logout,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // ==================================================
                                // APP NAME
                                // ==================================================

                                const Center(
                                  child: Text(
                                    'Sangam Dairy',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // ==================================================
                                // TAGLINE
                                // ==================================================

                                const Center(
                                  child: Text(
                                    'Quality milk. Trusted every day.',
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 11,
                                    ),
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
        ],
      ),
    );
  }
}
