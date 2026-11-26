import 'package:flutter/material.dart';

import '../../data/products.dart';
import '../../services/product_api_service.dart';
import '../categories/category_products_screen.dart';
import '../product/product_details_screen.dart';

class SearchExploreScreen extends StatefulWidget {
  const SearchExploreScreen({super.key});

  @override
  State<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends State<SearchExploreScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  List<Map<String, dynamic>> _apiProducts = [];

  final List<String> _recentSearches = [
    'Full Cream Milk',
    'Paneer',
    'Ghee',
  ];

  final List<Map<String, String>> _categories = [
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
      'image': 'assets/images/drinks/mango_magic.png',
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

  final List<String> _trendingSearches = [
    'Milk',
    'Paneer',
    'Ghee',
    'Curd',
    'Buttermilk',
    'Sweets',
    'Milkshake',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _apiProducts = products
            .where(ProductApiService.isActiveProduct)
            .toList();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _searchResults {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final query = _searchQuery.toLowerCase();
    final sourceList = (_apiProducts.isNotEmpty ? _apiProducts : ProductsData.products)
        .where(ProductApiService.isActiveProduct)
        .toList();

    return sourceList.where((product) {
      final name =
          product['name']?.toString().toLowerCase() ?? '';

      final category =
          product['category']?.toString().toLowerCase() ?? '';

      return name.contains(query) || category.contains(query);
    }).toList();
  }

  void _searchFromText(String text) {
    final value = text.trim();

    if (value.isEmpty) return;

    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    _addRecentSearch(value);

    setState(() {});
  }

  void _addRecentSearch(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) return;

    setState(() {
      _recentSearches.removeWhere(
            (item) => item.toLowerCase() == cleaned.toLowerCase(),
      );

      _recentSearches.insert(0, cleaned);

      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _openCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: categoryName,
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Search & Explore',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'SANGAM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 18,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1180,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),

                      if (_searchQuery.isNotEmpty)
                        _buildSearchResults()
                      else
                        _buildExploreContent(),
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

  Widget _buildSearchBar() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _searchFocusNode.hasFocus
              ? primaryGreen
              : const Color(0xFFE1E8E2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 17),
          const Icon(
            Icons.search_rounded,
            color: primaryGreen,
            size: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: _searchFromText,
              decoration: const InputDecoration(
                hintText: 'Search milk, paneer, sweets, ghee...',
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                color: darkGreen,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.black45,
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildExploreContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recentSearches.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Recent Searches',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 12),
          _buildRecentSearches(),
          const SizedBox(height: 28),
        ],

        _buildSectionHeader(
          title: 'Trending Searches',
          icon: Icons.trending_up_rounded,
        ),
        const SizedBox(height: 12),
        _buildTrendingSearches(),
        const SizedBox(height: 30),

        _buildSectionHeader(
          title: 'Explore Categories',
          icon: Icons.grid_view_rounded,
        ),
        const SizedBox(height: 14),
        _buildCategories(),

        const SizedBox(height: 30),

        _buildDiscoverCard(),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(11),
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
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _recentSearches.map((search) {
        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            _searchFromText(search);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFDDE5DF),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 17,
                  color: Colors.black45,
                ),
                const SizedBox(width: 7),
                Text(
                  search,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendingSearches() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _trendingSearches.map((search) {
        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            _searchFromText(search);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: orange.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  size: 17,
                  color: orange,
                ),
                const SizedBox(width: 7),
                Text(
                  search,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategories() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCategoryColumns(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 170,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _openCategory(category['name']!);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE0E8E1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset(
                    category['image']!,
                    fit: BoxFit.contain,
                    errorBuilder: (_,_,_) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color: primaryGreen,
                        size: 35,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    category['name']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getCategoryColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Widget _buildDiscoverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087A35),
            Color(0xFF0D9B48),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Sangam Dairy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Fresh milk, dairy products, sweets and more.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              results.isEmpty
                  ? 'No products found'
                  : '${results.length} Products Found',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
            if (results.isNotEmpty)
              Text(
                '"$_searchQuery"',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (results.isEmpty)
          _buildNoResults()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getProductColumns(context),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 330,
            ),
            itemBuilder: (context, index) {
              return _buildProductCard(results[index]);
            },
          ),
      ],
    );
  }

  int _getProductColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final String name =
        product['name']?.toString() ?? 'Product';

    final String image =
        product['image']?.toString() ?? '';

    final String category =
        product['category']?.toString() ?? '';

    final double price =
        (product['price'] as num?)?.toDouble() ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _openProduct(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0E8E1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F8F4),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (_,_,_) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      color: primaryGreen,
                      size: 42,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: darkGreen,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius:
                          BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E8E2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: primaryGreen,
              size: 38,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'No products found',
            style: TextStyle(
              color: darkGreen,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Try searching for milk, sweets, ghee,\npaneer or another Sangam product.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: _clearSearch,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(
                color: primaryGreen,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Explore Categories',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
