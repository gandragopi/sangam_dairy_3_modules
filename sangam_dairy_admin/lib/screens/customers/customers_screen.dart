import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/customer_api_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerApiService _customerApi = CustomerApiService();
  List<Customer> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    final customers = await _customerApi.getCustomers();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _loading = false;
    });
  }

  void _showCustomerPurchaseHistory(BuildContext context, Customer customer) {
    final sampleOrders = [
      {'id': 'ORD-8821', 'date': '2026-11-04 10:30 AM', 'items': 'Cow Ghee (1), Milk (2)', 'amount': 478.0, 'status': 'Delivered'},
      {'id': 'ORD-8790', 'date': '2026-10-22 08:15 AM', 'items': 'Fresh Paneer (2), Curd (1)', 'amount': 258.0, 'status': 'Delivered'},
      {'id': 'ORD-8750', 'date': '2026-10-10 09:00 AM', 'items': 'Buffalo Ghee (1)', 'amount': 720.0, 'status': 'Delivered'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF087A35).withValues(alpha: 0.15),
              child: Text(customer.name.isNotEmpty ? customer.name[0] : 'C', style: const TextStyle(color: Color(0xFF087A35), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${customer.phone} • ${customer.city}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Purchase History & Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: sampleOrders.length,
                  itemBuilder: (context, index) {
                    final ord = sampleOrders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBF9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2EBE3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${ord['id']} (${ord['date']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('${ord['items']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${ord['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF087A35), fontSize: 14)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${ord['status']}', style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: brandGreen));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registered Customers Directory',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172D1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage customer accounts, purchase history, and contact profiles.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadCustomers,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Customers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: brandGreen,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFD3E0D5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
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
                          DataColumn(label: Text('Customer ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Orders', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Spent', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _customers.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(Text(c.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: brandGreen.withValues(alpha: 0.15),
                                      child: Text(
                                        c.name.isNotEmpty ? c.name[0] : 'C',
                                        style: const TextStyle(
                                          color: brandGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(c.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(c.phone)),
                              DataCell(Text(c.city)),
                              DataCell(Text('${c.totalOrders}')),
                              DataCell(Text('₹${c.totalSpent.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: brandGreen))),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _showCustomerPurchaseHistory(context, c),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandGreen.withValues(alpha: 0.1),
                                    foregroundColor: brandGreen,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.receipt_long_outlined, size: 14),
                                  label: const Text('Purchase History', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
