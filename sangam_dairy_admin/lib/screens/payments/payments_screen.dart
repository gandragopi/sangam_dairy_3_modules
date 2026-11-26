import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_api_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final OrderApiService _orderApi = OrderApiService();
  List<Order> _orders = [];
  bool _loading = true;

  String _selectedPeriod = 'All'; // 'Today', 'Weekly', 'Monthly', 'All'
  String _selectedMethod = 'All'; // 'All', 'UPI', 'Card', 'COD'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final orders = await _orderApi.getOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  List<Order> _filterOrdersByPeriod(List<Order> list, String period) {
    final now = DateTime.now();
    if (period == 'Today') {
      return list.where((o) {
        return o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day;
      }).toList();
    } else if (period == 'Weekly') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return list.where((o) => o.createdAt.isAfter(weekAgo)).toList();
    } else if (period == 'Monthly') {
      final monthAgo = now.subtract(const Duration(days: 30));
      return list.where((o) => o.createdAt.isAfter(monthAgo)).toList();
    }
    return list;
  }

  bool _isUpi(String method) {
    final m = method.toUpperCase();
    return m.contains('UPI') || m.contains('PHONEPE') || m.contains('GPAY') || m.contains('PAYTM') || m.contains('BHIM');
  }

  bool _isCardOrNetBanking(String method) {
    final m = method.toUpperCase();
    return m.contains('CARD') ||
        m.contains('CREDIT') ||
        m.contains('DEBIT') ||
        m.contains('NET') ||
        m.contains('BANKING') ||
        m.contains('VISA') ||
        m.contains('MASTER');
  }

  bool _isCod(String method) {
    final m = method.toUpperCase();
    return m.contains('COD') || m.contains('CASH');
  }

  List<Order> get _filteredTransactions {
    var list = _filterOrdersByPeriod(_orders, _selectedPeriod);

    if (_selectedMethod != 'All') {
      final sm = _selectedMethod.toUpperCase();
      if (sm == 'UPI') {
        list = list.where((o) => _isUpi(o.paymentMethod)).toList();
      } else if (sm == 'CARD') {
        list = list.where((o) => _isCardOrNetBanking(o.paymentMethod)).toList();
      } else if (sm == 'COD') {
        list = list.where((o) => _isCod(o.paymentMethod)).toList();
      } else {
        list = list.where((o) => o.paymentMethod.toUpperCase() == sm).toList();
      }
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((o) {
        return o.transactionId.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.id.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);

    if (_loading) {
      return Center(child: CircularProgressIndicator(color: brandGreen));
    }

    final todayOrders = _filterOrdersByPeriod(_orders, 'Today');
    final weeklyOrders = _filterOrdersByPeriod(_orders, 'Weekly');
    final monthlyOrders = _filterOrdersByPeriod(_orders, 'Monthly');

    final double todayEarnings = todayOrders.fold(0, (sum, o) => sum + o.totalAmount);
    final double weeklyEarnings = weeklyOrders.fold(0, (sum, o) => sum + o.totalAmount);
    final double monthlyEarnings = monthlyOrders.fold(0, (sum, o) => sum + o.totalAmount);
    final double totalEarningsAllTime = _orders.fold(0, (sum, o) => sum + o.totalAmount);

    // Method Breakdown (All Time or Filtered Period)
    final activePeriodOrders = _filterOrdersByPeriod(_orders, _selectedPeriod);
    final double upiTotal = activePeriodOrders
        .where((o) => _isUpi(o.paymentMethod))
        .fold(0, (sum, o) => sum + o.totalAmount);
    final double cardTotal = activePeriodOrders
        .where((o) => _isCardOrNetBanking(o.paymentMethod))
        .fold(0, (sum, o) => sum + o.totalAmount);
    final double codTotal = activePeriodOrders
        .where((o) => _isCod(o.paymentMethod))
        .fold(0, (sum, o) => sum + o.totalAmount);

    final double periodTotalSum = upiTotal + cardTotal + codTotal;

    final filteredTxns = _filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Action Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earnings & Payments Overview',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172D1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track revenue collections, UPI, Card, COD payment gateways & settlements.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Revenue'),
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

            // Earnings Cards Row (Today, Weekly, Monthly)
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth > 1050
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth > 650
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _earningsCard(
                      width: width,
                      title: "Today's Earnings",
                      amount: '₹${todayEarnings.toStringAsFixed(0)}',
                      subtitle: '${todayOrders.length} orders settled today',
                      icon: Icons.today_rounded,
                      color: Colors.green.shade800,
                      bgAccent: const Color(0xFFE8F6EB),
                    ),
                    _earningsCard(
                      width: width,
                      title: 'Weekly Earnings (This Week)',
                      amount: '₹${weeklyEarnings.toStringAsFixed(0)}',
                      subtitle: '${weeklyOrders.length} orders this week',
                      icon: Icons.calendar_view_week_rounded,
                      color: Colors.blue.shade800,
                      bgAccent: const Color(0xFFEBF3FC),
                    ),
                    _earningsCard(
                      width: width,
                      title: 'Monthly Earnings (This Month)',
                      amount: '₹${monthlyEarnings.toStringAsFixed(0)}',
                      subtitle: '${monthlyOrders.length} orders this month',
                      icon: Icons.calendar_month_rounded,
                      color: Colors.teal.shade800,
                      bgAccent: const Color(0xFFE6F5F5),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Payment Methods Breakdown Section (UPI, Card, COD)
            const Text(
              'Payment Mode Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172D1E),
              ),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth = constraints.maxWidth > 950
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _paymentMethodCard(
                      width: cardWidth,
                      methodName: 'UPI (PhonePe / GPay)',
                      amount: upiTotal,
                      totalPeriodAmount: periodTotalSum,
                      icon: Icons.qr_code_2_rounded,
                      color: const Color(0xFF5F259F), // UPI purple
                      bgAccent: const Color(0xFFF3E8FF),
                    ),
                    _paymentMethodCard(
                      width: cardWidth,
                      methodName: 'Credit / Debit Cards',
                      amount: cardTotal,
                      totalPeriodAmount: periodTotalSum,
                      icon: Icons.credit_card_rounded,
                      color: const Color(0xFF1976D2), // Card blue
                      bgAccent: const Color(0xFFE3F2FD),
                    ),
                    _paymentMethodCard(
                      width: cardWidth,
                      methodName: 'Cash on Delivery (COD)',
                      amount: codTotal,
                      totalPeriodAmount: periodTotalSum,
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF2E7D32), // COD green
                      bgAccent: const Color(0xFFE8F5E9),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Payment Settlement Transactions Table Section
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Settlement History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172D1E),
                        ),
                      ),
                      Text(
                        'Total Total Collected: ₹${totalEarningsAllTime.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: brandGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter & Search Controls Bar
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Search Input
                      SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search TXN ID or Customer...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  ),
                          ),
                        ),
                      ),

                      // Time Period Selector
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Period: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Time')),
                              DropdownMenuItem(value: 'Today', child: Text('Today')),
                              DropdownMenuItem(value: 'Weekly', child: Text('This Week')),
                              DropdownMenuItem(value: 'Monthly', child: Text('This Month')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPeriod = val);
                            },
                          ),
                        ],
                      ),

                      // Payment Method Selector
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Method: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          DropdownButton<String>(
                            value: _selectedMethod,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Methods')),
                              DropdownMenuItem(value: 'UPI', child: Text('UPI (PhonePe/GPay)')),
                              DropdownMenuItem(value: 'Card', child: Text('Cards')),
                              DropdownMenuItem(value: 'COD', child: Text('Cash on Delivery')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMethod = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Data Table of Transactions
                  if (filteredTxns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No payment transactions found.')),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F8F5)),
                            columnSpacing: 28,
                            columns: const [
                              DataColumn(label: Text('Transaction ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Payment Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredTxns.map((order) {
                              Color methodBg;
                              Color methodColor;
                              IconData methodIcon;

                              if (_isUpi(order.paymentMethod)) {
                                methodBg = const Color(0xFFF3E8FF);
                                methodColor = const Color(0xFF5F259F);
                                methodIcon = Icons.qr_code_2_rounded;
                              } else if (_isCardOrNetBanking(order.paymentMethod)) {
                                methodBg = const Color(0xFFE3F2FD);
                                methodColor = const Color(0xFF1976D2);
                                methodIcon = Icons.credit_card_rounded;
                              } else {
                                methodBg = const Color(0xFFE8F5E9);
                                methodColor = const Color(0xFF2E7D32);
                                methodIcon = Icons.payments_rounded;
                              }

                              final dateStr =
                                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}';

                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    order.transactionId.isNotEmpty ? order.transactionId : 'TXN-SETTLED',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  )),
                                  DataCell(Text(order.id)),
                                  DataCell(Text(order.customerName)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: methodBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(methodIcon, color: methodColor, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            order.paymentMethod.toUpperCase(),
                                            style: TextStyle(color: methodColor, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(
                                    '₹${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: brandGreen),
                                  )),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: order.paymentStatus == 'Paid'
                                            ? const Color(0xFFE4F5E8)
                                            : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        order.paymentStatus == 'Paid' ? 'Settled' : 'COD Pending',
                                        style: TextStyle(
                                          color: order.paymentStatus == 'Paid' ? brandGreen : Colors.orange.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earningsCard({
    required double width,
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgAccent,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172D1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard({
    required double width,
    required String methodName,
    required double amount,
    required double totalPeriodAmount,
    required IconData icon,
    required Color color,
    required Color bgAccent,
  }) {
    final double percentage = totalPeriodAmount > 0 ? (amount / totalPeriodAmount) * 100 : 0;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total revenue',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalPeriodAmount > 0 ? (amount / totalPeriodAmount) : 0,
              minHeight: 8,
              backgroundColor: bgAccent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
