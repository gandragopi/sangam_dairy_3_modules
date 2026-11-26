import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFFFFCF5);
  static const Color orange = Color(0xFFF28C28);
  static const Color textDark = Color(0xFF18221B);
  static const Color textGrey = Color(0xFF69736B);

  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final items = await CartService.getCart();

      if (!mounted) return;

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load cart: $error'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadCart,
          ),
        ),
      );
    }
  }

  Future<void> _increaseQuantity(dynamic cartItemId) async {
    try {
      await CartService.increaseQuantity(cartItemId);
      await _loadCart();
    } catch (error) {
      _showCartError(error);
    }
  }

  Future<void> _decreaseQuantity(dynamic cartItemId) async {
    try {
      await CartService.decreaseQuantity(cartItemId);
      await _loadCart();
    } catch (error) {
      _showCartError(error);
    }
  }

  Future<void> _removeItem(dynamic cartItemId) async {
    try {
      await CartService.removeFromCart(cartItemId);
      await _loadCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showCartError(error);
    }
  }

  void _showCartError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cart operation failed: $error'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearCart() async {
    if (_cartItems.isEmpty) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear Cart?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await CartService.clearCart();
    await _loadCart();
  }

  double _getPrice(Map<String, dynamic> item) {
    final price = item['price'];

    if (price is num) {
      return price.toDouble();
    }

    return double.tryParse(price?.toString() ?? '0') ?? 0;
  }

  int _getQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'];

    if (quantity is num) {
      return quantity.toInt();
    }

    return int.tryParse(quantity?.toString() ?? '1') ?? 1;
  }

  double get _subtotal {
    double total = 0;

    for (final item in _cartItems) {
      total += _getPrice(item) * _getQuantity(item);
    }

    return total;
  }

  double get _deliveryFee {
    if (_cartItems.isEmpty) {
      return 0;
    }

    return 0;
  }

  double get _total {
    return _subtotal + _deliveryFee;
  }

  int get _totalItems {
    int total = 0;

    for (final item in _cartItems) {
      total += _getQuantity(item);
    }

    return total;
  }

  String _formatPrice(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: _buildAppBar(),

      // ==========================================================
      // FULL CART BODY WITH SANGAM LOGO BACKGROUND
      // ==========================================================

      body: Stack(
        children: [
          // --------------------------------------------------------
          // ORIGINAL CART CONTENT
          // --------------------------------------------------------

          _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          )
              : _cartItems.isEmpty
              ? _buildEmptyCart()
              : RefreshIndicator(
            color: primaryGreen,
            onRefresh: _loadCart,
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                final bool isDesktop =
                    constraints.maxWidth >= 900;

                if (isDesktop) {
                  return _buildDesktopCart(constraints);
                }

                return _buildMobileCart();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // APP BAR
  // ==============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: darkGreen,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 18,
      title: Row(
        children: [
          // --------------------------------------------------------
          // BACK BUTTON
          // --------------------------------------------------------

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () {
                Navigator.of(context).maybePop();
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: darkGreen,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          // --------------------------------------------------------
          // SANGAM LOGO
          // --------------------------------------------------------

          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD9E8DD),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/sangam_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                    ) {
                  return const Icon(
                    Icons.storefront_rounded,
                    color: primaryGreen,
                    size: 26,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 13),

          // --------------------------------------------------------
          // TITLE
          // --------------------------------------------------------

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Freshness packed for you',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        if (_cartItems.isNotEmpty)
          TextButton.icon(
            onPressed: _clearCart,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: Colors.redAccent,
            ),
            label: const Text(
              'Clear',
              style: TextStyle(
                color: textGrey,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==============================================================
  // DESKTOP CART
  // ==============================================================

  Widget _buildDesktopCart(BoxConstraints constraints) {
    final double horizontalPadding =
    constraints.maxWidth >= 1400 ? 70.0 : 35.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        45,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1300,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartHeading(),
                    const SizedBox(height: 18),
                    ..._cartItems.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: _buildCartItem(item),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 28),

              SizedBox(
                width: 360,
                child: _buildOrderSummary(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // MOBILE CART
  // ==============================================================

  Widget _buildMobileCart() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        30,
      ),
      children: [
        _buildCartHeading(),

        const SizedBox(height: 16),

        ..._cartItems.map(
              (item) => Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _buildCartItem(item),
          ),
        ),

        const SizedBox(height: 8),

        _buildOrderSummary(),
      ],
    );
  }

  // ==============================================================
  // CART HEADING
  // ==============================================================

  Widget _buildCartHeading() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_totalItems ${_totalItems == 1 ? 'item' : 'items'} selected',
                style: const TextStyle(
                  fontSize: 13,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: primaryGreen,
                size: 17,
              ),
              SizedBox(width: 6),
              Text(
                'Fresh Delivery',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // CART ITEM
  // ==============================================================

  Widget _buildCartItem(
      Map<String, dynamic> item,
      ) {
    final String name =
        item['name']?.toString() ?? 'Product';

    final dynamic cartItemId = item['id'];

    final String image =
        item['image']?.toString() ?? '';

    final String packSize =
        item['packSize']?.toString() ?? '';

    final double price = _getPrice(item);

    final int quantity = _getQuantity(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.96,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE6EDE7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          _buildProductImage(image),

          const SizedBox(width: 15),

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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                if (packSize.isNotEmpty &&
                    packSize != '-')
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Text(
                      packSize,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textGrey,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      _formatPrice(price),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(width: 6),

                    const Text(
                      'per pack',
                      style: TextStyle(
                        fontSize: 10,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            children: [
              _buildQuantityControl(
                cartItemId: cartItemId,
                quantity: quantity,
              ),

              const SizedBox(height: 7),

              InkWell(
                borderRadius:
                BorderRadius.circular(10),
                onTap: () =>
                    _removeItem(cartItemId),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PRODUCT IMAGE
  // ==============================================================

  Widget _buildProductImage(
      String image,
      ) {
    return Container(
      width: 92,
      height: 105,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F5),
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: image.isEmpty
          ? const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      )
          : Image.asset(
        image,
        fit: BoxFit.contain,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 32,
          );
        },
      ),
    );
  }

  // ==============================================================
  // QUANTITY CONTROL
  // ==============================================================

  Widget _buildQuantityControl({
    required dynamic cartItemId,
    required int quantity,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD5E8D9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove_rounded,
            onTap: () =>
                _decreaseQuantity(
                  cartItemId,
                ),
          ),

          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w900,
                  color: darkGreen,
                ),
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.add_rounded,
            onTap: () =>
                _increaseQuantity(
                  cartItemId,
                ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // QUANTITY BUTTON
  // ==============================================================

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 36,
          child: Icon(
            icon,
            size: 17,
            color: primaryGreen,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // ORDER SUMMARY
  // ==============================================================

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(
              alpha: 0.16,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$_totalItems items in your cart',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 22),

          _summaryRow(
            'Subtotal',
            _formatPrice(_subtotal),
          ),

          const SizedBox(height: 13),

          _summaryRow(
            'Delivery',
            _deliveryFee == 0
                ? 'FREE'
                : _formatPrice(
              _deliveryFee,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18,
            ),
            child: Divider(
              color: Colors.white24,
              height: 1,
            ),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Text(
                _formatPrice(_total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),

                SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Fresh dairy products delivered safely to your doorstep.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.4,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _goToCheckout,
              style:
              ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor:
                Colors.white,
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  SizedBox(width: 8),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SUMMARY ROW
  // ==============================================================

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

  // ==============================================================
  // EMPTY CART
  // ==============================================================

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 470,
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                    const Color(0xFFD7EBD9),
                    width: 5,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 58,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Your cart is empty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                  FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Looks like you haven’t added anything yet.\nExplore our fresh dairy products and add your favourites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: textGrey,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.storefront_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryGreen,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 24,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        15,
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
  }

  // ==============================================================
  // CHECKOUT
  // ==============================================================

  Future<void> _goToCheckout() async {
    if (_cartItems.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const CheckoutScreen(),
      ),
    );

    if (!mounted) return;

    await _loadCart();
  }
}

