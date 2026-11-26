import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/customer.dart';

class ExportService {
  static void downloadCSV(BuildContext context, String filename, String csvContent) {
    _showReportDialog(context, filename, csvContent);
  }

  static void _showReportDialog(BuildContext context, String filename, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exported Report: $filename'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Copy or download your CSV report data below:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    content,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String generateOrdersCSV(List<Order> orders) {
    final buffer = StringBuffer();
    buffer.writeln('Order ID,Customer Name,Phone,Delivery Address,Total Amount,Status,Payment Status,Payment Method,Date');
    for (var o in orders) {
      buffer.writeln('"${o.id}","${o.customerName}","${o.customerPhone}","${o.deliveryAddress.replaceAll(',', ' - ')}",${o.totalAmount},"${o.status}","${o.paymentStatus}","${o.paymentMethod}","${o.createdAt.toIso8601String()}"');
    }
    return buffer.toString();
  }

  static String generateProductsCSV(List<Product> products) {
    final buffer = StringBuffer();
    buffer.writeln('Product ID,Name,Category,Pack Size,Price (₹),Stock Quantity,Status');
    for (var p in products) {
      buffer.writeln('${p.id},"${p.name}","${p.category}","${p.packSize}",${p.price},${p.stockQuantity},"${p.active ? 'Active' : 'Inactive'}"');
    }
    return buffer.toString();
  }

  static String generateCustomersCSV(List<Customer> customers) {
    final buffer = StringBuffer();
    buffer.writeln('Customer ID,Name,Email,Phone,City,Total Orders,Total Spent (₹),Joined Date');
    for (var c in customers) {
      buffer.writeln('${c.id},"${c.name}","${c.email}","${c.phone}","${c.city}",${c.totalOrders},${c.totalSpent},"${c.joinedDate.toIso8601String()}"');
    }
    return buffer.toString();
  }
}
