class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final int totalOrders;
  final double totalSpent;
  final DateTime joinedDate;
  final bool active;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.totalOrders,
    required this.totalSpent,
    required this.joinedDate,
    this.active = true,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'].toString())
          : DateTime.now(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'joinedDate': joinedDate.toIso8601String(),
      'active': active,
    };
  }
}
