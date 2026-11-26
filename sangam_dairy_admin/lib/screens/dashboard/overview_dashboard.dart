import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/order_api_service.dart';
import '../../services/product_api_service.dart';
import '../../services/export_service.dart';

class OverviewDashboard extends StatefulWidget {
  final VoidCallback onNavigateToProducts;
  final VoidCallback onNavigateToOrders;
  final VoidCallback? onNavigateToPayments;

  const OverviewDashboard({
    super.key,
    required this.onNavigateToProducts,
    required this.onNavigateToOrders,
    this.onNavigateToPayments,
  });

  @override
  State<OverviewDashboard> createState() => _OverviewDashboardState();
}

class _OverviewDashboardState extends State<OverviewDashboard> {
  final ProductApiService _productApi = ProductApiService();
  final OrderApiService _orderApi = OrderApiService();

  List<Product> _products = [];
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final products = await _productApi.getProducts();
      final orders = await _orderApi.getOrders();
      if (!mounted) return;
      setState(() {
        _products = products;
        _orders = orders;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showEarningsDialog(String title, List<Order> orders, double totalAmount, String periodLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_rounded, color: Colors.green.shade800),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7EC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA2E0B8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Earnings ($periodLabel)', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF087A35))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Orders', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('${orders.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF172D1E))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('$periodLabel Earnings History & Orders List:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text('No orders found for this period.'))
                    : ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final o = orders[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE9F7EC),
                              child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF087A35), fontWeight: FontWeight.bold)),
                            ),
                            title: Text('Order #${o.id} • ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${o.paymentMethod} • ${o.createdAt.toLocal().toString().split('.').first}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            trailing: Text('₹${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF087A35))),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF087A35), foregroundColor: Colors.white),
            onPressed: () {
              final csv = ExportService.generateOrdersCSV(orders);
              ExportService.downloadCSV(context, '${periodLabel.toLowerCase()}_earnings_history.csv', csv);
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export History CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTotalOrdersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Total Store Orders & Payment Methods'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Gateways Active:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(8)),
                      child: const Text('UPI / Cards / COD Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('All Store Orders History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    return ListTile(
                      title: Text('Order #${o.id} - ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Method: ${o.paymentMethod} | Status: ${o.status}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: Text('₹${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigateToOrders();
            },
            icon: const Icon(Icons.shopping_bag_outlined, size: 16),
            label: const Text('View All in Orders Tab'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showActiveProductsDialog(int activeCount, int totalCount) {
    final syncPct = totalCount > 0 ? ((activeCount / totalCount) * 100).toStringAsFixed(0) : '100';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFF087A35)),
            SizedBox(width: 10),
            Text('Active Products & Synchronization'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5F3FC)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Products: $activeCount / $totalCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('$syncPct% synchronized', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF087A35))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Product Catalog History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.category} • Pack: ${p.packSize} • Stock: ${p.stockQuantity}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF087A35))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF087A35), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigateToProducts();
            },
            icon: const Icon(Icons.inventory_2_rounded, size: 16),
            label: const Text('Manage Products Catalog'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(List<Product> lowStock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
            const SizedBox(width: 10),
            const Text('Low Stock Alerts & Reorder Management'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Low Stock Items: ${lowStock.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.amber.shade900)),
                    const Text('Requires Reorder', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Items needing immediate restock:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: lowStock.isEmpty
                    ? const Center(child: Text('All product stocks are healthy! No low stock alerts.'))
                    : ListView.separated(
                        itemCount: lowStock.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = lowStock[index];
                          return ListTile(
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${p.category} • Pack: ${p.packSize}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Text('${p.stockQuantity} left', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigateToProducts();
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Restock / Manage Inventory'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOutOfStockDialog(List<Product> outOfStock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_shopping_cart_rounded, color: Colors.red.shade800),
            const SizedBox(width: 10),
            const Text('Out of Stock Products Management'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC9C9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Out of Stock Items: ${outOfStock.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade800)),
                    const Text('Zero Inventory', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Products currently at 0 stock:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: outOfStock.isEmpty
                    ? const Center(child: Text('Fantastic! No products are currently out of stock.'))
                    : ListView.separated(
                        itemCount: outOfStock.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = outOfStock[index];
                          return ListTile(
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${p.category} • Pack: ${p.packSize}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                              child: const Text('0 units', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.onNavigateToProducts();
            },
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Restock / Manage Catalog'),
          ),
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
      return const Center(
        child: CircularProgressIndicator(color: brandGreen),
      );
    }

    final now = DateTime.now();
    final todayOrders = _orders.where((o) =>
        o.createdAt.year == now.year &&
        o.createdAt.month == now.month &&
        o.createdAt.day == now.day).toList();

    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyOrders = _orders.where((o) => o.createdAt.isAfter(weekAgo)).toList();

    final monthAgo = now.subtract(const Duration(days: 30));
    final monthlyOrders = _orders.where((o) => o.createdAt.isAfter(monthAgo)).toList();

    final double todayEarnings = todayOrders.fold(0, (sum, o) => sum + o.totalAmount);
    final double weeklyEarnings = weeklyOrders.fold(0, (sum, o) => sum + o.totalAmount);
    final double monthlyEarnings = monthlyOrders.fold(0, (sum, o) => sum + o.totalAmount);

    final totalProducts = _products.length;
    final activeProducts = _products.where((p) => p.active).length;
    final lowStockProducts = _products.where((p) => p.stockQuantity < 40 && p.stockQuantity > 0).toList();
    final outOfStockProducts = _products.where((p) => p.stockQuantity == 0).toList();

    return SingleChildScrollView(
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
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172D1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time store performance, earnings & inventory statistics.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Data'),
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

          // Revenue Analytics Cards Row (Today, Weekly, Monthly)
          const Text(
            'Earnings Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF172D1E)),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 1100
                  ? (constraints.maxWidth - 32) / 3
                  : constraints.maxWidth > 650
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _kpiCard(
                    width: cardWidth,
                    title: "Today's Earnings",
                    value: '₹${todayEarnings.toStringAsFixed(0)}',
                    trend: '${todayOrders.length} orders today',
                    icon: Icons.today_rounded,
                    color: Colors.green.shade800,
                    bgAccent: const Color(0xFFE9F7EC),
                    onTap: () => _showEarningsDialog("Today's Earnings History & Breakdown", todayOrders, todayEarnings, "Today"),
                  ),
                  _kpiCard(
                    width: cardWidth,
                    title: 'Weekly Earnings',
                    value: '₹${weeklyEarnings.toStringAsFixed(0)}',
                    trend: '${weeklyOrders.length} orders this week',
                    icon: Icons.calendar_view_week_rounded,
                    color: Colors.blue.shade800,
                    bgAccent: const Color(0xFFEBF3FC),
                    onTap: () => _showEarningsDialog("Weekly Earnings History & Breakdown", weeklyOrders, weeklyEarnings, "Weekly"),
                  ),
                  _kpiCard(
                    width: cardWidth,
                    title: 'Monthly Earnings',
                    value: '₹${monthlyEarnings.toStringAsFixed(0)}',
                    trend: '${monthlyOrders.length} orders this month',
                    icon: Icons.calendar_month_rounded,
                    color: Colors.teal.shade800,
                    bgAccent: const Color(0xFFE6F5F5),
                    onTap: () => _showEarningsDialog("Monthly Earnings History & Breakdown", monthlyOrders, monthlyEarnings, "Monthly"),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Operational Stats
          const Text(
            'Store Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF172D1E)),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 1200
                  ? (constraints.maxWidth - 48) / 4
                  : constraints.maxWidth > 800
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _kpiCard(
                    width: cardWidth,
                    title: 'Total Store Orders',
                    value: '${_orders.length}',
                    trend: 'UPI / Cards / COD Active',
                    icon: Icons.local_shipping_outlined,
                    color: Colors.indigo.shade700,
                    bgAccent: const Color(0xFFEEF2FF),
                    onTap: () => _showTotalOrdersDialog(),
                  ),
                  _kpiCard(
                    width: cardWidth,
                    title: 'Active Products',
                    value: '$activeProducts / $totalProducts',
                    trend: '${totalProducts > 0 ? ((activeProducts / totalProducts) * 100).toStringAsFixed(0) : 100}% synchronized',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.teal.shade700,
                    bgAccent: const Color(0xFFE6F5F5),
                    onTap: () => _showActiveProductsDialog(activeProducts, totalProducts),
                  ),
                  _kpiCard(
                    width: cardWidth,
                    title: 'Low Stock Alerts',
                    value: '${lowStockProducts.length}',
                    trend: 'Requires reorder',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.amber.shade900,
                    bgAccent: const Color(0xFFFFF7EA),
                    onTap: () => _showLowStockDialog(lowStockProducts),
                  ),
                  _kpiCard(
                    width: cardWidth,
                    title: 'Out of Stock',
                    value: '${outOfStockProducts.length}',
                    trend: 'Needs restock',
                    icon: Icons.remove_shopping_cart_rounded,
                    color: Colors.red.shade800,
                    bgAccent: const Color(0xFFFFE8E8),
                    onTap: () => _showOutOfStockDialog(outOfStockProducts),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Lower Section: Recent Orders & Stock Alerts
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 950;
              final allStockAlerts = [...outOfStockProducts, ...lowStockProducts];

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _recentOrdersCard(brandGreen)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _lowStockCard(allStockAlerts, brandGreen)),
                  ],
                );
              }

              return Column(
                children: [
                  _recentOrdersCard(brandGreen),
                  const SizedBox(height: 24),
                  _lowStockCard(allStockAlerts, brandGreen),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required double width,
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
    required Color bgAccent,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EBE3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
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
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172D1E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 12, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentOrdersCard(Color brandGreen) {
    return Container(
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
                'Recent Store Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172D1E),
                ),
              ),
              TextButton(
                onPressed: widget.onNavigateToOrders,
                style: TextButton.styleFrom(foregroundColor: brandGreen),
                child: const Row(
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No recent orders found.')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF6FAF7)),
                horizontalMargin: 12,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _orders.take(5).map((order) {
                  Color statusColor;
                  Color statusBg;
                  if (order.status == 'Delivered') {
                    statusColor = Colors.green.shade800;
                    statusBg = const Color(0xFFE4F5E8);
                  } else if (order.status == 'Processing') {
                    statusColor = Colors.blue.shade800;
                    statusBg = const Color(0xFFEBF3FC);
                  } else if (order.status == 'Cancelled') {
                    statusColor = Colors.red.shade800;
                    statusBg = const Color(0xFFFFE8E8);
                  } else {
                    statusColor = Colors.orange.shade900;
                    statusBg = const Color(0xFFFFF3E0);
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(order.customerName)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.paymentMethod,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _lowStockCard(List<Product> lowStock, Color brandGreen) {
    return Container(
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
                'Stock Reorder Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172D1E),
                ),
              ),
              TextButton(
                onPressed: widget.onNavigateToProducts,
                style: TextButton.styleFrom(foregroundColor: brandGreen),
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (lowStock.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: brandGreen, size: 36),
                    const SizedBox(height: 8),
                    const Text('All product stocks are healthy!'),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStock.take(5).length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final product = lowStock[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFFF3E0),
                      child: Icon(Icons.inventory_2_outlined, color: Colors.amber.shade900, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Category: ${product.category} • ${product.packSize}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${product.stockQuantity} units left',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
