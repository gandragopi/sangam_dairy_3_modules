import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/order_api_service.dart';
import '../product/product_details_screen.dart';
import '../reviews/rate_review_screen.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF075C2A);
  static const Color lightGreen = Color(0xFFEAF7EE);
  static const Color pageBackground = Color(0xFFF8FBF8);
  static const Color orange = Color(0xFFFFA916);
  static const Color red = Color(0xFFD64545);

  // ------------------------------------------------------------
  // DEMO DELIVERED ORDER
  // ------------------------------------------------------------

  static const String deliveredOrderId = 'SGM20260916091837';

  // ------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------

  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic> _reviews = {};

  final Set<String> _cancelledOrderIds = <String>{};

  bool _isLoading = true;

  int _selectedTab = 0;

  final List<String> _tabs = [
    'All',
    'Active',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }

  // ------------------------------------------------------------
  // LOAD ORDERS
  // ------------------------------------------------------------

  Future<void> _loadOrders() async {
    try {
      final orders = await OrderApiService.getOrders();

      final prefs = await SharedPreferences.getInstance();

      final reviewString =
      prefs.getString('sangam_dairy_reviews');

      final cancelledOrderIds =
          prefs.getStringList('sangam_cancelled_orders') ?? <String>[];

      Map<String, dynamic> reviews = {};

      if (reviewString != null &&
          reviewString.isNotEmpty) {
        try {
          final decoded = jsonDecode(reviewString);

          if (decoded is Map) {
            reviews = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {
          reviews = {};
        }
      }

      if (!mounted) return;

      setState(() {
        _orders =
        List<Map<String, dynamic>>.from(orders);
        _reviews = reviews;
        _cancelledOrderIds
          ..clear()
          ..addAll(cancelledOrderIds);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _orders = [];
        _reviews = {};
        _cancelledOrderIds.clear();
        _isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // BASIC HELPERS
  // ------------------------------------------------------------

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String _getOrderId(
      Map<String, dynamic> order,
      int index,
      ) {
    final value = order['orderId'] ??
        order['id'] ??
        order['order_id'] ??
        order['orderNumber'];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return 'SG-${1000 + index}';
  }
  String _getCustomerName(
      Map<String, dynamic> order,
      ) {
    final value = order['customerName'];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return 'Gopi Gandra';
  }

  String _getPaymentMethod(
      Map<String, dynamic> order,
      ) {
    final value = order['paymentMethod'];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return 'Cash on Delivery';
  }

  List<Map<String, dynamic>> _getItems(
      Map<String, dynamic> order,
      ) {
    final rawItems = order['items'];

    if (rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) =>
        Map<String, dynamic>.from(item),
      )
          .toList();
    }

    return [];
  }

  String _getItemName(
      Map<String, dynamic> item,
      ) {
    return (
        item['name'] ??
            item['productName'] ??
            item['title'] ??
            'Product'
    ).toString();
  }

  String _getItemImage(
      Map<String, dynamic> item,
      ) {
    return (
        item['image'] ??
            item['imagePath'] ??
            ''
    ).toString();
  }

  double _getItemPrice(
      Map<String, dynamic> item,
      ) {
    return _toDouble(item['price']);
  }

  int _getItemQuantity(
      Map<String, dynamic> item,
      ) {
    final quantity = item['quantity'];

    if (quantity is num) {
      return quantity.toInt();
    }

    return int.tryParse(
      quantity?.toString() ?? '',
    ) ??
        1;
  }

  double _getItemTotal(
      Map<String, dynamic> item,
      ) {
    return _getItemPrice(item) *
        _getItemQuantity(item);
  }

  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

  bool _isDelivered(
      Map<String, dynamic> order,
      int index,
      ) {
    final orderId = _getOrderId(
      order,
      index,
    );

    return orderId == deliveredOrderId;
  }

  bool _isCancelled(
      Map<String, dynamic> order,
      ) {
    final orderId = order['orderId'] ??
        order['id'] ??
        order['order_id'] ??
        order['orderNumber'];

    final normalizedOrderId =
        orderId?.toString().trim() ?? '';

    final status =
    order['status']
        ?.toString()
        .toLowerCase()
        .trim();

    return _cancelledOrderIds.contains(
      normalizedOrderId,
    ) ||
        status == 'cancelled' ||
        status == 'canceled';
  }

  String _getDisplayStatus(
      Map<String, dynamic> order,
      int index,
      ) {
    if (_isCancelled(order)) {
      return 'Cancelled';
    }

    if (_isDelivered(order, index)) {
      return 'Delivered';
    }

    return 'Order Placed';
  }

  // ------------------------------------------------------------
  // TAB FILTER
  // ------------------------------------------------------------

  List<Map<String, dynamic>> _getFilteredOrders() {
    final filtered = <Map<String, dynamic>>[];

    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];

      final delivered = _isDelivered(
        order,
        i,
      );

      final cancelled = _isCancelled(order);

      if (_selectedTab == 0) {
        filtered.add(order);
      } else if (_selectedTab == 1) {
        if (!delivered && !cancelled) {
          filtered.add(order);
        }
      } else if (_selectedTab == 2) {
        if (delivered) {
          filtered.add(order);
        }
      } else if (_selectedTab == 3) {
        if (cancelled) {
          filtered.add(order);
        }
      }
    }

    return filtered;
  }

  int _getOriginalIndex(
      Map<String, dynamic> order,
      ) {
    return _orders.indexOf(order);
  }

  // ------------------------------------------------------------
  // REVIEWS
  // ------------------------------------------------------------

  bool _hasReview(String orderId) {
    return _reviews.containsKey(orderId);
  }

  Future<void> _openRateReview(
      Map<String, dynamic> order,
      int index,
      ) async {
    final orderId = _getOrderId(
      order,
      index,
    );

    final items = _getItems(order);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RateReviewScreen(
              orderId: orderId,
              items: items,
            ),
      ),
    );

    await _loadOrders();
  }

  // ------------------------------------------------------------
  // TRACKING
  // ------------------------------------------------------------

  Future<void> _openTracking(
      Map<String, dynamic> order,
      int index,
      ) async {
    final orderId = _getOrderId(
      order,
      index,
    );

    final totalAmount = _toDouble(
      order['totalAmount'] ??
          order['total'] ??
          order['grandTotal'] ??
          order['amount'] ??
          0,
    );

    final items = _getItems(order);

    final status = _getDisplayStatus(
      order,
      index,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderTrackingScreen(
              orderId: orderId,
              totalAmount: totalAmount,
              paymentMethod:
              _getPaymentMethod(order),
              status: status,
              customerName:
              _getCustomerName(order),
              mobile:
              order['mobile']?.toString() ?? '',
              address:
              order['address']?.toString() ?? '',
              city:
              order['city']?.toString() ?? '',
              pincode:
              order['pincode']?.toString() ?? '',
              items: items,
            ),
      ),
    );

    await _loadOrders();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ------------------------------------------------------
          // EXISTING ORDERS CONTENT
          // ------------------------------------------------------
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          )
              : RefreshIndicator(
            color: primaryGreen,
            onRefresh: _loadOrders,
            child: _buildOrdersContent(),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // APP BAR
  // ------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryGreen,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(13),
            ),
            padding:
            const EdgeInsets.all(6),
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
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'My Orders',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN CONTENT
  // ------------------------------------------------------------

  Widget _buildOrdersContent() {
    final filteredOrders =
    _getFilteredOrders();

    final totalOrders = _orders.length;

    int activeOrders = 0;
    int deliveredOrders = 0;
    int cancelledOrders = 0;

    for (int i = 0; i < _orders.length; i++) {
      if (_isDelivered(
        _orders[i],
        i,
      )) {
        deliveredOrders++;
      } else if (_isCancelled(
        _orders[i],
      )) {
        cancelledOrders++;
      } else {
        activeOrders++;
      }
    }

    if (_orders.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 100),
          _buildEmptyState(),
        ],
      );
    }

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      children: [
        _buildSummaryHeader(
          total: totalOrders,
          active: activeOrders,
          delivered: deliveredOrders,
        ),

        const SizedBox(height: 20),

        _buildTabs(
          activeCount: activeOrders,
          deliveredCount: deliveredOrders,
          cancelledCount: cancelledOrders,
        ),

        const SizedBox(height: 18),

        if (filteredOrders.isEmpty)
          _buildFilteredEmptyState()
        else
          ...filteredOrders.map(
                (order) {
              final originalIndex =
              _getOriginalIndex(order);

              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 16,
                ),
                child: _buildOrderCard(
                  order,
                  originalIndex,
                ),
              );
            },
          ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SUMMARY HEADER
  // ------------------------------------------------------------

  Widget _buildSummaryHeader({
    required int total,
    required int active,
    required int delivered,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Orders',
          style: TextStyle(
            color: darkGreen,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Track and manage your Sangam Dairy purchases',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 17),

        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total',
                value: total.toString(),
                icon:
                Icons.receipt_long_rounded,
                color: primaryGreen,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildSummaryCard(
                title: 'Active',
                value: active.toString(),
                icon:
                Icons.local_shipping_rounded,
                color: orange,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildSummaryCard(
                title: 'Delivered',
                value: delivered.toString(),
                icon:
                Icons.check_circle_rounded,
                color: primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: Colors.black
              .withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.035),
            blurRadius: 13,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TABS
  // ------------------------------------------------------------

  Widget _buildTabs({
    required int activeCount,
    required int deliveredCount,
    required int cancelledCount,
  }) {
    return Container(
      height: 60,
      padding:
      const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black
              .withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: List.generate(
          _tabs.length,
              (index) {
            final selected =
                _selectedTab == index;

            String? count;

            if (index == 1) {
              count =
                  activeCount.toString();
            } else if (index == 2) {
              count =
                  deliveredCount.toString();
            } else if (index == 3) {
              count =
                  cancelledCount.toString();
            }

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 180,
                  ),
                  height: 50,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryGreen
                        : Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        _tabs[index],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black54,
                          fontSize: 15.5,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      if (count != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration:
                          BoxDecoration(
                            color: selected
                                ? Colors.white
                                .withValues(
                              alpha: 0.18,
                            )
                                : lightGreen,
                            borderRadius:
                            BorderRadius
                                .circular(8),
                          ),
                          child: Text(
                            count,
                            style:
                            TextStyle(
                              color: selected
                                  ? Colors.white
                                  : primaryGreen,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
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

  // ------------------------------------------------------------
  // ORDER CARD
  // ------------------------------------------------------------

  Widget _buildOrderCard(
      Map<String, dynamic> order,
      int index,
      ) {
    final orderId =
    _getOrderId(order, index);

    final delivered =
    _isDelivered(order, index);

    final cancelled =
    _isCancelled(order);

    final status =
    _getDisplayStatus(
      order,
      index,
    );

    final items =
    _getItems(order);

    final totalAmount =
    _toDouble(
      order['totalAmount'] ??
          order['total'] ??
          order['grandTotal'] ??
          order['amount'] ??
          0,
    );

    final reviewed =
    _hasReview(orderId);

    final itemTotal = items.fold<double>(
      0,
          (
          previous,
          item,
          ) =>
      previous + _getItemTotal(item),
    );

    final deliveryFee =
    _toDouble(
      order['deliveryFee'] ??
          order['deliveryCharge'] ??
          0,
    );

    final handlingFee =
    _toDouble(
      order['handlingFee'] ?? 0,
    );

    final platformFee =
    _toDouble(
      order['platformFee'] ?? 0,
    );

    final discount =
    _toDouble(
      order['discount'] ?? 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: cancelled
              ? red.withValues(
            alpha: 0.18,
          )
              : Colors.black
              .withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.045),
            blurRadius: 18,
            offset:
            const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOrderHeader(
            orderId: orderId,
            status: status,
            delivered: delivered,
            cancelled: cancelled,
          ),

          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
          ),

          _buildOrderItems(items),

          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
          ),

          _buildOrderDetails(
            order: order,
            itemTotal: itemTotal,
            deliveryFee: deliveryFee,
            handlingFee: handlingFee,
            platformFee: platformFee,
            discount: discount,
            totalAmount: totalAmount,
          ),

          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
          ),

          _buildOrderActions(
            order: order,
            index: index,
            delivered: delivered,
            cancelled: cancelled,
            reviewed: reviewed,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ORDER HEADER
  // ------------------------------------------------------------

  Widget _buildOrderHeader({
    required String orderId,
    required String status,
    required bool delivered,
    required bool cancelled,
  }) {
    final Color statusColor;

    if (cancelled) {
      statusColor = red;
    } else if (delivered) {
      statusColor = primaryGreen;
    } else {
      statusColor = orange;
    }

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        14,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusColor
                  .withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              cancelled
                  ? Icons.cancel_outlined
                  : delivered
                  ? Icons
                  .check_circle_rounded
                  : Icons
                  .shopping_bag_rounded,
              color: statusColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #$orderId',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cancelled
                      ? 'This order was cancelled'
                      : delivered
                      ? 'Delivered successfully'
                      : 'Your order is being processed',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _buildStatusChip(
            status,
            statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String status,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(alpha: 0.10),
        borderRadius:
        BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ORDER ITEMS
  // ------------------------------------------------------------

  Widget _buildOrderItems(
      List<Map<String, dynamic>> items,
      ) {
    if (items.isEmpty) {
      return const Padding(
        padding:
        EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.black38,
            ),
            SizedBox(width: 10),
            Text(
              'Order items unavailable',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        15,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .shopping_basket_outlined,
                color: primaryGreen,
                size: 19,
              ),
              const SizedBox(width: 7),
              Text(
                '${items.length} ${items.length == 1 ? 'Item' : 'Items'}',
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...items.map(
                (item) =>
                _buildItemRow(item),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
      Map<String, dynamic> item,
      ) {
    final image =
    _getItemImage(item);

    final name =
    _getItemName(item);

    final quantity =
    _getItemQuantity(item);

    final price =
    _getItemPrice(item);

    final total =
        price * quantity;

    return InkWell(
      borderRadius:
      BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(
                  product: item,
                ),
          ),
        );
      },
      child: Padding(
        padding:
        const EdgeInsets.only(
          bottom: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              padding:
              const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
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
                        .local_drink_rounded,
                    color:
                    primaryGreen,
                    size: 28,
                  );
                },
              )
                  : const Icon(
                Icons
                    .local_drink_rounded,
                color:
                primaryGreen,
                size: 28,
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
                    style:
                    const TextStyle(
                      color: darkGreen,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(0)} × $quantity',
                    style:
                    const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '₹${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 13,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ORDER DETAILS / BILL
  // ------------------------------------------------------------

  Widget _buildOrderDetails({
    required Map<String, dynamic> order,
    required double itemTotal,
    required double deliveryFee,
    required double handlingFee,
    required double platformFee,
    required double discount,
    required double totalAmount,
  }) {
    final paymentMethod =
    _getPaymentMethod(order);

    final address =
        order['address']
            ?.toString() ??
            '';

    final city =
        order['city']
            ?.toString() ??
            '';

    final pincode =
        order['pincode']
            ?.toString() ??
            '';

    String fullAddress =
        address;

    if (city.isNotEmpty) {
      fullAddress =
      fullAddress.isEmpty
          ? city
          : '$fullAddress, $city';
    }

    if (pincode.isNotEmpty) {
      fullAddress =
      fullAddress.isEmpty
          ? pincode
          : '$fullAddress - $pincode';
    }

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        15,
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            paymentMethod,
          ),

          const SizedBox(height: 14),

          if (fullAddress.isNotEmpty)
            _buildDetailRow(
              icon:
              Icons.location_on_outlined,
              title: 'Delivery',
              value: fullAddress,
            ),

          if (fullAddress.isNotEmpty)
            const SizedBox(height: 14),

          _buildBillSection(
            itemTotal: itemTotal,
            deliveryFee: deliveryFee,
            handlingFee: handlingFee,
            platformFee: platformFee,
            discount: discount,
            totalAmount: totalAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
      String paymentMethod,
      ) {
    final method =
    paymentMethod.toLowerCase();

    Widget logo;

    if (method.contains('phonepe')) {
      logo = Image.asset(
        'assets/images/phonepe.png',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons.phone_android_rounded,
            color: primaryGreen,
            size: 22,
          );
        },
      );
    } else if (method.contains(
      'google pay',
    ) ||
        method.contains('gpay')) {
      logo = Image.asset(
        'assets/images/google_pay.png',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons
                .account_balance_wallet_rounded,
            color: primaryGreen,
            size: 22,
          );
        },
      );
    } else {
      logo = const Icon(
        Icons.payments_outlined,
        color: primaryGreen,
        size: 22,
      );
    }

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
            BorderRadius.circular(11),
          ),
          child: Center(
            child: logo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                paymentMethod,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillSection({
    required double itemTotal,
    required double deliveryFee,
    required double handlingFee,
    required double platformFee,
    required double discount,
    required double totalAmount,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: orange.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: primaryGreen,
                size: 18,
              ),
              SizedBox(width: 7),
              Text(
                'Bill Details',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _billRow(
            'Item Total',
            '₹${itemTotal.toStringAsFixed(0)}',
          ),

          if (deliveryFee > 0) ...[
            const SizedBox(height: 7),
            _billRow(
              'Delivery Fee',
              '₹${deliveryFee.toStringAsFixed(0)}',
            ),
          ] else ...[
            const SizedBox(height: 7),
            _billRow(
              'Delivery Fee',
              'FREE',
              valueColor: primaryGreen,
            ),
          ],

          const SizedBox(height: 7),

          _billRow(
            'Handling Fee',
            '₹${handlingFee.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 7),

          _billRow(
            'Platform Fee',
            '₹${platformFee.toStringAsFixed(0)}',
          ),

          if (discount > 0) ...[
            const SizedBox(height: 7),
            _billRow(
              'Discount',
              '-₹${discount.toStringAsFixed(0)}',
              valueColor: primaryGreen,
            ),
          ],

          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Divider(
              height: 1,
            ),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Amount',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Align(
            alignment:
            Alignment.centerLeft,
            child: Text(
              'GST included in applicable prices',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 9.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
            valueColor ?? darkGreen,
            fontSize: 11,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ACTIONS
  // ------------------------------------------------------------

  Widget _buildOrderActions({
    required Map<String, dynamic> order,
    required int index,
    required bool delivered,
    required bool cancelled,
    required bool reviewed,
  }) {
    if (cancelled) {
      return Padding(
        padding:
        const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              _showCancelledMessage();
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              size: 17,
            ),
            label: const Text(
              'Order Cancelled',
            ),
            style:
            OutlinedButton.styleFrom(
              foregroundColor: red,
              side: BorderSide(
                color: red.withValues(
                  alpha: 0.5,
                ),
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
              ),
              textStyle:
              const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        13,
        18,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _openTracking(
                  order,
                  index,
                );
              },
              icon: const Icon(
                Icons
                    .location_searching_rounded,
                size: 17,
              ),
              label: const Text(
                'Track Order',
              ),
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                primaryGreen,
                side: const BorderSide(
                  color: primaryGreen,
                ),
                minimumSize:
                const Size(0, 45),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                textStyle:
                const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          if (delivered) ...[
            const SizedBox(width: 10),
            Expanded(
              child:
              ElevatedButton.icon(
                onPressed: () {
                  _openRateReview(
                    order,
                    index,
                  );
                },
                icon: Icon(
                  reviewed
                      ? Icons
                      .rate_review_rounded
                      : Icons.star_rounded,
                  size: 17,
                ),
                label: Text(
                  reviewed
                      ? 'Reviewed'
                      : 'Rate & Review',
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  orange,
                  foregroundColor:
                  Colors.white,
                  minimumSize:
                  const Size(0, 45),
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  textStyle:
                  const TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CANCELLED MESSAGE
  // ------------------------------------------------------------

  void _showCancelledMessage() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),
          title: const Text(
            'Order Cancelled',
            style: TextStyle(
              color: darkGreen,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          content: const Text(
            'This order has been cancelled.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
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

  // ------------------------------------------------------------
  // FILTER EMPTY
  // ------------------------------------------------------------

  Widget _buildFilteredEmptyState() {
    String title;

    String description;

    IconData icon;

    if (_selectedTab == 1) {
      title = 'No Active Orders';
      description =
      'Your active orders will appear here.';
      icon =
          Icons.local_shipping_outlined;
    } else if (_selectedTab == 2) {
      title = 'No Delivered Orders';
      description =
      'Delivered orders will appear here.';
      icon =
          Icons.check_circle_outline_rounded;
    } else if (_selectedTab == 3) {
      title = 'No Cancelled Orders';
      description =
      'Cancelled orders will appear here.';
      icon =
          Icons.cancel_outlined;
    } else {
      title = 'No Orders Yet';
      description =
      'Your Sangam Dairy orders will appear here.';
      icon =
          Icons.shopping_bag_outlined;
    }

    return Container(
      padding:
      const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(23),
        border: Border.all(
          color: Colors.black
              .withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration:
            const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 42,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 20,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY ORDERS
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      padding:
      const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black
              .withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration:
            const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .shopping_bag_outlined,
              color: primaryGreen,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Orders Yet',
            style: TextStyle(
              color: darkGreen,
              fontSize: 22,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Sangam Dairy orders will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              primaryGreen,
              foregroundColor:
              Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 13,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
