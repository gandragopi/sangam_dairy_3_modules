import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_api_service.dart';
import 'widgets/add_edit_product_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductApiService _api = ProductApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _isGridView = false;

  final List<String> _categories = [
    'All',
    'Milk',
    'Curd',
    'Ghee',
    'Paneer',
    'Butter',
    'Sweets',
    'Beverages',
    'Flavoured Milk',
    'Ice Cream',
  ];

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
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.packSize.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      final matchesStatus = _selectedStatus == 'All' ||
          (_selectedStatus == 'Active' && product.active) ||
          (_selectedStatus == 'Inactive' && !product.active);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => const AddEditProductDialog(),
    );

    if (result != null) {
      final added = await _api.addProduct(result);
      if (!mounted) return;
      setState(() {
        _products.insert(0, added);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${added.name} created successfully!')),
      );
    }
  }

  Future<void> _openEditDialog(Product product) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (context) => AddEditProductDialog(product: product),
    );

    if (result != null) {
      final updated = await _api.updateProduct(result);
      if (!mounted) return;
      setState(() {
        final index = _products.indexWhere((p) => p.id == updated.id);
        if (index != -1) _products[index] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updated.name} updated!')),
      );
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _api.deleteProduct(product.id);
      if (!mounted) return;
      setState(() {
        _products.removeWhere((p) => p.id == product.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    final activeCount = _products.where((p) => p.active).length;
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action & Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products & Inventory',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172D1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage store dairy items, prices, pack sizes and availability.',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Refresh Products',
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh, color: brandGreen),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _openAddDialog,
                      style: FilledButton.styleFrom(
                        backgroundColor: brandGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Chips Row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statChip('Total Items', '${_products.length}', Icons.inventory_2_outlined, brandGreen),
                _statChip('Active Items', '$activeCount', Icons.check_circle_outline, Colors.teal),
                _statChip('Showing Results', '${filtered.length}', Icons.filter_list, Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 16),

            // Search and Filters Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE3)),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Search Box
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search product name, category...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                      ),
                    ),
                  ),

                  // Category Dropdown Filter
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        underline: const SizedBox(),
                        items: _categories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ],
                  ),

                  // Status Dropdown Filter
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ],
                  ),

                  // View Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Table View',
                          icon: Icon(
                            Icons.table_rows_outlined,
                            color: !_isGridView ? brandGreen : Colors.grey,
                          ),
                          onPressed: () => setState(() => _isGridView = false),
                        ),
                        IconButton(
                          tooltip: 'Grid View',
                          icon: Icon(
                            Icons.grid_view_outlined,
                            color: _isGridView ? brandGreen : Colors.grey,
                          ),
                          onPressed: () => setState(() => _isGridView = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products Content
            Expanded(
              child: _buildProductsContent(brandGreen, filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EBE3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProductsContent(Color brandGreen, List<Product> products) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: brandGreen));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Unable to fetch products', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No products found matching your search or filters.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          childAspectRatio: 0.82,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return _buildProductCard(brandGreen, p);
        },
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F8F5)),
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Pack Size', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: products.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text('#${product.id}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFE9F7EC),
                            child: Icon(Icons.local_drink_rounded, color: brandGreen, size: 15),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (product.description.isNotEmpty)
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    product.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(product.category)),
                    DataCell(Text(product.packSize)),
                    DataCell(Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(
                      Text(
                        '${product.stockQuantity} units',
                        style: TextStyle(
                          color: product.stockQuantity < 40 ? Colors.red.shade800 : Colors.black87,
                          fontWeight: product.stockQuantity < 40 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.active
                              ? const Color(0xFFE4F5E8)
                              : const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.active ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: product.active ? brandGreen : Colors.red.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                            tooltip: 'Edit',
                            onPressed: () => _openEditDialog(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(product),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Color brandGreen, Product product) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    color: brandGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.active ? const Color(0xFFE4F5E8) : const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  product.active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: product.active ? brandGreen : Colors.red.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: brandGreen.withValues(alpha: 0.10),
                child: Icon(Icons.local_drink_rounded, color: brandGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Pack Size: ${product.packSize}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isNotEmpty ? product.description : 'Authentic Sangam Dairy product.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandGreen),
                  ),
                  Text(
                    '${product.stockQuantity} in stock',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueAccent),
                    onPressed: () => _openEditDialog(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(product),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
