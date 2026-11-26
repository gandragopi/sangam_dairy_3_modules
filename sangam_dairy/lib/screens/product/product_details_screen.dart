import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../../services/product_api_service.dart';
import '../../services/wishlist_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFFFFCF5);
  static const Color orange = Color(0xFFF28C28);

  // ============================================================
  // STATE
  // ============================================================

  int quantity = 1;

  bool isWishlisted = false;
  bool wishlistLoading = true;
  bool cartLoading = false;

  int selectedVariantIndex = 0;

  late Map<String, dynamic> _currentProduct;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _loadWishlistStatus();
    _refreshProductDetails();
  }

  Future<void> _refreshProductDetails() async {
    try {
      final dynamic id = widget.product['id'];
      Map<String, dynamic>? updated;

      if (id != null) {
        final parsedId = id is int ? id : int.tryParse(id.toString());
        if (parsedId != null) {
          updated = await ProductApiService.getProductById(parsedId);
        }
      }

      if (updated == null) {
        final String productName = widget.product['name']?.toString().trim() ?? '';
        if (productName.isNotEmpty) {
          final allProducts = await ProductApiService.getProducts();
          final match = allProducts.firstWhere(
            (p) => p['name']?.toString().trim().toLowerCase() == productName.toLowerCase(),
            orElse: () => widget.product,
          );
          updated = match;
        }
      }

      if (!mounted) return;
      if (updated != null) {
        setState(() {
          _currentProduct = updated!;
        });
      }
    } catch (_) {}
  }

  Map<String, dynamic> get product => _currentProduct;

  // ============================================================
  // VARIANTS
  // ============================================================

  List<Map<String, dynamic>> get variants {
    final value = product['variants'];

    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (variant) => Map<String, dynamic>.from(variant),
    )
        .toList();
  }

  bool get hasVariants {
    return variants.isNotEmpty;
  }

  Map<String, dynamic>? get selectedVariant {
    if (!hasVariants) {
      return null;
    }

    if (selectedVariantIndex < 0 ||
        selectedVariantIndex >= variants.length) {
      return variants.first;
    }

    return variants[selectedVariantIndex];
  }

  String get selectedImage {
    final variant = selectedVariant;

    if (variant != null) {
      final image = variant['image']?.toString();

      if (image != null && image.trim().isNotEmpty) {
        return image;
      }
    }

    return product['image']?.toString() ?? '';
  }

  String get selectedPackSize {
    final variant = selectedVariant;

    if (variant != null) {
      final packSize = variant['packSize']?.toString();

      if (packSize != null && packSize.trim().isNotEmpty) {
        return packSize;
      }

      final label = variant['label']?.toString();

      if (label != null && label.trim().isNotEmpty) {
        return label;
      }
    }

    return product['packSize']?.toString() ?? '-';
  }

  double get selectedPrice {
    final variant = selectedVariant;

    if (variant != null) {
      if (selectedVariantIndex == 0) {
        return price;
      }

      if (variant['price'] is num) {
        return (variant['price'] as num).toDouble();
      }
    }

    return price;
  }

  // ============================================================
  // LOAD SAVED WISHLIST STATUS
  // ============================================================

  Future<void> _loadWishlistStatus() async {
    final saved = await WishlistService.isWishlisted(
      product,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isWishlisted = saved;
      wishlistLoading = false;
    });
  }

  // ============================================================
  // TOGGLE WISHLIST
  // ============================================================

  Future<void> _toggleWishlist() async {
    if (wishlistLoading) {
      return;
    }

    setState(() {
      wishlistLoading = true;
    });

    final saved = await WishlistService.toggleWishlist(
      product,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isWishlisted = saved;
      wishlistLoading = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Added to Wishlist ❤️'
              : 'Removed from Wishlist',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // PRODUCT VALUES
  // ============================================================

  String _value(String key) {
    if (key == 'packSize' && hasVariants) {
      return selectedPackSize;
    }

    final variant = selectedVariant;

    if (variant != null) {
      final variantValue = variant[key];

      if (variantValue != null) {
        final variantText = variantValue.toString().trim();

        if (variantText.isNotEmpty) {
          return variantText;
        }
      }
    }

    final value = product[key];

    if (value == null) {
      return '-';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '-';
    }

    return text;
  }

  // ============================================================
  // PRICE
  // ============================================================

  double get price {
    final value = product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  double get totalPrice {
    return selectedPrice * quantity;
  }

  // ============================================================
  // BUILD SELECTED PRODUCT FOR CART
  // ============================================================

  Map<String, dynamic> get _cartProduct {
    final pMap = Map<String, dynamic>.from(
      product,
    );

    if (hasVariants) {
      pMap['image'] = selectedImage;
      pMap['packSize'] = selectedPackSize;

      final variant = selectedVariant;

      if (variant != null && variant['price'] is num) {
        pMap['price'] = variant['price'];
      }
    }

    return pMap;
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget _buildProductImage({
    required double width,
    required double height,
  }) {
    final imagePath = selectedImage;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: imagePath.isEmpty
            ? const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.grey,
          ),
        )
            : Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PACK / VARIANT SELECTOR
  // ============================================================

  Widget _buildVariantSelector() {
    if (!hasVariants) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Pack Sizes',
          style: TextStyle(
            color: darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: variants.length,
            separatorBuilder: (_, index) =>
            const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final variant = variants[index];

              final image =
                  variant['image']?.toString() ?? '';

              final label =
                  variant['label']?.toString() ??
                      variant['packSize']?.toString() ??
                      '-';

              final isSelected =
                  selectedVariantIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVariantIndex = index;
                    quantity = 1;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  width: 108,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? lightGreen
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : Colors.grey.withValues(
                        alpha: 0.15,
                      ),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withValues(
                          alpha: isSelected
                              ? 0.08
                              : 0.04,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: image.isEmpty
                            ? const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
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
                              Icons
                                  .image_not_supported_outlined,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? primaryGreen
                              : darkGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Swipe to view available packs',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _buildInfoItem(
      String title,
      String value, {
        int? maxLines,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            maxLines: maxLines,
            softWrap: true,
            overflow: maxLines == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT INFORMATION RESPONSIVE LAYOUT
  // ============================================================

  Widget _buildProductInformation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final double spacing = 12;

        final bool singleColumn = width < 560;

        final double itemWidth = singleColumn
            ? width
            : (width - spacing) / 2;

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildInfoItem(
                    'Fat',
                    _value('fat'),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: _buildInfoItem(
                    'SNF',
                    _value('snf'),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: _buildInfoItem(
                    'Pack Size',
                    _value('packSize'),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: _buildInfoItem(
                    'Shelf Life',
                    _value('shelfLife'),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: _buildInfoItem(
                    'Storage',
                    _value('storage'),
                  ),
                ),
              ],
            ),

            // ----------------------------------------------------
            // DESCRIPTION
            // Same design as Pack Size / Shelf Life / Storage
            // ----------------------------------------------------

            const SizedBox(height: 12),

            _buildInfoItem(
              'Description',
              _value('description'),
              maxLines: null,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  Widget _buildQuantitySelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1
                ? () {
              setState(() {
                quantity--;
              });
            }
                : null,
            icon: const Icon(
              Icons.remove,
              size: 19,
            ),
            color: primaryGreen,
          ),

          Text(
            '$quantity',
            style: const TextStyle(
              color: darkGreen,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                quantity++;
              });
            },
            icon: const Icon(
              Icons.add,
              size: 19,
            ),
            color: primaryGreen,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRUST ROW
  // ============================================================

  Widget _buildTrustRow() {
    return Row(
      children: [
        Expanded(
          child: _trustItem(
            Icons.verified_outlined,
            'Quality',
          ),
        ),

        Expanded(
          child: _trustItem(
            Icons.eco_outlined,
            'Fresh',
          ),
        ),

        Expanded(
          child: _trustItem(
            Icons.local_shipping_outlined,
            'Safe Delivery',
          ),
        ),
      ],
    );
  }

  Widget _trustItem(
      IconData icon,
      String text,
      ) {
    return Column(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: const BoxDecoration(
            color: lightGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 22,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  bool get isProductActive => ProductApiService.isActiveProduct(product);

  // ADD TO CART
  // ============================================================

  Future<void> _addToCart() async {
    if (cartLoading || !isProductActive) {
      if (!isProductActive && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This product is currently inactive and unavailable.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      cartLoading = true;
    });

    try {
      await CartService.addToCart(
        _cartProduct,
        quantity: quantity,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  '${product['name']}'
                      '${hasVariants ? ' - $selectedPackSize' : ''}'
                      ' added to cart',
                ),
              ),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to add product to cart. Please try again.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cartLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PRODUCT CONTENT
  // ============================================================

  Widget _buildProductContent() {
    final productName =
        product['name']?.toString() ??
            'Product';

    final category =
        product['category']?.toString() ??
            'Dairy';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // ========================================================
        // CATEGORY
        // ========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
            BorderRadius.circular(30),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ========================================================
        // NAME
        // ========================================================

        Text(
          productName,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // RATING
        // ========================================================

        Row(
          children: [
            ...List.generate(
              5,
                  (index) => const Icon(
                Icons.star_rounded,
                color: orange,
                size: 20,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '4.5',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ========================================================
        // PRICE
        // ========================================================

        Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Text(
              '₹${selectedPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              'per pack',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ========================================================
        // PACK SELECTOR
        // ========================================================

        _buildVariantSelector(),

        if (hasVariants)
          const SizedBox(height: 22),

        // ========================================================
        // DELIVERY
        // ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: primaryGreen.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: primaryGreen,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fresh Delivery',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Delivered fresh to your doorstep',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // ========================================================
        // PRODUCT INFORMATION
        // ========================================================

        const Text(
          'Product Information',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 14),

        // IMPORTANT:
        // Wrap is used instead of GridView.count.
        // This allows Shelf Life / Description to grow naturally.
        _buildProductInformation(),

        const SizedBox(height: 28),

        // ========================================================
        // QUANTITY
        // ========================================================

        Row(
          children: [
            const Expanded(
              child: Text(
                'Quantity',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            _buildQuantitySelector(),
          ],
        ),

        const SizedBox(height: 22),

        // ========================================================
        // TOTAL
        // ========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: cream,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '₹${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // ADD TO CART
        // ========================================================

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: (cartLoading || !isProductActive) ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: isProductActive ? primaryGreen : Colors.grey,
              disabledBackgroundColor: isProductActive
                  ? primaryGreen.withValues(alpha: 0.65)
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: cartLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isProductActive
                        ? Icons.shopping_bag_outlined
                        : Icons.block_outlined,
                  ),
            label: Text(
              cartLoading
                  ? 'Adding...'
                  : (!isProductActive
                      ? 'Currently Inactive'
                      : 'Add to Cart'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // TRUST
        // ========================================================

        _buildTrustRow(),
      ],
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 10,
        bottom: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 22,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // PRODUCT IMAGE
                // ==================================================

                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      _buildProductImage(
                        width: double.infinity,
                        height: 520,
                      ),

                      Positioned(
                        top: 18,
                        right: 18,
                        child:
                        _buildWishlistButton(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 48),

                // ==================================================
                // PRODUCT DETAILS
                // ==================================================

                Expanded(
                  flex: 5,
                  child: _buildProductContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        30,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildProductImage(
                width: double.infinity,
                height: 330,
              ),

              Positioned(
                top: 14,
                right: 14,
                child: _buildWishlistButton(),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildProductContent(),
        ],
      ),
    );
  }

  // ============================================================
  // WISHLIST BUTTON
  // ============================================================

  Widget _buildWishlistButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: _toggleWishlist,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: wishlistLoading
                ? const SizedBox(
              width: 19,
              height: 19,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryGreen,
              ),
            )
                : Icon(
              isWishlisted
                  ? Icons.favorite_rounded
                  : Icons
                  .favorite_border_rounded,
              color: isWishlisted
                  ? Colors.red
                  : darkGreen,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkGreen,
            size: 20,
          ),
        ),

        title: const Text(
          'Product Details',
          style: TextStyle(
            color: darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: false,

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: IconButton(
              onPressed: _toggleWishlist,
              icon: wishlistLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryGreen,
                ),
              )
                  : Icon(
                isWishlisted
                    ? Icons.favorite_rounded
                    : Icons
                    .favorite_border_rounded,
                color: isWishlisted
                    ? Colors.red
                    : darkGreen,
              ),
            ),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          if (constraints.maxWidth >= 800) {
            return _buildDesktopLayout();
          }

          return _buildMobileLayout();
        },
      ),
    );
  }
}
