import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/product_api_service.dart';
import '../../services/cart_service.dart';
import '../categories/categories_screen.dart';
import '../categories/category_products_screen.dart';
import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import '../product/product_details_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../search/search_explore_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../offers/offers_deals_screen.dart';
import '../rewards/rewards_coupons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  // CONTROLLERS
  // ============================================================

  final TextEditingController _searchController =
  TextEditingController();

  final PageController _bannerController =
  PageController();

  Timer? _bannerTimer;

  // ============================================================
  // STATE
  // ============================================================

  int _currentBanner = 0;

  int _selectedBottomIndex = 0;

  List<Map<String, dynamic>> _apiProducts = [];

  bool _productsLoading = true;

  // ============================================================
  // BANNERS
  // ============================================================

  final List<Map<String, dynamic>> _banners = [
    {
      'image': 'assets/images/sangam_milk_collection.png',
      'title': 'Fresh Dairy. Every Day.',
      'subtitle': 'Pure goodness delivered fresh to your home.',
      'button': 'Shop Now',
    },
    {
      'image': 'assets/images/sangam_dairy_products.png',
      'title': 'Quality You Can Trust',
      'subtitle': 'Fresh dairy products made with care.',
      'button': 'Explore',
    },
    {
      'image': 'assets/images/sangam_farm.png',
      'title': 'From Farm to Family',
      'subtitle': 'Natural freshness from Sangam Dairy.',
      'button': 'Discover',
    },
  ];

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Milk',
      'image': 'assets/images/milk/fcm_gold_plus_milk.png',
    },
    {
      'name': 'Milk Products',
      'image': 'assets/images/milkproducts/sangam_paneer.png',
    },
    {
      'name': 'Sweets',
      'image': 'assets/images/sweets/gulabjamun.png',
    },
    {
      'name': 'Drinks',
      'image': 'assets/images/drinks/sangam_orange.png',
    },
    {
      'name': 'Savories',
      'image': 'assets/images/savories/kara_boondi.png',
    },
    {
      'name': 'Spices',
      'image': 'assets/images/spieces/chilli_powder.png',
    },
    {
      'name': 'Other Products',
      'image': 'assets/images/other_products/badam_powder.png',
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startBannerTimer();
    _loadProducts();
  }

  // ============================================================
// LOAD / REFRESH PRODUCTS FROM BACKEND
// ============================================================

  Future<void> _loadProducts() async {
    try {
      final products = await ProductApiService.getProducts();

      if (!mounted) return;

      setState(() {
        _apiProducts = products;
        _productsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        // Keep the previous products if refresh fails.
        _productsLoading = false;
      });

      debugPrint('Product refresh failed: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'Unable to refresh products. Please try again.',
          ),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: _loadProducts,
          ),
        ),
      );
    }
  }

// ============================================================
// OPEN PRODUCT AND REFRESH HOME WHEN RETURNING
// ============================================================

  // ============================================================
  // BANNER TIMER
  // ============================================================

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!_bannerController.hasClients) {
          return;
        }

        int nextPage = _currentBanner + 1;

        if (nextPage >= _banners.length) {
          nextPage = 0;
        }

        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<Map<String, dynamic>> get _filteredProducts {
    final activeProducts = _apiProducts
        .where(ProductApiService.isActiveProduct)
        .toList();

    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return activeProducts;
    }

    return activeProducts.where((product) {
      final name =
          product['name']?.toString().toLowerCase() ?? '';

      final category =
          product['category']?.toString().toLowerCase() ?? '';

      return name.contains(query) ||
          category.contains(query);
    }).toList();
  }

  // ============================================================
  // OPEN CATEGORY
  // ============================================================

  void _openCategory(String categoryName) {
    if (categoryName.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: categoryName,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN PRODUCT
  // ============================================================

  Future<void> _openProduct(Map<String, dynamic> product) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );

    if (!mounted) return;

    await _loadProducts();
  }
  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> _showCartMessage(
      Map<String, dynamic> product,
      ) async {
    await CartService.addToCart(product);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product['name']} added to cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: orange,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onBottomNavigation(int index) {
    if (index == 0) {
      setState(() {
        _selectedBottomIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CartScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: pageBackground,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: primaryGreen,
                    onRefresh: _loadProducts,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeader(),
                        ),

                        SliverToBoxAdapter(
                          child: _buildSearchHeader(
                            products.length,
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: _buildBannerSlider(),
                        ),

                        SliverToBoxAdapter(
                          child: _buildQuickFeatures(),
                        ),

                        SliverToBoxAdapter(
                          child: _buildShopByCategory(),
                        ),

                        // SUBSCRIPTION
                        SliverToBoxAdapter(
                          child: _buildSubscriptionCard(),
                        ),

                        // OFFERS & DEALS
                        SliverToBoxAdapter(
                          child: _buildOffersCard(),
                        ),

                        // REWARDS & GIFT CARDS (COMING SOON)
                        SliverToBoxAdapter(
                          child: _buildRewardsAndCouponsCard(),
                        ),

                        // ALL PRODUCTS HEADER
                        SliverToBoxAdapter(
                          child: _buildAllProductsHeader(
                            products.length,
                          ),
                        ),

                        // LOADING / PRODUCT GRID
                        if (_productsLoading)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 45,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              18,
                              0,
                              18,
                              35,
                            ),
                            sliver: _buildProductGrid(products),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          // LOGO
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
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
                  Icons.water_drop_rounded,
                  color: primaryGreen,
                  size: 28,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // BRAND
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sangam Dairy',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Freshness you can trust',
                  style: TextStyle(
                    fontSize: 11,
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // NOTIFICATIONS
          _headerIconButton(
            icon: Icons.notifications_none_rounded,
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

          const SizedBox(width: 8),

          // WISHLIST
          _headerIconButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WishlistScreen(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // CART
          _headerIconButton(
            icon: Icons.shopping_cart_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER ICON
  // ============================================================

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: pageBackground,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE3EAE4),
            ),
          ),
          child: Icon(
            icon,
            color: darkGreen,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchHeader(int productCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: pageBackground,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFE2EAE3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const SearchExploreScreen(),
                  ),
                );
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: primaryGreen,
                ),
                hintText:
                'Search milk, sweets, dairy products...',
                hintStyle: TextStyle(
                  color: textGrey,
                  fontSize: 12,
                ),
                suffixIcon: Icon(
                  Icons.tune_rounded,
                  color: textGrey,
                  size: 20,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  Widget _buildBannerSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 205,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBanner = index;
                });
              },
              itemBuilder: (
                  context,
                  index,
                  ) {
                final banner = _banners[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius:
                    BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withValues(
                          alpha: 0.13,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          banner['image'].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return const SizedBox();
                          },
                        ),
                      ),

                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                darkGreen.withValues(
                                  alpha: 0.93,
                                ),
                                darkGreen.withValues(
                                  alpha: 0.62,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.all(24),
                        child: Align(
                          alignment:
                          Alignment.centerLeft,
                          child: SizedBox(
                            width: 330,
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: orange
                                        .withValues(
                                      alpha: 0.95,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      20,
                                    ),
                                  ),
                                  child: const Text(
                                    'SANGAM FRESH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight:
                                      FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  banner['title'].toString(),
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style:
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.1,
                                    fontWeight:
                                    FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  banner['subtitle']
                                      .toString(),
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style:
                                  const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(
                                  height: 13,
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 15,
                                    vertical: 9,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      12,
                                    ),
                                  ),
                                  child: Text(
                                    banner['button']
                                        .toString(),
                                    style:
                                    const TextStyle(
                                      color: darkGreen,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
                  (index) {
                final active =
                    index == _currentBanner;

                return AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 220),
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? primaryGreen
                        : const Color(0xFFC9D5CB),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK FEATURES
  // ============================================================

  Widget _buildQuickFeatures() {
    final features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Fresh Delivery',
        'subtitle': 'Delivered with care',
      },
      {
        'icon': Icons.verified_outlined,
        'title': 'Quality Assured',
        'subtitle': 'Trusted products',
      },
      {
        'icon': Icons.eco_outlined,
        'title': 'Pure & Fresh',
        'subtitle': 'Every single day',
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'Easy Support',
        'subtitle': 'We are here for you',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        4,
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final isDesktop =
              constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: features
                  .map(
                    (feature) => Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.only(
                      right: 10,
                    ),
                    child: _featureCard(
                      icon: feature['icon']
                      as IconData,
                      title: feature['title']
                          .toString(),
                      subtitle: feature['subtitle']
                          .toString(),
                    ),
                  ),
                ),
              )
                  .toList(),
            );
          }

          return SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: features.length,
              separatorBuilder: (
                  context,
                  index,
                  ) =>
              const SizedBox(width: 10),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final feature =
                features[index];

                return SizedBox(
                  width: 185,
                  child: _featureCard(
                    icon:
                    feature['icon'] as IconData,
                    title:
                    feature['title'].toString(),
                    subtitle:
                    feature['subtitle'].toString(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FEATURE CARD
  // ============================================================

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
        ),
      ),
      child: Row(
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

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 9,
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
  // SHOP BY CATEGORY
  // ============================================================

  Widget _buildShopByCategory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        25,
        18,
        0,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop by Category',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Explore all Sangam Dairy products',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const CategoriesScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildCategoryList(),
        ],
      ),
    );
  }

  // ============================================================
  // SUBSCRIPTION CARD
  // ============================================================

  Widget _buildSubscriptionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        25,
        18,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const SubscriptionsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  darkGreen,
                  primaryGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withValues(
                    alpha: 0.14,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration:
                        BoxDecoration(
                          color: orange.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Text(
                          'SANGAM SUBSCRIPTION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Fresh milk,\nwithout the daily hassle.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          height: 1.15,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        'Choose your milk, quantity & delivery frequency.',
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white
                              .withValues(
                            alpha: 0.82,
                          ),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Text(
                              'START SUBSCRIPTION',
                              style: TextStyle(
                                color: darkGreen,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color:
                              primaryGreen,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: Colors.white,
                    size: 43,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OFFERS & DEALS CARD
  // ============================================================

  Widget _buildOffersCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const OffersDealsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF4D9),
                  Colors.white,
                ],
              ),
              borderRadius:
              BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF0DFB5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                // OFFER ICON
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: orange.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: orange,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 15),

                // TEXT
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offers & Deals',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 19,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Discover special prices on Sangam favourites.',
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 9),
                      Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            'VIEW DEALS',
                            style: TextStyle(
                              color: primaryGreen,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            color: primaryGreen,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // OFFER BADGE
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '10%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REWARDS & GIFT CARDS CARD (COMING SOON)
  // ============================================================

  Widget _buildRewardsAndCouponsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const RewardsCouponsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Colors.white,
                ],
              ),
              borderRadius:
              BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFC8E6C9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                // ICON
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: primaryGreen,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 15),

                // TEXT
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rewards & Gift Cards',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Unlock loyalty points & redeem gift coupons.',
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 9),
                      Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            'COMING SOON',
                            style: TextStyle(
                              color: orange,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: orange,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // BADGE
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY LIST
  // ============================================================

  Widget _buildCategoryList() {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width = constraints.maxWidth;

        if (width >= 1200) {
          return GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 14,
              mainAxisSpacing: 10,
              mainAxisExtent: 125,
            ),
            itemBuilder: (
                context,
                index,
                ) {
              return _categoryCard(
                _categories[index],
              );
            },
          );
        }

        return SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (
                context,
                index,
                ) =>
            const SizedBox(width: 12),
            itemBuilder: (
                context,
                index,
                ) {
              return SizedBox(
                width: 105,
                child: _categoryCard(
                  _categories[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard(
      Map<String, dynamic> category,
      ) {
    final name =
        category['name']?.toString() ?? '';

    final image =
        category['image']?.toString() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openCategory(name);
        },
        borderRadius:
        BorderRadius.circular(20),
        child: Container(
          padding:
          const EdgeInsets.fromLTRB(
            8,
            8,
            8,
            7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              const Color(0xFFE2E9E3),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                    color: pageBackground,
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                  padding:
                  const EdgeInsets.all(7),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Icon(
                        Icons.image_outlined,
                        color: textGrey,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ALL PRODUCTS HEADER
  // ============================================================

  Widget _buildAllProductsHeader(
      int count,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        28,
        18,
        14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'All Products',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Everything fresh from Sangam Dairy',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              '$count items',
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  Widget _buildProductGrid(
      List<Map<String, dynamic>> products,
      ) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(35),
          child: const Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: textGrey,
                ),
                SizedBox(height: 10),
                Text(
                  'No products found',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Try searching for another product.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            MediaQuery.of(context).size.width;

        int columns;

        if (width >= 1400) {
          columns = 6;
        } else if (width >= 1100) {
          columns = 5;
        } else if (width >= 800) {
          columns = 4;
        } else if (width >= 600) {
          columns = 3;
        } else {
          columns = 2;
        }

        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (
                context,
                index,
                ) {
              return _ProductGridCard(
                product: products[index],
                onTap: () {
                  _openProduct(
                    products[index],
                  );
                },
                onAdd: () {
                  _showCartMessage(
                    products[index],
                  );
                },
              );
            },
            childCount: products.length,
          ),
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent:
            width < 600 ? 255 : 275,
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            10,
            7,
            10,
            7,
          ),
          child: Row(
            children: [
              _bottomNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
              ),
              _bottomNavItem(
                index: 1,
                icon: Icons.grid_view_rounded,
                label: 'Categories',
              ),
              _bottomNavItem(
                index: 2,
                icon:
                Icons.shopping_cart_outlined,
                label: 'Cart',
              ),
              _bottomNavItem(
                index: 3,
                icon:
                Icons.receipt_long_outlined,
                label: 'Orders',
              ),
              _bottomNavItem(
                index: 4,
                icon:
                Icons.person_outline_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAV ITEM
  // ============================================================

  Widget _bottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected =
        _selectedBottomIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          _onBottomNavigation(index);
        },
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 3,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                width: 68,
                height: 34,
                decoration:
                BoxDecoration(
                  color: selected
                      ? lightGreen
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? darkGreen
                      : const Color(
                    0xFF536057,
                  ),
                  size: 21,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? darkGreen
                      : const Color(
                    0xFF536057,
                  ),
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT GRID CARD
// ============================================================================

class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductGridCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  static const Color primaryGreen =
  Color(0xFF087A35);

  static const Color darkGreen =
  Color(0xFF173B20);

  static const Color pageBackground =
  Color(0xFFF6F9F6);

  static const Color textGrey =
  Color(0xFF69736B);

  double _getPrice() {
    final value = product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '0',
    ) ??
        0;
  }

  String _formatPrice() {
    return '₹${_getPrice().toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final name =
        product['name']?.toString() ??
            'Product';

    final image =
        product['image']?.toString() ??
            '';

    final packSize =
        product['packSize']?.toString() ??
            '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              const Color(0xFFE0E8E1),
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration:
                    BoxDecoration(
                      color: pageBackground,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                    padding:
                    const EdgeInsets.all(8),
                    child: Image.asset(
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
                          color: textGrey,
                          size: 35,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  name,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                if (packSize.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    packSize,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      color: textGrey,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 7),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatPrice(),
                        style:
                        const TextStyle(
                          color: primaryGreen,
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: onAdd,
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration:
                        BoxDecoration(
                          color:
                          primaryGreen,
                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons.add_rounded,
                          color:
                          Colors.white,
                          size: 21,
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

