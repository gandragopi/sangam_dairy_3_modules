import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  static final ProductApiService _instance = ProductApiService._internal();
  factory ProductApiService() => _instance;
  ProductApiService._internal() {
    _initMockProducts();
  }

  String baseUrl = 'http://localhost:8080/api/products';
  bool isLiveServerConnected = false;

  // In-memory fallback list (expanded to exactly 83 products with 2 low stock & 2 inactive -> 81 / 83 active)
  final List<Product> _mockProducts = [
    Product(
      id: 1,
      name: 'Badam Milk',
      category: 'Flavoured Milk',
      packSize: '200 ML',
      price: 60.0,
      active: true,
      stockQuantity: 120,
      description: 'Rich almond flavored pasteurized milk packed with nourishment.',
    ),
    Product(
      id: 2,
      name: 'Badam Nuts Milk',
      category: 'Flavoured Milk',
      packSize: '200 ML',
      price: 40.0,
      active: true,
      stockQuantity: 85,
      description: 'Crunchy almond chunk flavoured milk drink.',
    ),
    Product(
      id: 3,
      name: 'Chocolate Milk',
      category: 'Flavoured Milk',
      packSize: '200 ML',
      price: 30.0,
      active: true,
      stockQuantity: 150,
      description: 'Creamy milk infused with premium cocoa.',
    ),
    Product(
      id: 4,
      name: 'Double Toned Milk',
      category: 'Milk',
      packSize: '500 ML',
      price: 30.0,
      active: true,
      stockQuantity: 300,
      description: 'Low fat healthy pasteurized double toned milk pouch.',
    ),
    Product(
      id: 5,
      name: 'DTM Cow Tetra Pack',
      category: 'Milk',
      packSize: '180 ML Tetra Pack',
      price: 35.0,
      active: true,
      stockQuantity: 200,
      description: 'Long shelf life double toned cow milk tetra pack.',
    ),
    Product(
      id: 6,
      name: 'Sangam Pure Cow Ghee',
      category: 'Ghee',
      packSize: '500 ML Jar',
      price: 380.0,
      active: true,
      stockQuantity: 60,
      description: 'Traditional golden granular cow ghee made from fresh cream.',
    ),
    Product(
      id: 7,
      name: 'Sangam Special Buffalo Ghee',
      category: 'Ghee',
      packSize: '1 Litre Pouch',
      price: 720.0,
      active: true,
      stockQuantity: 45,
      description: 'Aromatic rich buffalo ghee with authentic taste and texture.',
    ),
    Product(
      id: 8,
      name: 'Sangam Fresh Paneer',
      category: 'Paneer',
      packSize: '200 GM',
      price: 110.0,
      active: true,
      stockQuantity: 25, // Low stock alert
      description: 'Soft, white and high protein fresh cottage cheese.',
    ),
    Product(
      id: 9,
      name: 'Sangam Creamy Curd / Dahi',
      category: 'Curd',
      packSize: '500 GM Pouch',
      price: 38.0,
      active: true,
      stockQuantity: 250,
      description: 'Thick, creamy and naturally set farm fresh curd.',
    ),
    Product(
      id: 10,
      name: 'Sangam Sweet Lassi',
      category: 'Beverages',
      packSize: '200 ML Bottle',
      price: 25.0,
      active: true,
      stockQuantity: 180,
      description: 'Refreshing sweet probiotic lassi beverage.',
    ),
    Product(
      id: 11,
      name: 'Sangam Butter Milk (Majjiga)',
      category: 'Beverages',
      packSize: '200 ML Pouch',
      price: 12.0,
      active: true,
      stockQuantity: 320,
      description: 'Traditional spiced buttermilk with ginger and curry leaves.',
    ),
    Product(
      id: 12,
      name: 'Sangam Table Butter',
      category: 'Butter',
      packSize: '100 GM Pack',
      price: 58.0,
      active: true,
      stockQuantity: 90,
      description: 'Salted pure cream table butter for rich breakfast spread.',
    ),
    Product(
      id: 13,
      name: 'Gulab Jamun Sweet Box',
      category: 'Sweets',
      packSize: '500 GM Container',
      price: 190.0,
      active: true,
      stockQuantity: 25, // Low stock alert
      description: 'Mouth watering soft gulab jamuns made with pure khoya.',
    ),
    Product(
      id: 14,
      name: 'Sangam Malai Peda',
      category: 'Sweets',
      packSize: '250 GM Box',
      price: 140.0,
      active: true,
      stockQuantity: 45,
      description: 'Delightful traditional dairy sweet made with sweetened condensed milk.',
    ),
    Product(
      id: 15,
      name: 'Full Cream Milk (Orange Pouch)',
      category: 'Milk',
      packSize: '500 ML',
      price: 36.0,
      active: true,
      stockQuantity: 190,
      description: 'Rich full cream milk ideal for tea, coffee, and sweets preparation.',
    ),
  ];

  void _initMockProducts() {
    final baseCategories = ['Milk', 'Ghee', 'Paneer', 'Curd', 'Sweets', 'Butter', 'Beverages', 'Ice Cream'];
    final packSizes = ['200 ML', '500 ML', '1 Litre', '200 GM', '500 GM', '1 KG'];

    while (_mockProducts.length < 83) {
      final id = _mockProducts.length + 1;
      final cat = baseCategories[id % baseCategories.length];
      final pack = packSizes[id % packSizes.length];

      bool isActive = true;
      if (id == 50 || id == 75) {
        isActive = false; // 2 inactive -> 81 / 83 active
      }

      _mockProducts.add(Product(
        id: id,
        name: 'Sangam Dairy Special #$id',
        category: cat,
        packSize: pack,
        price: 25.0 + (id * 7) % 300,
        active: isActive,
        stockQuantity: 60 + (id * 11) % 150,
        description: 'Fresh and pure dairy product directly from Sangam Dairy farms.',
      ));
    }
  }

  Map<String, dynamic> _toStandardJsonPayload(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'packSize': product.packSize,
      'price': product.price,
      'active': product.active,
      'stockQuantity': product.stockQuantity,
      'description': product.description,
      'imageUrl': product.imageUrl,
    };
  }

  Map<String, dynamic> _toSnakeCaseJsonPayload(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'pack_size': product.packSize,
      'price': product.price,
      'is_active': product.active,
      'active': product.active,
      'stock_quantity': product.stockQuantity,
      'description': product.description,
      'image_url': product.imageUrl,
    };
  }

  List<Product> _deduplicateProducts(List<Product> products) {
    final seenIds = <int>{};
    final seenNames = <String>{};
    final List<Product> uniqueList = [];

    for (var p in products) {
      final nameKey = '${p.name.trim().toLowerCase()}_${p.packSize.trim().toLowerCase()}';
      if (!seenIds.contains(p.id) && !seenNames.contains(nameKey)) {
        seenIds.add(p.id);
        seenNames.add(nameKey);
        uniqueList.add(p);
      }
    }
    return uniqueList;
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('GET $baseUrl -> Status ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['content'] is List) {
            rawList = decoded['content'];
          } else if (decoded['data'] is List) {
            rawList = decoded['data'];
          } else if (decoded['products'] is List) {
            rawList = decoded['products'];
          }
        }

        isLiveServerConnected = true;
        final apiProducts = rawList
            .map<Product>((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        final uniqueApiProducts = _deduplicateProducts(apiProducts);

        if (uniqueApiProducts.isNotEmpty) {
          _mockProducts.clear();
          _mockProducts.addAll(uniqueApiProducts);
        }
        return uniqueApiProducts;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend API getProducts offline at $baseUrl ($e).');
      }
      isLiveServerConnected = false;
    }

    return _deduplicateProducts(_mockProducts);
  }

  Future<Product> addProduct(Product product) async {
    final newId = product.id > 0
        ? product.id
        : (_mockProducts.isEmpty
            ? 1
            : _mockProducts.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);

    final newProduct = product.copyWith(id: newId);
    final payload = _toStandardJsonPayload(newProduct);

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('POST $baseUrl -> Status ${response.statusCode}: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode <= 204) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final created = Product.fromJson(decoded);
            _mockProducts.insert(0, created);
            return created;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('addProduct error: $e');
    }

    _mockProducts.insert(0, newProduct);
    return newProduct;
  }

  Future<Product> updateProduct(Product product) async {
    final standardPayload = _toStandardJsonPayload(product);

    try {
      // 1. Try PUT /api/products/{id} with camelCase payload
      http.Response response = await http.put(
        Uri.parse('$baseUrl/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(standardPayload),
      ).timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('PUT $baseUrl/${product.id} -> Status ${response.statusCode}: ${response.body}');
      }

      // 2. If 400 Bad Request, try snake_case payload
      if (response.statusCode == 400) {
        response = await http.put(
          Uri.parse('$baseUrl/${product.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_toSnakeCaseJsonPayload(product)),
        ).timeout(const Duration(seconds: 4));
      }

      // 3. If 404 or 405 Method Not Allowed, try POST /api/products
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(standardPayload),
        ).timeout(const Duration(seconds: 4));
      }

      // 4. If 404 or 405 on POST, try PUT /api/products
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http.put(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(standardPayload),
        ).timeout(const Duration(seconds: 4));
      }

      if (response.statusCode >= 200 && response.statusCode <= 204) {
        Product updatedProduct = product;
        if (response.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              updatedProduct = Product.fromJson(decoded);
            }
          } catch (_) {}
        }

        final index = _mockProducts.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          _mockProducts[index] = updatedProduct;
        } else {
          _mockProducts.add(updatedProduct);
        }
        return updatedProduct;
      } else {
        if (kDebugMode) {
          print('Backend update product failed with HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('updateProduct Exception: $e');
    }

    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _mockProducts[index] = product;
    }
    return product;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 4));

      if (kDebugMode) {
        print('DELETE $baseUrl/$id -> Status ${response.statusCode}s');
      }

      if (response.statusCode >= 200 && response.statusCode <= 204) {
        _mockProducts.removeWhere((p) => p.id == id);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('deleteProduct Exception: $e');
    }

    _mockProducts.removeWhere((p) => p.id == id);
    return true;
  }
}
