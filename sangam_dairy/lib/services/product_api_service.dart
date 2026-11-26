import 'dart:convert';

import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ProductApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products. Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'Invalid products response format.',
      );
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => _normalizeProduct(
        Map<String, dynamic>.from(item),
      ),
    )
        .where(isActiveProduct)
        .toList();
  }

  // ============================================================
  // CHECK IF PRODUCT IS ACTIVE
  // ============================================================

  static bool isActiveProduct(Map<String, dynamic> product) {
    final dynamic rawStatus = product['status'] ??
        product['Status'] ??
        product['state'] ??
        product['State'];

    if (rawStatus != null) {
      final statusStr = rawStatus.toString().trim().toLowerCase();
      if (statusStr == 'inactive' ||
          statusStr == 'disabled' ||
          statusStr == 'false' ||
          statusStr == '0' ||
          statusStr == 'off' ||
          statusStr == 'archived') {
        return false;
      }
      if (statusStr == 'active' ||
          statusStr == 'enabled' ||
          statusStr == 'true' ||
          statusStr == '1' ||
          statusStr == 'on') {
        return true;
      }
    }

    final dynamic activeFlag = product['is_active'] ??
        product['isActive'] ??
        product['active'] ??
        product['IsActive'] ??
        product['Is_Active'] ??
        product['is_available'] ??
        product['isAvailable'];

    if (activeFlag != null) {
      if (activeFlag == false ||
          activeFlag == 0 ||
          activeFlag == 'false' ||
          activeFlag == '0') {
        return false;
      }
      if (activeFlag == true ||
          activeFlag == 1 ||
          activeFlag == 'true' ||
          activeFlag == '1') {
        return true;
      }
    }

    return true;
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  static Future<Map<String, dynamic>> getProductById(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load product. Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid product response format.',
      );
    }

    return _normalizeProduct(
      Map<String, dynamic>.from(decoded),
    );
  }

  // ============================================================
  // GET PRODUCTS BY CATEGORY
  // ============================================================

  static Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/products/category/'
            '${Uri.encodeComponent(category)}',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load category products. '
            'Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'Invalid category products response format.',
      );
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => _normalizeProduct(
        Map<String, dynamic>.from(item),
      ),
    )
        .where(isActiveProduct)
        .toList();
  }

  // ============================================================
  // NORMALIZE PRODUCT
  // ============================================================

  static Map<String, dynamic> _normalizeProduct(
      Map<String, dynamic> product,
      ) {
    final Map<String, dynamic> normalized =
    Map<String, dynamic>.from(product);

    // ------------------------------------------------------------
    // BASIC VALUES
    // ------------------------------------------------------------

    normalized['name'] =
        product['name']?.toString() ?? '';

    normalized['category'] =
        product['category']?.toString() ?? '';

    normalized['image'] =
        product['image']?.toString() ?? '';

    normalized['fat'] =
        product['fat']?.toString() ?? '';

    normalized['snf'] =
        product['snf']?.toString() ?? '';

    normalized['packSize'] =
        product['packSize']?.toString() ?? '';

    normalized['shelfLife'] =
        product['shelfLife']?.toString() ?? '';

    normalized['storage'] =
        product['storage']?.toString() ?? '';

    normalized['description'] =
        product['description']?.toString() ?? '';

    // ------------------------------------------------------------
    // STATUS & AVAILABILITY
    // ------------------------------------------------------------

    final dynamic rawStatus = product['status'] ?? product['Status'];
    if (rawStatus != null) {
      normalized['status'] = rawStatus.toString();
    }

    final dynamic rawIsActive = product['is_active'] ??
        product['isActive'] ??
        product['active'];
    if (rawIsActive != null) {
      normalized['is_active'] = rawIsActive;
    }

    // ------------------------------------------------------------
    // PRICE
    // ------------------------------------------------------------

    final dynamic priceValue = product['price'];

    if (priceValue is num) {
      normalized['price'] = priceValue;
    } else {
      normalized['price'] =
          num.tryParse(
            priceValue?.toString() ?? '',
          ) ??
              0;
    }

    // ------------------------------------------------------------
    // VARIANTS
    // ------------------------------------------------------------

    final dynamic variantsValue = product['variants'];

    if (variantsValue is List) {
      normalized['variants'] = _normalizeVariants(
        variantsValue,
      );
    } else if (variantsValue is String &&
        variantsValue.trim().isNotEmpty) {
      try {
        final dynamic decodedVariants =
        jsonDecode(variantsValue);

        if (decodedVariants is List) {
          normalized['variants'] =
              _normalizeVariants(decodedVariants);
        } else {
          normalized['variants'] = <Map<String, dynamic>>[];
        }
      } catch (_) {
        normalized['variants'] =
        <Map<String, dynamic>>[];
      }
    } else {
      normalized['variants'] =
      <Map<String, dynamic>>[];
    }

    return normalized;
  }

  // ============================================================
  // NORMALIZE VARIANTS
  // ============================================================

  static List<Map<String, dynamic>> _normalizeVariants(
      List<dynamic> variants,
      ) {
    return variants
        .whereType<Map>()
        .map(
          (variant) {
        final Map<String, dynamic> item =
        Map<String, dynamic>.from(variant);

        return {
          ...item,
          'label':
          item['label']?.toString() ?? '',
          'packSize':
          item['packSize']?.toString() ?? '',
          'image':
          item['image']?.toString() ?? '',
          'price': item['price'] is num
              ? item['price']
              : num.tryParse(
            item['price']?.toString() ?? '',
          ) ??
              0,
        };
      },
    )
        .toList();
  }
}
