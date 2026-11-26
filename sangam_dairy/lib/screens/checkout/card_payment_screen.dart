import 'package:flutter/material.dart';

import '../../services/order_api_service.dart';
import '../../services/payment_api_service.dart';
import '../orders/order_success_screen.dart';

class CardPaymentScreen extends StatefulWidget {
  final String customerName;
  final String mobile;
  final String address;
  final String city;
  final String pincode;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryCharge;

  const CardPaymentScreen({
    super.key,
    required this.customerName,
    required this.mobile,
    required this.address,
    required this.city,
    required this.pincode,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryCharge,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardNumberController =
  TextEditingController();

  final TextEditingController _cardHolderController =
  TextEditingController();

  final TextEditingController _expiryController =
  TextEditingController();

  final TextEditingController _cvvController =
  TextEditingController();

  bool _isProcessing = false;
  bool _obscureCvv = true;

  double get totalAmount =>
      widget.subtotal + widget.deliveryCharge;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _generatePaymentReference() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CARD_$timestamp';
  }

  String _generateTransactionId() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN_$timestamp';
  }

  String _formatCardNumber(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');

    final StringBuffer result = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result.write(' ');
      }
      result.write(digits[i]);
    }

    return result.toString();
  }

  Future<void> _processCardPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
    });

    final String paymentReference =
    _generatePaymentReference();

    try {
      // --------------------------------------------------
      // STEP 1: CREATE PENDING PAYMENT IN BACKEND
      // --------------------------------------------------
      await PaymentApiService.createPayment(
        orderKey: 'guest_cart',
        paymentReference: paymentReference,
        amount: totalAmount,
        paymentMethod: 'Credit / Debit Card',
      );

      if (!mounted) return;

      // --------------------------------------------------
      // DEVELOPMENT PAYMENT PROCESSING SIMULATION
      // --------------------------------------------------
      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      // --------------------------------------------------
      // STEP 2: MARK PAYMENT AS SUCCESS IN BACKEND
      // --------------------------------------------------
      final String transactionId =
      _generateTransactionId();

      final Map<String, dynamic> paymentResult =
      await PaymentApiService.markPaymentSuccess(
        paymentReference: paymentReference,
        transactionId: transactionId,
      );

      if (!mounted) return;

      final String paymentStatus =
          paymentResult['status']?.toString() ?? '';

      if (paymentStatus != 'SUCCESS') {
        throw Exception(
          'Payment was not successful.',
        );
      }

      // --------------------------------------------------
      // STEP 3: CREATE ORDER ONLY AFTER PAYMENT SUCCESS
      // --------------------------------------------------
      final Map<String, dynamic> order =
      await OrderApiService.createOrder(
        customerName: widget.customerName,
        mobile: widget.mobile,
        address: widget.address,
        city: widget.city,
        pincode: widget.pincode,
        paymentMethod: 'Credit / Debit Card',
      );

      if (!mounted) return;

      final dynamic orderIdValue = order['id'];

      final String orderId =
          orderIdValue?.toString() ?? 'N/A';

      // --------------------------------------------------
      // STEP 4: PAYMENT SUCCESS MESSAGE
      // --------------------------------------------------
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF087A35),
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your card payment was successful.\n\n'
                  'Transaction ID: $transactionId\n'
                  'Order ID: $orderId',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Color(0xFF087A35),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // --------------------------------------------------
      // STEP 5: GO TO ORDER SUCCESS SCREEN
      // --------------------------------------------------
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: orderId,
            totalAmount: totalAmount,
            paymentMethod: 'Credit / Debit Card',
            customerName: widget.customerName,
            mobile: widget.mobile,
            address: widget.address,
            city: widget.city,
            pincode: widget.pincode,
            items: widget.cartItems,
            subtotal: widget.subtotal,
            deliveryCharge: widget.deliveryCharge,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF087A35),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF6F9F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF087A35),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _cardPreview() {
    final String number =
    _cardNumberController.text.trim();

    final String displayNumber = number.isEmpty
        ? '•••• •••• •••• ••••'
        : number;

    final String holder =
    _cardHolderController.text.trim().isEmpty
        ? 'CARD HOLDER'
        : _cardHolderController.text
        .trim()
        .toUpperCase();

    final String expiry =
    _expiryController.text.trim().isEmpty
        ? 'MM/YY'
        : _expiryController.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087A35),
            Color(0xFF173B20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SANGAM DAIRY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            displayNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    holder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF087A35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Card Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _cardPreview(),

                const SizedBox(height: 24),

                const Text(
                  'Enter Card Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B20),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (value) {
                    final String formatted =
                    _formatCardNumber(value);

                    if (formatted != value) {
                      _cardNumberController.value =
                          TextEditingValue(
                            text: formatted,
                            selection:
                            TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                    }

                    setState(() {});
                  },
                  decoration: _inputDecoration(
                    label: 'Card Number',
                    hint: '1234 5678 9012 3456',
                    icon: Icons.credit_card,
                  ).copyWith(
                    counterText: '',
                  ),
                  validator: (value) {
                    final String digits =
                    (value ?? '').replaceAll(
                      RegExp(r'\D'),
                      '',
                    );

                    if (digits.length != 16) {
                      return 'Enter a valid 16-digit card number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _cardHolderController,
                  textCapitalization:
                  TextCapitalization.characters,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: _inputDecoration(
                    label: 'Card Holder Name',
                    hint: 'Enter name on card',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter card holder name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType:
                        TextInputType.number,
                        maxLength: 5,
                        onChanged: (value) {
                          String digits =
                          value.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                          if (digits.length > 4) {
                            digits =
                                digits.substring(0, 4);
                          }

                          String formatted = digits;

                          if (digits.length > 2) {
                            formatted =
                            '${digits.substring(0, 2)}/${digits.substring(2)}';
                          }

                          if (formatted != value) {
                            _expiryController.value =
                                TextEditingValue(
                                  text: formatted,
                                  selection:
                                  TextSelection.collapsed(
                                    offset:
                                    formatted.length,
                                  ),
                                );
                          }

                          setState(() {});
                        },
                        decoration:
                        _inputDecoration(
                          label: 'Expiry',
                          hint: 'MM/YY',
                          icon: Icons.date_range,
                        ).copyWith(
                          counterText: '',
                        ),
                        validator: (value) {
                          final String text =
                              value?.trim() ?? '';

                          if (!RegExp(
                            r'^(0[1-9]|1[0-2])\/\d{2}$',
                          ).hasMatch(text)) {
                            return 'Enter MM/YY';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType:
                        TextInputType.number,
                        maxLength: 3,
                        obscureText: _obscureCvv,
                        decoration:
                        _inputDecoration(
                          label: 'CVV',
                          hint: '123',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureCvv =
                                !_obscureCvv;
                              });
                            },
                            icon: Icon(
                              _obscureCvv
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(
                                0xFF087A35,
                              ),
                            ),
                          ),
                        ).copyWith(
                          counterText: '',
                        ),
                        validator: (value) {
                          final String text =
                              value?.trim() ?? '';

                          if (!RegExp(
                            r'^\d{3}$',
                          ).hasMatch(text)) {
                            return 'Enter 3-digit CVV';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Color(0xFF087A35),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Secure Payment',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your card details are not '
                                  'stored by Sangam Dairy.',
                              style: TextStyle(
                                color:
                                Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF087A35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    _isProcessing
                        ? null
                        : _processCardPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF087A35),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: _isProcessing
                        ? const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing Payment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      'Pay ₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Development payment flow',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
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
