
import 'package:flutter/material.dart';

import '../../services/order_api_service.dart';
import '../../services/phonepe_payment_service.dart';
import '../../services/google_pay_payment_service.dart';
import '../orders/order_success_screen.dart';
import 'card_payment_screen.dart';
import 'net_banking_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
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

  final String customerName;
  final String mobile;
  final String address;
  final String city;
  final String pincode;

  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryCharge;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);
  static const Color textGrey = Color(0xFF69736B);

  // ============================================================
  // PAYMENT
  // ============================================================

  String _selectedPayment = 'Cash on Delivery';

  bool _isPlacingOrder = false;

  // ============================================================
  // TOTALS
  // ============================================================

  double get _subtotal => widget.subtotal;

  double get _deliveryCharge => widget.deliveryCharge;

  double get _totalAmount => _subtotal + _deliveryCharge;

  List<Map<String, dynamic>> get _cartItems => widget.cartItems;

  int get _totalItems {
    int total = 0;

    for (final item in _cartItems) {
      final dynamic quantity = item['quantity'];

      if (quantity is num) {
        total += quantity.toInt();
      } else {
        total +=
            int.tryParse(
              quantity?.toString() ?? '',
            ) ??
                1;
      }
    }

    return total;
  }

  // ============================================================
  // PAYMENT METHODS
  // ============================================================

  final List<String> _paymentMethods = [
    'PhonePe',
    'Google Pay',
    'Credit / Debit Card',
    'Net Banking',
    'Cash on Delivery',
  ];

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  String _formatPrice(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );
      return;
    }

    if (_isPlacingOrder) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final order = await OrderApiService.createOrder(
        customerName: widget.customerName,
        mobile: widget.mobile,
        address: widget.address,
        city: widget.city,
        pincode: widget.pincode,
        paymentMethod: _selectedPayment,
      );

      final String orderId =
          order['id']?.toString() ??
              'SANGAM-ORDER';

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: orderId,
            totalAmount: _totalAmount,
            paymentMethod: _selectedPayment,
            customerName: widget.customerName,
            mobile: widget.mobile,
            address: widget.address,
            city: widget.city,
            pincode: widget.pincode,
            items: _cartItems,
            subtotal: _subtotal,
            deliveryCharge: _deliveryCharge,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to place order. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // ============================================================
  // PHONEPE PAYMENT
  // ============================================================

  Future<void> _startPhonePePayment() async {
    if (_cartItems.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );
      return;
    }

    final String paymentReference =
        'SG${DateTime.now().millisecondsSinceEpoch}';

    final bool launched =
    await PhonePePaymentService.startPayment(
      amount: _totalAmount,
      orderReference: paymentReference,
    );

    if (!mounted) {
      return;
    }

    if (!launched) {
      _showMessage(
        'PhonePe app is not available on this device.',
      );
      return;
    }

    // IMPORTANT:
    // Opening PhonePe does NOT mean payment is successful.
    // Therefore we do NOT call _placeOrder() here.
    //
    // Real payment verification will be added later through
    // PhonePe Payment Gateway + backend verification.

    _showMessage(
      'PhonePe opened. Complete the payment there.',
    );
  }

  // ============================================================
  // GOOGLE PAY PAYMENT
  // ============================================================

  Future<void> _startGooglePayPayment() async {
    if (_cartItems.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );
      return;
    }

    if (_totalAmount <= 0) {
      _showMessage(
        'Invalid payment amount.',
      );
      return;
    }

    final String paymentReference =
        'SG${DateTime.now().millisecondsSinceEpoch}';

    final bool launched =
    await GooglePayPaymentService.startPayment(
      amount: _totalAmount,
      orderReference: paymentReference,
    );

    if (!mounted) {
      return;
    }

    if (!launched) {
      _showMessage(
        'Google Pay app is not available on this device.',
      );
      return;
    }

    // IMPORTANT:
    // Opening Google Pay does NOT mean payment is successful.
    // Therefore we do NOT call _placeOrder() here.
    //
    // Later, production payment verification will be added
    // through a payment gateway + backend verification.

    _showMessage(
      'Google Pay opened. Complete the payment there.',
    );
  }

  // ============================================================
  // HANDLE PAYMENT
  // ============================================================

  Future<void> _handlePayment() async {
    if (_cartItems.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );
      return;
    }

    // ----------------------------------------------------------
    // CASH ON DELIVERY
    // ----------------------------------------------------------

    if (_selectedPayment == 'Cash on Delivery') {
      await _placeOrder();
      return;
    }

    // ----------------------------------------------------------
    // PHONEPE
    // ----------------------------------------------------------

    if (_selectedPayment == 'PhonePe') {
      await _startPhonePePayment();
      return;
    }

    // ----------------------------------------------------------
    // GOOGLE PAY
    // ----------------------------------------------------------

    if (_selectedPayment == 'Google Pay') {
      await _startGooglePayPayment();
      return;
    }

    // ----------------------------------------------------------
    // CREDIT / DEBIT CARD
    // ----------------------------------------------------------

    if (_selectedPayment == 'Credit / Debit Card') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CardPaymentScreen(
            customerName: widget.customerName,
            mobile: widget.mobile,
            address: widget.address,
            city: widget.city,
            pincode: widget.pincode,
            cartItems: _cartItems,
            subtotal: _subtotal,
            deliveryCharge: _deliveryCharge,
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // NET BANKING
    // ----------------------------------------------------------

    if (_selectedPayment == 'Net Banking') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NetBankingScreen(
            amount: _totalAmount,
            customerName: widget.customerName,
            mobile: widget.mobile,
            address: widget.address,
            city: widget.city,
            pincode: widget.pincode,
            cartItems: _cartItems,
            subtotal: _subtotal,
            deliveryCharge: _deliveryCharge,
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // OTHER ONLINE METHODS
    // ----------------------------------------------------------

    _showOnlinePaymentDialog();
  }

  // ============================================================
  // ONLINE PAYMENT DIALOG
  // ============================================================

  void _showOnlinePaymentDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Online Payment',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedPayment,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatPrice(_totalAmount),
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Continue to complete your payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _placeOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'PAY & PLACE ORDER',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
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
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  Widget _paymentIcon(String method) {
    if (method == 'PhonePe') {
      return Image.asset(
        'assets/images/phonepe.png',
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons.phone_android_rounded,
            color: primaryGreen,
            size: 28,
          );
        },
      );
    }

    if (method == 'Google Pay') {
      return Image.asset(
        'assets/images/google_pay.png',
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons.account_balance_wallet_rounded,
            color: primaryGreen,
            size: 28,
          );
        },
      );
    }

    if (method == 'Credit / Debit Card') {
      return const Icon(
        Icons.credit_card_rounded,
        color: primaryGreen,
        size: 29,
      );
    }

    if (method == 'Net Banking') {
      return const Icon(
        Icons.account_balance_rounded,
        color: primaryGreen,
        size: 29,
      );
    }

    return const Icon(
      Icons.payments_outlined,
      color: primaryGreen,
      size: 29,
    );
  }

  // ============================================================
  // PAYMENT METHOD CARD
  // ============================================================

  Widget _paymentMethodCard(
      String method,
      ) {
    final bool selected =
        _selectedPayment == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? lightGreen
              : Colors.white,
          borderRadius:
          BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? primaryGreen
                : const Color(0xFFE0E8E2),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : lightGreen,
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Center(
                child: _paymentIcon(method),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method == 'PhonePe'
                        ? 'Pay securely using PhonePe'
                        : method == 'Google Pay'
                        ? 'Pay using Google Pay'
                        : method ==
                        'Cash on Delivery'
                        ? 'Pay when your order arrives'
                        : 'Secure payment option',
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? primaryGreen
                      : Colors.black26,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                margin:
                const EdgeInsets.all(
                  4,
                ),
                decoration:
                const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ORDER ITEM
  // ============================================================

  Widget _orderItem(
      Map<String, dynamic> item,
      ) {
    final String name =
        item['name']?.toString() ??
            item['productName']?.toString() ??
            'Product';

    final String image =
        item['image']?.toString() ?? '';

    final String packSize =
        item['packSize']?.toString() ?? '';

    final double price =
    _toDouble(item['price']);

    final int quantity =
    _toInt(item['quantity']);

    final double itemTotal =
        price * quantity;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE1E9E3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: image.isNotEmpty
                ? Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Icon(
                  Icons
                      .image_not_supported_outlined,
                  color: primaryGreen,
                );
              },
            )
                : const Icon(
              Icons.local_drink_rounded,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                if (packSize.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    packSize,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '₹${price.toStringAsFixed(0)} × $quantity',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${itemTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        1;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/sangam_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons.local_drink_rounded,
                    color: primaryGreen,
                  );
                },
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Sangam Dairy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                Text(
                  'Payment',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              padding:
              const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 23,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Select how you would like to pay for your order.',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ORDER ITEMS
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: const Color(
                          0xFFE0E8E2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .shopping_bag_outlined,
                              color:
                              primaryGreen,
                              size: 21,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Expanded(
                              child: Text(
                                'Order Items',
                                style: TextStyle(
                                  color:
                                  darkGreen,
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                ),
                              ),
                            ),
                            Text(
                              '$_totalItems items',
                              style:
                              const TextStyle(
                                color:
                                textGrey,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        ..._cartItems.map(
                          _orderItem,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PAYMENT METHODS
                  // ==================================================

                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 11),

                  ..._paymentMethods.map(
                    _paymentMethodCard,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // BILL SUMMARY
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                      18,
                    ),
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment:
                          Alignment.centerLeft,
                          child: Text(
                            'Order Summary',
                            style: TextStyle(
                              color:
                              Colors.white,
                              fontSize: 18,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 17,
                        ),

                        _summaryRow(
                          'Subtotal',
                          _formatPrice(
                            _subtotal,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        _summaryRow(
                          'Delivery',
                          _deliveryCharge == 0
                              ? 'FREE'
                              : _formatPrice(
                            _deliveryCharge,
                          ),
                        ),

                        const Padding(
                          padding:
                          EdgeInsets
                              .symmetric(
                            vertical: 16,
                          ),
                          child: Divider(
                            color:
                            Colors.white24,
                          ),
                        ),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total Amount',
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                ),
                              ),
                            ),
                            Text(
                              _formatPrice(
                                _totalAmount,
                              ),
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 23,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PAY BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                      _isPlacingOrder
                          ? null
                          : _handlePayment,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor:
                        darkGreen,
                        disabledBackgroundColor:
                        Colors.grey
                            .shade300,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: _isPlacingOrder
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: darkGreen,
                        ),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            _selectedPayment ==
                                'Cash on Delivery'
                                ? Icons
                                .check_circle_outline_rounded
                                : Icons
                                .lock_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            _selectedPayment ==
                                'Cash on Delivery'
                                ? 'PLACE ORDER'
                                : 'PAY ${_formatPrice(_totalAmount)}',
                            style:
                            const TextStyle(
                              fontSize: 14,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // SECURITY NOTE
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons
                            .verified_user_outlined,
                        color: primaryGreen,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _selectedPayment ==
                              'PhonePe'
                              ? 'You will be redirected to PhonePe for payment.'
                              : _selectedPayment ==
                              'Google Pay'
                              ? 'You will be redirected to Google Pay for payment.'
                              : 'Your payment information is handled securely.',
                          textAlign:
                          TextAlign.center,
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      String title,
      String value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}



