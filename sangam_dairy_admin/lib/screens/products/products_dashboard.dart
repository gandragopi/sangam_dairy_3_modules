import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_api_service.dart';

class ProductsDashboard extends StatefulWidget {
  const ProductsDashboard({super.key});

  @override
  State<ProductsDashboard> createState() => _ProductsDashboardState();
}

class _ProductsDashboardState extends State<ProductsDashboard> {
  final ProductApiService _api = ProductApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final products = await _api.getProducts();
      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) return _products;

    return _products.where((product) {
      final name = product.name.toLowerCase();
      final category = product.category.toLowerCase();

      return name.contains(query) || category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF087A35);
    final activeCount = _products.where((p) => p.active).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text(
          'Sangam Dairy | Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh products',
            onPressed: _loading ? null : _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Products Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173D27),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage products stored in your database.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _summaryCard(
                    'Total Products',
                    _loading ? '...' : '${_products.length}',
                    Icons.inventory_2_outlined,
                    green,
                  ),
                  _summaryCard(
                    'Active Products',
                    _loading ? '...' : '$activeCount',
                    Icons.check_circle_outline,
                    Colors.teal,
                  ),
                  _summaryCard(
                    'Search Results',
                    _loading ? '...' : '${_filteredProducts.length}',
                    Icons.search,
                    Colors.blueGrey,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _search = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by product name or category...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFDCE6DE),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _buildProductsContent(green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsContent(Color green) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Could not load products',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3EBE4)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4EC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Text(
              'Showing ${products.length} products',
              style: TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF5F8F5),
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Pack Size')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: products.map((product) {
                    final active = product.active;
                    final price = product.price;

                    return DataRow(
                      cells: [
                        DataCell(Text('${product.id}')),
                        DataCell(
                          SizedBox(
                            width: 190,
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(product.category),
                        ),
                        DataCell(
                          Text(product.packSize),
                        ),
                        DataCell(
                          Text('₹${price.toStringAsFixed(0)}'),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFE4F5E8)
                                  : const Color(0xFFFFE8E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              active ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: active
                                    ? green
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
