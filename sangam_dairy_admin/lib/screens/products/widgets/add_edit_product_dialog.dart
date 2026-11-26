import 'package:flutter/material.dart';
import '../../../models/product.dart';

class AddEditProductDialog extends StatefulWidget {
  final Product? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _packSizeController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Milk';
  bool _active = true;

  final List<String> _categories = [
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
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _packSizeController = TextEditingController(text: p?.packSize ?? '500 ML');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '35');
    _stockController = TextEditingController(text: p != null ? p.stockQuantity.toString() : '100');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    if (p != null) {
      if (_categories.contains(p.category)) {
        _selectedCategory = p.category;
      } else {
        _selectedCategory = 'Milk';
      }
      _active = p.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _packSizeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 50;

    final product = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      packSize: _packSizeController.text.trim(),
      price: price,
      stockQuantity: stock,
      description: _descriptionController.text.trim(),
      active: _active,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Product' : 'Add New Sangam Dairy Product',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172D1E),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Product Name
                const Text('Product Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Sangam Special Buffalo Ghee',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Category & Pack Size in Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(),
                            items: _categories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pack Size *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _packSizeController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 500 ML / 200 GM',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Pack size required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price & Stock Quantity
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (₹) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 60',
                              prefixText: '₹ ',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Price required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stock Quantity *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 100',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Stock required';
                              if (int.tryParse(v) == null) return 'Invalid integer';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Product Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Short summary of the product benefits & ingredients...',
                  ),
                ),
                const SizedBox(height: 16),

                // Status Switch
                SwitchListTile(
                  title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Enable or disable this product in customer app'),
                  value: _active,
                  activeColor: brandGreen,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _active = val),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: brandGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.add_circle, size: 18),
                      label: Text(isEditing ? 'Save Changes' : 'Create Product'),
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
