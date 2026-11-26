import 'package:flutter/material.dart';

import '../../services/product_api_service.dart';
import '../product/product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color pageBackground = Color(0xFFF6F9F6);

  List<Map<String, dynamic>> products = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategoryProducts();
  }

  // ==========================================================
  // LOAD PRODUCTS FROM BACKEND
  // ==========================================================

  Future<void> _loadCategoryProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> loadedProducts =
      await ProductApiService.getProductsByCategory(
        widget.categoryName,
      );

      if (!mounted) return;

      setState(() {
        products = loadedProducts
            .where(ProductApiService.isActiveProduct)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        products = [];
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Stack(
        children: [
          // ========================================================
          // LOADING
          // ========================================================

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            )

          // ========================================================
          // ERROR
          // ========================================================

          else if (errorMessage != null)
            _buildErrorState()

          // ========================================================
          // EMPTY
          // ========================================================

          else if (products.isEmpty)
              _buildEmptyState()

            // ========================================================
            // PRODUCTS
            // ========================================================

            else
              LayoutBuilder(
                builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                    ) {
                  final double width = constraints.maxWidth;

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

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      30,
                    ),
                    itemCount: products.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio:
                      width >= 600 ? 0.68 : 0.62,
                    ),
                    itemBuilder: (
                        BuildContext context,
                        int index,
                        ) {
                      final Map<String, dynamic> product =
                      products[index];

                      return _CategoryProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ProductDetailsScreen(
                                  product: product,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: primaryGreen.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load products',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your backend connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadCategoryProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 60,
            color: primaryGreen.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          const Text(
            'No products available',
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CATEGORY PRODUCT CARD
// ============================================================================

class _CategoryProductCard extends StatelessWidget {
  const _CategoryProductCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);

  // ==========================================================
  // DISPLAY IMAGE
  // ==========================================================

  String _getDisplayImage() {
    final dynamic variantsData = product['variants'];

    if (variantsData is List && variantsData.isNotEmpty) {
      for (final variant in variantsData) {
        if (variant is Map) {
          final dynamic variantImage = variant['image'];

          if (variantImage != null &&
              variantImage.toString().trim().isNotEmpty) {
            return variantImage.toString();
          }
        }
      }
    }

    return product['image']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        product['name']?.toString() ?? '';

    final String image = _getDisplayImage();

    final String packSize =
        product['packSize']?.toString() ?? '';

    final num price = product['price'] is num
        ? product['price'] as num
        : num.tryParse(
      product['price']?.toString() ?? '',
    ) ??
        0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE1EAE3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF7),
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: image.isEmpty
                      ? const Center(
                    child: Icon(
                      Icons
                          .image_not_supported_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                  )
                      : Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                        ) {
                      return const Center(
                        child: Icon(
                          Icons
                              .image_not_supported_outlined,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    },
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
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
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
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              // ==================================================
              // PRICE
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '₹$price',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
