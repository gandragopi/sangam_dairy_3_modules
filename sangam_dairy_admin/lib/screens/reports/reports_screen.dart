import 'package:flutter/material.dart';
import '../../services/export_service.dart';
import '../../services/order_api_service.dart';
import '../../services/product_api_service.dart';
import '../../models/customer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  List<Customer> _getMockCustomers() {
    return [
      Customer(id: 'CUST-101', name: 'Ramesh Kumar', email: 'ramesh.k@gmail.com', phone: '+91 98765 43210', city: 'Guntur', totalOrders: 18, totalSpent: 4250.0, joinedDate: DateTime(2025, 4, 12)),
      Customer(id: 'CUST-102', name: 'Sita Lakshmi', email: 'sita.lakshmi@yahoo.com', phone: '+91 91234 56789', city: 'Vijayawada', totalOrders: 24, totalSpent: 6800.0, joinedDate: DateTime(2025, 2, 20)),
      Customer(id: 'CUST-103', name: 'Venkateswarlu P.', email: 'venkat.p@outlook.com', phone: '+91 94401 22334', city: 'Tenali', totalOrders: 9, totalSpent: 2100.0, joinedDate: DateTime(2025, 6, 5)),
      Customer(id: 'CUST-104', name: 'Anitha Reddy', email: 'anitha.reddy@gmail.com', phone: '+91 97000 11223', city: 'Vadlamudi', totalOrders: 31, totalSpent: 8900.0, joinedDate: DateTime(2024, 11, 15)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports & Data Export Hub',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172D1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate and download professional CSV / Excel reports for orders, inventory, customers, and payments.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.8,
                children: [
                  _buildReportCard(
                    context,
                    title: 'Sales & Orders Report',
                    description: 'Export all store orders, delivery statuses, payment modes, and total revenue to CSV/Excel.',
                    icon: Icons.shopping_bag_rounded,
                    color: Colors.green.shade700,
                    onExport: () async {
                      final orders = await OrderApiService().getOrders();
                      if (!context.mounted) return;
                      final csv = ExportService.generateOrdersCSV(orders);
                      ExportService.downloadCSV(context, 'sangam_orders_report.csv', csv);
                    },
                  ),
                  _buildReportCard(
                    context,
                    title: 'Inventory & Products Report',
                    description: 'Export complete dairy product catalog, current stock levels, pricing, and active status.',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.blue.shade700,
                    onExport: () async {
                      final products = await ProductApiService().getProducts();
                      if (!context.mounted) return;
                      final csv = ExportService.generateProductsCSV(products);
                      ExportService.downloadCSV(context, 'sangam_products_inventory.csv', csv);
                    },
                  ),
                  _buildReportCard(
                    context,
                    title: 'Customer Directory Report',
                    description: 'Export registered customer details, contact numbers, city, total orders count, and total spent.',
                    icon: Icons.people_rounded,
                    color: Colors.orange.shade800,
                    onExport: () {
                      final customers = _getMockCustomers();
                      final csv = ExportService.generateCustomersCSV(customers);
                      ExportService.downloadCSV(context, 'sangam_customers_directory.csv', csv);
                    },
                  ),
                  _buildReportCard(
                    context,
                    title: 'Financial & Payments Report',
                    description: 'Export UPI, Card, and COD transaction summaries, settlement statuses, and revenues.',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.purple.shade700,
                    onExport: () async {
                      final orders = await OrderApiService().getOrders();
                      if (!context.mounted) return;
                      final csv = ExportService.generateOrdersCSV(orders);
                      ExportService.downloadCSV(context, 'sangam_financial_payments.csv', csv);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onExport,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172D1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onExport,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export to CSV / Excel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
