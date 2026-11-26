import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/cart_service.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  // ============================================================
  // CUSTOMER
  // ============================================================

  static const String _customerName = 'Gopi Gandra';

  final TextEditingController _mobileController =
  TextEditingController();

  final TextEditingController _addressController =
  TextEditingController();

  final TextEditingController _cityController =
  TextEditingController();

  final TextEditingController _pincodeController =
  TextEditingController();

  bool _loading = true;
  bool _savingDetails = false;

  List<Map<String, dynamic>> _cartItems = [];

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================

  static const String _mobileKey = 'sangam_customer_mobile';
  static const String _addressKey = 'sangam_customer_address';
  static const String _cityKey = 'sangam_customer_city';
  static const String _pincodeKey = 'sangam_customer_pincode';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadCheckoutData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final mobile = prefs.getString(_mobileKey) ?? '';
      final address = prefs.getString(_addressKey) ?? '';
      final city = prefs.getString(_cityKey) ?? '';
      final pincode = prefs.getString(_pincodeKey) ?? '';

      final cart = await CartService.getCart();

      if (!mounted) return;

      setState(() {
        _mobileController.text = mobile;
        _addressController.text = address;
        _cityController.text = city;
        _pincodeController.text = pincode;

        _cartItems = cart;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // SAVE CUSTOMER DETAILS
  // ============================================================

  Future<void> _saveCustomerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _mobileKey,
      _mobileController.text.trim(),
    );

    await prefs.setString(
      _addressKey,
      _addressController.text.trim(),
    );

    await prefs.setString(
      _cityKey,
      _cityController.text.trim(),
    );

    await prefs.setString(
      _pincodeKey,
      _pincodeController.text.trim(),
    );
  }

  // ============================================================
  // CONTINUE TO PAYMENT
  //
  // IMPORTANT:
  // THIS FUNCTION DOES NOT PLACE ORDER.
  // IT ONLY SAVES DETAILS AND OPENS PAYMENT SCREEN.
  // ============================================================

  Future<void> _continueToPayment() async {
    if (_savingDetails) return;

    final mobile = _mobileController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final pincode = _pincodeController.text.trim();

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mobile.isEmpty) {
      _showError('Please enter your mobile number.');
      return;
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      _showError('Please enter a valid 10-digit mobile number.');
      return;
    }

    if (address.isEmpty) {
      _showError('Please enter your delivery address.');
      return;
    }

    if (city.isEmpty) {
      _showError('Please enter your city.');
      return;
    }

    if (pincode.isEmpty) {
      _showError('Please enter your pincode.');
      return;
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode)) {
      _showError('Please enter a valid 6-digit pincode.');
      return;
    }

    setState(() {
      _savingDetails = true;
    });

    try {
      await _saveCustomerDetails();

      if (!mounted) return;

      setState(() {
        _savingDetails = false;
      });

      // ========================================================
      // ONLY NAVIGATION
      // NO ORDER SAVE HERE
      // NO CART CLEAR HERE
      // NO ORDER PLACED DIALOG HERE
      // ========================================================

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            customerName: _customerName,
            mobile: mobile,
            address: address,
            city: city,
            pincode: pincode,
            cartItems: _cartItems,
            subtotal: _subtotal,
            deliveryCharge: _deliveryCharge,
          ),
        ),
      );

      // Refresh cart when returning from payment screen.
      final cart = await CartService.getCart();

      if (!mounted) return;

      setState(() {
        _cartItems = cart;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savingDetails = false;
      });

      _showError(
        'Unable to continue. Please try again.',
      );
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double get _subtotal {
    double value = 0;

    for (final item in _cartItems) {
      final price =
          (item['price'] as num?)?.toDouble() ?? 0;

      final quantity =
          (item['quantity'] as num?)?.toInt() ?? 1;

      value += price * quantity;
    }

    return value;
  }

  double get _deliveryCharge {
    return _subtotal >= 500 ? 0 : 40;
  }

  double get _total {
    return _subtotal + _deliveryCharge;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Review your delivery details',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      )
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >= 950;

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
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeliveryDetailsCard(),

          const SizedBox(height: 18),

          _buildOrderSummaryCard(),

          const SizedBox(height: 22),

          _buildContinueButton(),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1150,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _buildDeliveryDetailsCard(),
              ),
              const SizedBox(width: 26),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 20),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELIVERY DETAILS CARD
  // ============================================================

  Widget _buildDeliveryDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E8E2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryGreen,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Where should we deliver your order?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _buildFixedNameField(),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _mobileController,
            label: 'Mobile Number',
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _addressController,
            label: 'Delivery Address',
            hint: 'House no, street, area',
            icon: Icons.home_outlined,
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'City',
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: '6 digits',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: orange.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: orange,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your delivery details will be saved for your next order.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIXED NAME
  // ============================================================

  Widget _buildFixedNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE1E7E2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  _customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Saved',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primaryGreen,
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
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.black38,
            ),
            prefixIcon: Icon(
              icon,
              color: primaryGreen,
              size: 21,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFE0E7E1),
              ),
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
        ),
      ],
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E8E2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 16),

          if (_cartItems.isEmpty)
            const Text(
              'Your cart is empty.',
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          else
            ..._cartItems.map(
                  (item) => _buildSummaryItem(item),
            ),

          const Divider(
            height: 25,
          ),

          _summaryRow(
            'Subtotal',
            '₹${_subtotal.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 9),

          _summaryRow(
            'Delivery',
            _deliveryCharge == 0
                ? 'FREE'
                : '₹${_deliveryCharge.toStringAsFixed(0)}',
            valueColor: _deliveryCharge == 0
                ? primaryGreen
                : darkGreen,
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.only(
              top: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5EAE6),
                ),
              ),
            ),
            child: _summaryRow(
              'Total Payable',
              '₹${_total.toStringAsFixed(0)}',
              bold: true,
              valueColor: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _buildSummaryItem(
      Map<String, dynamic> item,
      ) {
    final String name =
        item['name']?.toString() ?? '';

    final int quantity =
        (item['quantity'] as num?)?.toInt() ?? 1;

    final double price =
        (item['price'] as num?)?.toDouble() ?? 0;

    final String image =
        item['image']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: image.isEmpty
                ? const Icon(
              Icons.image_outlined,
              color: Colors.grey,
            )
                : Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                );
              },
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '₹${(price * quantity).toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      String title,
      String value, {
        bool bold = false,
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight:
            bold ? FontWeight.w800 : FontWeight.w500,
            color:
            bold ? darkGreen : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 13,
            fontWeight:
            bold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? darkGreen,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTINUE BUTTON
  // ============================================================

  Widget _buildContinueButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
            _savingDetails ? null : _continueToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              disabledBackgroundColor:
              primaryGreen.withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(15),
              ),
            ),
            child: _savingDetails
                ? const SizedBox(
              width: 22,
              height: 22,
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
                Text(
                  'Continue to Payment',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                SizedBox(width: 9),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 13),

        const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: Colors.black38,
            ),
            SizedBox(width: 6),
            Text(
              'Secure checkout',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
