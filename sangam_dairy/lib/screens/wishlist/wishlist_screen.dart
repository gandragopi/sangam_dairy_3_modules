import 'package:flutter/material.dart';

import '../../services/wishlist_service.dart';
import '../product/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFFFFCF5);

  // ============================================================
  // STATE
  // ============================================================

  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWishlist();
  }

  // ============================================================
  // LOAD WISHLIST
  // ============================================================

  Future<void> _loadWishlist() async {
    final items = await WishlistService.getWishlist();

    if (!mounted) {
      return;
    }

    setState(() {
      wishlist = items;
      isLoading = false;
    });
  }

  // ============================================================
  // OPEN PRODUCT
  // ============================================================

  void _openProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  Future<void> _removeProduct(
      Map<String, dynamic> product,
      ) async {
    await WishlistService.removeFromWishlist(product);

    if (!mounted) {
      return;
    }

    setState(() {
      wishlist.removeWhere(
            (item) =>
        item['name']?.toString() ==
            product['name']?.toString(),
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from wishlist'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> _clearAll() async {
    if (wishlist.isEmpty) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear Wishlist?',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Remove all products from your wishlist?',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Clear All',
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    await WishlistService.clearWishlist();

    if (!mounted) {
      return;
    }

    setState(() {
      wishlist.clear();
    });
  }

  // ============================================================
  // CONTINUE SHOPPING
  // ============================================================

  void _continueShopping() {
    Navigator.pop(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkGreen,
            size: 21,
          ),
        ),
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      )
          : wishlist.isEmpty
          ? _buildEmptyWishlist()
          : RefreshIndicator(
        color: primaryGreen,
        onRefresh: _loadWishlist,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int crossAxisCount;

            if (width >= 1200) {
              crossAxisCount = 5;
            } else if (width >= 900) {
              crossAxisCount = 4;
            } else if (width >= 600) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }

            // ==================================================
            // FIXED CARD HEIGHT
            // ==================================================

            final double cardHeight =
            width >= 600 ? 380 : 365;

            return GridView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ),
              itemCount: wishlist.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                mainAxisExtent: cardHeight,
              ),
              itemBuilder: (context, index) {
                final product = wishlist[index];

                return _WishlistProductCard(
                  product: product,
                  onTap: () {
                    _openProduct(product);
                  },
                  onRemove: () {
                    _removeProduct(product);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY WISHLIST
  // ============================================================

  Widget _buildEmptyWishlist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: primaryGreen,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Your wishlist is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favourite Sangam Dairy products here and find them easily later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _continueShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WISHLIST PRODUCT CARD
// ============================================================================

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);

  @override
  Widget build(BuildContext context) {
    final String name =
        product['name']?.toString() ?? '';

    final String image =
        product['image']?.toString() ?? '';

    final String category =
        product['category']?.toString() ?? '';

    final String packSize =
        product['packSize']?.toString() ?? '';

    final num price = product['price'] is num
        ? product['price'] as num
        : 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE1EAE3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // IMAGE
                // ==================================================

                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBF8),
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Icon(
                              Icons
                                  .image_not_supported_outlined,
                              color: Colors.grey,
                              size: 40,
                            );
                          },
                        ),
                      ),

                      // ==================================================
                      // REMOVE / HEART
                      // ==================================================

                      Positioned(
                        top: 3,
                        right: 3,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: onRemove,
                            customBorder:
                            const CircleBorder(),
                            child: const SizedBox(
                              width: 43,
                              height: 43,
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CATEGORY
                // ==================================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PRODUCT NAME
                // ==================================================

                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 4),

                // ==================================================
                // PACK SIZE
                // ==================================================

                Text(
                  packSize,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // ==================================================
                // PRICE + ADD
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '₹$price',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: primaryGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onTap,
                      borderRadius:
                      BorderRadius.circular(9),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius:
                          BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
