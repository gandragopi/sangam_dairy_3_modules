import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/product_api_service.dart';
import '../screens/dashboard/overview_dashboard.dart';
import '../screens/products/products_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/banners/banners_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/common/coming_soon_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/support/help_support_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);
    const deepGreen = Color(0xFF054526);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7F4),
          appBar: isMobile
              ? AppBar(
                  backgroundColor: deepGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          'assets/images/sangam_logo.png',
                          height: 22,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.local_drink,
                            size: 20,
                            color: brandGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sangam Dairy Admin',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: 'Logout',
                      onPressed: () => _confirmLogout(context),
                    ),
                  ],
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  child: _buildSidebarContent(
                      brandGreen, deepGreen, isDrawer: true),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isSidebarCollapsed ? 80 : 250,
                  child: _buildSidebarContent(brandGreen, deepGreen),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) _buildTopHeader(context, brandGreen),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          OverviewDashboard(
                            onNavigateToProducts: () => _navigateTo(1),
                            onNavigateToOrders: () => _navigateTo(2),
                            onNavigateToPayments: () => _navigateTo(3),
                          ),
                          ProductsScreen(
                            key: ValueKey('products_$_selectedIndex'),
                          ),
                          OrdersScreen(
                            key: ValueKey('orders_$_selectedIndex'),
                          ),
                          PaymentsScreen(
                            key: ValueKey('payments_$_selectedIndex'),
                          ),
                          const CustomersScreen(),
                          const BannersScreen(),
                          const ReportsScreen(),
                          const ComingSoonScreen(
                            title: 'Rewards & Loyalty Program',
                            icon: Icons.card_giftcard_rounded,
                            description: 'Manage customer reward points, milestone tiers, and redemption rules. Coming soon in the next update!',
                          ),
                          const ComingSoonScreen(
                            title: 'Gift Cards Management',
                            icon: Icons.redeem_rounded,
                            description: 'Issue digital dairy gift cards, track active balances and gift card redemptions. Coming soon!',
                          ),
                          const ComingSoonScreen(
                            title: 'Discount Coupons & Promos',
                            icon: Icons.local_offer_rounded,
                            description: 'Create custom promo codes, festival discount vouchers, and special category sales. Coming soon!',
                          ),
                          const SettingsScreen(),
                          const HelpSupportScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(BuildContext context, Color brandGreen) {
    final user = AuthService().currentUser;
    final isLive = ProductApiService().isLiveServerConnected;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2EBE3)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
            },
            icon: Icon(
              _isSidebarCollapsed ? Icons.menu : Icons.menu_open,
              color: const Color(0xFF4A584F),
            ),
            tooltip: _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'Sangam Dairy Operations Portal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2D23),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Server Connection Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isLive ? const Color(0xFFE6F6EC) : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLive ? const Color(0xFFA2E0B8) : const Color(0xFFFFD8A8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLive ? Colors.green.shade600 : Colors.orange.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isLive ? 'API Connected' : 'Local Data Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLive ? Colors.green.shade800 : Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Notification icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF4A584F)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new system alerts.')),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // User Profile Card
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _confirmLogout(context);
              } else if (value == 'settings') {
                _navigateTo(10);
              }
            },
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Admin',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: brandGreen,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.name.split(' ').first ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2D23),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF718076), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(Color brandGreen, Color deepGreen, {bool isDrawer = false}) {
    final collapsed = _isSidebarCollapsed && !isDrawer;

    return Container(
      color: deepGreen,
      child: Column(
        children: [
          // Sidebar Logo Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/sangam_logo.png',
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.local_drink,
                      size: 24,
                      color: brandGreen,
                    ),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SANGAM DAIRY',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Color(0xFFB9E8C8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _sidebarNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Products',
                  badge: '83+',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 2,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Orders',
                  badge: 'New',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 3,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Payments',
                  badge: '₹',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 4,
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Customers',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 5,
                  icon: Icons.view_carousel_outlined,
                  activeIcon: Icons.view_carousel_rounded,
                  label: 'Banners',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 6,
                  icon: Icons.bar_chart_rounded,
                  activeIcon: Icons.analytics_rounded,
                  label: 'Reports & Export',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 7,
                  icon: Icons.card_giftcard_outlined,
                  activeIcon: Icons.card_giftcard_rounded,
                  label: 'Rewards',
                  badge: 'Soon',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 8,
                  icon: Icons.redeem_outlined,
                  activeIcon: Icons.redeem_rounded,
                  label: 'Gift Cards',
                  badge: 'Soon',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 9,
                  icon: Icons.local_offer_outlined,
                  activeIcon: Icons.local_offer_rounded,
                  label: 'Coupons',
                  badge: 'Soon',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 10,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _sidebarNavItem(
                  index: 11,
                  icon: Icons.help_outline_rounded,
                  activeIcon: Icons.help_rounded,
                  label: 'Help & Support',
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
              ],
            ),
          ),

          // Logout at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _confirmLogout(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment:
                      collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.logout_rounded, color: Color(0xFFFFB4B4), size: 20),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Color(0xFFFFB4B4),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? badge,
    required bool collapsed,
    required bool isDrawer,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _navigateTo(index);
            if (isDrawer) Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0A853C)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFFC0D8C8),
                  size: 21,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFE2F3E7),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of Sangam Dairy Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
