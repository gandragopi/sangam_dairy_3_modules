import 'package:flutter/material.dart';

import 'order_tracking_screen.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final String paymentMethod;

  final String customerName;
  final String mobile;
  final String address;
  final String city;
  final String pincode;

  final List<Map<String, dynamic>> items;

  final double subtotal;
  final double deliveryCharge;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    this.customerName = '',
    this.mobile = '',
    this.address = '',
    this.city = '',
    this.pincode = '',
    this.items = const [],
    this.subtotal = 0,
    this.deliveryCharge = 0,
  });

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFEAF7EE);
  static const Color cream = Color(0xFFFFFCF5);
  static const Color orange = Color(0xFFFFA916);
  static const Color textGrey = Color(0xFF69736B);

  String _formatPrice(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _paymentLogo() {
    final method = paymentMethod.trim().toLowerCase();

    if (method.contains('phonepe')) {
      return Image.asset(
        'assets/images/phonepe.png',
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return const Icon(
            Icons.phone_android_rounded,
            color: primaryGreen,
            size: 28,
          );
        },
      );
    }

    if (method.contains('google pay') ||
        method.contains('gpay')) {
      return Image.asset(
        'assets/images/google_pay.png',
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return const Icon(
            Icons.account_balance_wallet_rounded,
            color: primaryGreen,
            size: 28,
          );
        },
      );
    }

    return const Icon(
      Icons.payments_outlined,
      color: primaryGreen,
      size: 28,
    );
  }

  String get _deliveryText {
    if (deliveryCharge <= 0) {
      return 'FREE';
    }

    return _formatPrice(deliveryCharge);
  }

  String get _addressText {
    return [
      address,
      city,
      pincode,
    ]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
  }

  void _openTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(
          orderId: orderId,
          totalAmount: totalAmount,
          paymentMethod: paymentMethod,
          customerName: customerName,
          mobile: mobile,
          address: address,
          city: city,
          pincode: pincode,
          items: items,
          status: 'Order Placed',
        ),
      ),
    );
  }

  void _openOrders(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const OrdersScreen(),
      ),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 850;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 18,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // SUCCESS ICON
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryGreen.withValues(
                          alpha: 0.18,
                        ),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: primaryGreen,
                      size: 58,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Order Placed Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Thank you for ordering from Sangam Dairy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ORDER ID
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black.withValues(
                          alpha: 0.06,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#$orderId',
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ETA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          darkGreen,
                          primaryGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expected Delivery',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Today • Within 30–45 mins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SUMMARY
                  _buildCard(
                    title: 'Order Summary',
                    icon: Icons.shopping_basket_outlined,
                    child: Column(
                      children: [
                        if (items.isEmpty)
                          const Padding(
                            padding:
                            EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Text(
                              'Order items are available in My Orders.',
                            ),
                          )
                        else
                          ...items.map(
                                (item) {
                              final name =
                                  item['name']
                                      ?.toString() ??
                                      'Product';

                              final price =
                              item['price'] is num
                                  ? (item['price'] as num)
                                  .toDouble()
                                  : double.tryParse(
                                item['price']
                                    ?.toString() ??
                                    '',
                              ) ??
                                  0;

                              final quantity =
                              item['quantity'] is num
                                  ? (item['quantity'] as num)
                                  .toInt()
                                  : int.tryParse(
                                item['quantity']
                                    ?.toString() ??
                                    '',
                              ) ??
                                  1;

                              return Padding(
                                padding:
                                const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$name × $quantity',
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow
                                            .ellipsis,
                                        style: const TextStyle(
                                          color: darkGreen,
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatPrice(
                                        price * quantity,
                                      ),
                                      style:
                                      const TextStyle(
                                        color: darkGreen,
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const Divider(height: 20),

                        _summaryRow(
                          'Item Total',
                          _formatPrice(subtotal),
                        ),

                        const SizedBox(height: 9),

                        _summaryRow(
                          'Delivery Fee',
                          _deliveryText,
                          valueColor:
                          deliveryCharge == 0
                              ? primaryGreen
                              : darkGreen,
                        ),

                        const SizedBox(height: 9),

                        _summaryRow(
                          'Handling Fee',
                          '₹0',
                        ),

                        const SizedBox(height: 9),

                        _summaryRow(
                          'Platform Fee',
                          '₹0',
                        ),

                        const SizedBox(height: 9),

                        _summaryRow(
                          'Discount',
                          '₹0',
                        ),

                        const Divider(height: 24),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total Paid',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              _formatPrice(totalAmount),
                              style: const TextStyle(
                                color: primaryGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'GST included in applicable product/service prices',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // DELIVERY + PAYMENT
                  _buildCard(
                    title: 'Delivery & Payment',
                    icon: Icons.local_shipping_outlined,
                    child: Column(
                      children: [
                        if (_addressText.isNotEmpty)
                          _detailRow(
                            Icons.home_outlined,
                            'Deliver to',
                            _addressText,
                          ),

                        if (_addressText.isNotEmpty)
                          const SizedBox(height: 14),

                        _detailRow(
                          Icons.person_outline,
                          'Customer',
                          customerName.isEmpty
                              ? 'Gopi Gandra'
                              : customerName,
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: _paymentLogo(),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment',
                                    style: TextStyle(
                                      color: textGrey,
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    paymentMethod,
                                    style: const TextStyle(
                                      color: darkGreen,
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatPrice(totalAmount),
                              style: const TextStyle(
                                color: primaryGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PROGRESS
                  _buildCard(
                    title: 'Order Status',
                    icon: Icons.route_outlined,
                    child: Row(
                      children: [
                        _statusStep(
                          icon: Icons.check_rounded,
                          title: 'Placed',
                          active: true,
                        ),
                        _statusLine(),
                        _statusStep(
                          icon: Icons.inventory_2_outlined,
                          title: 'Packed',
                          active: false,
                        ),
                        _statusLine(),
                        _statusStep(
                          icon: Icons.delivery_dining_outlined,
                          title: 'Delivered',
                          active: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // TRACK
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _openTracking(context);
                      },
                      icon: const Icon(
                        Icons.location_searching_rounded,
                      ),
                      label: const Text(
                        'Track Order',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ORDERS
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _openOrders(context);
                      },
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                      ),
                      label: const Text(
                        'View My Orders',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(
                          color: primaryGreen,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SHARE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: orange,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Share your order details with family',
                            style: TextStyle(
                              color: Color(0xFF755000),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? darkGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusStep({
    required IconData icon,
    required String title,
    required bool active,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: active
                  ? lightGreen
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? primaryGreen
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: active
                  ? primaryGreen
                  : Colors.grey.shade400,
              size: 21,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? darkGreen
                  : Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine() {
    return Container(
      width: 28,
      height: 2,
      margin: const EdgeInsets.only(
        bottom: 23,
      ),
      color: Colors.grey.shade300,
    );
  }
}
