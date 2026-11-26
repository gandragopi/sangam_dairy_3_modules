class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'Pending', 'Processing', 'Delivered', 'Cancelled'
  final String paymentStatus; // 'Paid', 'Pending', 'Failed'
  final String paymentMethod; // 'UPI', 'Card', 'COD'
  final String transactionId;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod = 'UPI',
    this.transactionId = '',
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Paid',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? 'UPI',
      transactionId: json['transactionId']?.toString() ?? json['transaction_id']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
