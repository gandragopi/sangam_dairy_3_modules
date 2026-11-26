class Product {
  final int id;
  final String name;
  final String category;
  final String packSize;
  final double price;
  final bool active;
  final int stockQuantity;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.packSize,
    required this.price,
    this.active = true,
    this.stockQuantity = 50,
    this.description = '',
    this.imageUrl = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Dairy',
      packSize: json['packSize']?.toString() ??
          json['pack_size']?.toString() ??
          '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      active: json['active'] == true ||
          json['active'] == 'true' ||
          json['status'] == 'Active',
      stockQuantity: json['stockQuantity'] is int
          ? json['stockQuantity']
          : int.tryParse(json['stockQuantity']?.toString() ?? '50') ?? 50,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'packSize': packSize,
      'price': price,
      'active': active,
      'stockQuantity': stockQuantity,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    String? packSize,
    double? price,
    bool? active,
    int? stockQuantity,
    String? description,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      packSize: packSize ?? this.packSize,
      price: price ?? this.price,
      active: active ?? this.active,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
