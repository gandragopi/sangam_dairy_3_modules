import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderApiService _api = OrderApiService();
  List<Order> _orders = [];
  bool _loading = true;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await _api.getOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  List<Order> get _filteredOrders {
    if (_selectedStatus == 'All') return _orders;
    return _orders.where((o) => o.status.toUpperCase() == _selectedStatus.toUpperCase()).toList();
  }

  Future<void> _updateStatus(Order order, String newStatus) async {
    await _api.updateOrderStatus(order.id, newStatus);
    if (!mounted) return;
    _loadOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order.id} status changed to $newStatus')),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Details - ${order.id}'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Phone: ${order.customerPhone}'),
              Text('Address: ${order.deliveryAddress}'),
              const Divider(height: 24),
              const Text('Items Ordered:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.productName}  x${item.quantity}'),
                        Text('₹${item.total.toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('₹${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF087A35))),
                ],
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

  Widget _buildStatusDropdown(Order order) {
    final statusList = <String>['PLACED', 'Pending', 'Processing', 'Delivered', 'Cancelled'];

    if (!statusList.contains(order.status) && order.status.isNotEmpty) {
      statusList.insert(0, order.status);
    }

    final dropdownValue = statusList.contains(order.status) ? order.status : statusList.first;

    return DropdownButton<String>(
      value: dropdownValue,
      underline: const SizedBox(),
      items: statusList.map((s) {
        return DropdownMenuItem<String>(
          value: s,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: s == 'Delivered'
                  ? const Color(0xFFE4F5E8)
                  : s == 'Processing'
                      ? const Color(0xFFEBF3FC)
                      : s == 'Cancelled'
                          ? const Color(0xFFFFE8E8)
                          : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: s == 'Delivered'
                    ? Colors.green.shade800
                    : s == 'Processing'
                        ? Colors.blue.shade800
                        : s == 'Cancelled'
                            ? Colors.red.shade800
                            : Colors.orange.shade900,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) _updateStatus(order, val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    final filtered = _filteredOrders;

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
                      'Store Orders Management',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172D1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track customer orders, delivery status, and payment details.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Refresh Orders',
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh, color: brandGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'PLACED', 'Pending', 'Processing', 'Delivered', 'Cancelled'].map((status) {
                  final isSelected = _selectedStatus.toUpperCase() == status.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: brandGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedStatus = status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Orders Table
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: brandGreen))
                  : filtered.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : Container(
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
                                    DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: filtered.map((order) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(order.customerName)),
                                        DataCell(Text(order.customerPhone)),
                                        DataCell(Text('₹${order.totalAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(order.paymentStatus)),
                                        DataCell(_buildStatusDropdown(order)),
                                        DataCell(
                                          TextButton.icon(
                                            onPressed: () => _showOrderDetails(order),
                                            icon: const Icon(Icons.visibility_outlined, size: 16),
                                            label: const Text('View'),
                                            style: TextButton.styleFrom(foregroundColor: brandGreen),
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
