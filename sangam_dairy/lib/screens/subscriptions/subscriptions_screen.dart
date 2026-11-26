import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/products.dart';
import '../../services/product_api_service.dart';
import '../delivery/delivery_calendar_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  final List<String> _frequencies = [
    'Daily',
    'Alternate Days',
    'Weekly',
  ];

  List<Map<String, dynamic>> _milkProducts = [];

  Map<String, dynamic>? _selectedProduct;

  String _selectedFrequency = 'Daily';

  int _quantity = 1;

  DateTime _startDate = DateTime.now().add(
    const Duration(days: 1),
  );

  bool _loading = true;

  Map<String, dynamic>? _savedSubscription;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString(
      'sangam_active_subscription',
    );

    final products = ProductsData.products
        .where(ProductApiService.isActiveProduct)
        .where(
          (product) =>
      product['category']?.toString().toLowerCase() == 'milk',
    )
        .map(
          (product) => Map<String, dynamic>.from(product),
    )
        .toList();

    if (!mounted) return;

    setState(() {
      _milkProducts = products;

      if (products.isNotEmpty) {
        _selectedProduct = products.first;
      }

      if (saved != null && saved.isNotEmpty) {
        try {
          final decoded = jsonDecode(saved);

          if (decoded is Map) {
            _savedSubscription = Map<String, dynamic>.from(
              decoded,
            );
          }
        } catch (_) {
          _savedSubscription = null;
        }
      }

      _loading = false;
    });
  }

  double _getPrice() {
    if (_selectedProduct == null) {
      return 0;
    }

    final value = _selectedProduct!['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  int _getDaysPerMonth() {
    switch (_selectedFrequency) {
      case 'Alternate Days':
        return 15;

      case 'Weekly':
        return 4;

      default:
        return 30;
    }
  }

  double _getEstimatedMonthlyAmount() {
    return _getPrice() *
        _quantity *
        _getDaysPerMonth();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectStartDate() async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(today)
          ? today
          : _startDate,
      firstDate: today,
      lastDate: DateTime(
        today.year + 2,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _startDate = selected;
    });
  }

  Future<void> _saveSubscription() async {
    if (_selectedProduct == null) {
      _showMessage(
        'Please select a milk product.',
      );
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final subscription = <String, dynamic>{
      'productName':
      _selectedProduct!['name']?.toString() ?? '',
      'image':
      _selectedProduct!['image']?.toString() ?? '',
      'price': _getPrice(),
      'packSize':
      _selectedProduct!['packSize']?.toString() ?? '',
      'frequency': _selectedFrequency,
      'quantity': _quantity,
      'startDate':
      _startDate.toIso8601String(),
      'estimatedMonthlyAmount':
      _getEstimatedMonthlyAmount(),
      'status': 'Active',
    };

    await prefs.setString(
      'sangam_active_subscription',
      jsonEncode(subscription),
    );

    if (!mounted) return;

    setState(() {
      _savedSubscription = subscription;
    });

    _showSubscriptionSuccess();
  }

  Future<void> _cancelSubscription() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Cancel Subscription?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel your active subscription?',
            style: TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'sangam_active_subscription',
    );

    if (!mounted) return;

    setState(() {
      _savedSubscription = null;
    });

    _showMessage(
      'Subscription cancelled successfully.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _showSubscriptionSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Subscription Activated!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_selectedProduct!['name']} will be delivered ${_selectedFrequency.toLowerCase()}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: const Row(
          children: [
            Icon(
              Icons.autorenew_rounded,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              'Subscriptions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      )
          : LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final isDesktop =
              constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
              isDesktop ? 40 : 18,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(),
                    const SizedBox(height: 26),
                    _buildSectionTitle(
                      'Choose your milk',
                      'Fresh Sangam milk delivered your way.',
                    ),
                    const SizedBox(height: 14),
                    _buildProductSelector(
                      isDesktop,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      'Delivery frequency',
                      'Choose how often you want your milk.',
                    ),
                    const SizedBox(height: 14),
                    _buildFrequencySelector(),
                    const SizedBox(height: 28),
                    _buildSubscriptionSettings(
                      isDesktop,
                    ),
                    const SizedBox(height: 28),
                    _buildSummaryCard(),
                    const SizedBox(height: 28),
                    if (_savedSubscription !=
                        null)
                      _buildActiveSubscription(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075C2A),
            Color(0xFF0D9B48),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final isSmall =
              constraints.maxWidth < 650;

          final textContent = Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                  BorderRadius.circular(30),
                ),
                child: const Text(
                  'SANGAM DAILY FRESH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Milk Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fresh, pure and nutritious milk\ndelivered to your doorstep.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose your milk, quantity and delivery frequency.',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.82,
                  ),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Text(
                  'MILK ONLY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          );

          final logo = Container(
            width: isSmall ? 110 : 150,
            height: isSmall ? 110 : 150,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.25,
                ),
                width: 1.5,
              ),
            ),
            child: Image.asset(
              'assets/images/sangam_logo.png',
              fit: BoxFit.contain,
            ),
          );

          if (isSmall) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                textContent,
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: logo,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: textContent,
              ),
              const SizedBox(width: 30),
              logo,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelector(
      bool isDesktop,
      ) {
    if (_milkProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: const Text(
          'No milk products available.',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _milkProducts.length,
        separatorBuilder: (
            _,
            _,
            ) =>
        const SizedBox(width: 14),
        itemBuilder: (
            context,
            index,
            ) {
          final product =
          _milkProducts[index];

          final selected =
              _selectedProduct?['name'] ==
                  product['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedProduct = product;
              });
            },
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 220),
              width:
              isDesktop ? 190 : 170,
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? primaryGreen
                      : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            product['image']
                                ?.toString() ??
                                '',
                            fit: BoxFit.contain,
                            errorBuilder: (
                                _,
                                _,
                                _,
                                ) {
                              return const Icon(
                                Icons
                                    .local_drink_rounded,
                                size: 55,
                                color: primaryGreen,
                              );
                            },
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration:
                              const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name']
                        ?.toString() ??
                        '',
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['packSize'] ?? ''}  •  ₹${_getProductPrice(product).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getProductPrice(
      Map<String, dynamic> product,
      ) {
    final value = product['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
      _frequencies.map((frequency) {
        final selected =
            _selectedFrequency ==
                frequency;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFrequency =
                  frequency;
            });
          },
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? primaryGreen
                  : Colors.white,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? primaryGreen
                    : Colors.grey.shade200,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: primaryGreen
                      .withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 12,
                  offset:
                  const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  frequency == 'Daily'
                      ? Icons.today_rounded
                      : frequency ==
                      'Alternate Days'
                      ? Icons
                      .date_range_rounded
                      : Icons
                      .calendar_view_week_rounded,
                  size: 20,
                  color: selected
                      ? Colors.white
                      : primaryGreen,
                ),
                const SizedBox(width: 9),
                Text(
                  frequency,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : darkGreen,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionSettings(
      bool isDesktop,
      ) {
    final content = [
      _buildSettingCard(
        icon: Icons.calendar_month_rounded,
        title: 'Start Date',
        value: _formatDate(_startDate),
        onTap: _selectStartDate,
      ),
      _buildQuantityCard(),
    ];

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: content[0],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: content[1],
          ),
        ],
      );
    }

    return Column(
      children: [
        content[0],
        const SizedBox(height: 14),
        content[1],
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
              const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryGreen,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: darkGreen,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityCard() {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .format_list_numbered_rounded,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Packs per delivery',
                  style: TextStyle(
                    fontSize: 15,
                    color: darkGreen,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: pageBackground,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                      : null,
                  icon: const Icon(
                    Icons.remove_rounded,
                  ),
                  color: primaryGreen,
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                IconButton(
                  onPressed: _quantity < 10
                      ? () {
                    setState(() {
                      _quantity++;
                    });
                  }
                      : null,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  color: primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBSCRIPTION SUMMARY
  // ============================================================

  Widget _buildSummaryCard() {
    final price = _getPrice();

    final days = _getDaysPerMonth();

    final quantity = _quantity;

    final monthlyAmount =
    _getEstimatedMonthlyAmount();

    final productName =
        _selectedProduct?['name']
            ?.toString() ??
            'Select a milk';

    final packSize =
        _selectedProduct?['packSize']
            ?.toString() ??
            '-';

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w900,
                        color: darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Estimated amount based on selected frequency.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding:
            const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pageBackground,
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  padding:
                  const EdgeInsets.all(7),
                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    _selectedProduct?['image']
                        ?.toString() ??
                        '',
                    fit: BoxFit.contain,
                    errorBuilder: (
                        _,
                        _,
                        _,
                        ) {
                      return const Icon(
                        Icons.local_drink_rounded,
                        color: primaryGreen,
                        size: 30,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w900,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        packSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                              .shade600,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _summaryRow(
            'Price per pack',
            '₹${price.toStringAsFixed(0)}',
          ),

          _summaryRow(
            'Quantity per delivery',
            '$quantity pack${quantity == 1 ? '' : 's'}',
          ),

          _summaryRow(
            'Delivery frequency',
            _selectedFrequency,
          ),

          _summaryRow(
            'Estimated deliveries',
            '$days / month',
          ),

          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Divider(
              height: 1,
            ),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estimated Monthly Amount',
                  style: TextStyle(
                    fontSize: 15,
                    color: darkGreen,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '₹${monthlyAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  color: primaryGreen,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Final billing may vary depending on actual deliveries and applicable charges.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
              _saveSubscription,
              icon: const Icon(
                Icons.autorenew_rounded,
              ),
              label: const Text(
                'ACTIVATE SUBSCRIPTION',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                primaryGreen,
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 17,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                textStyle:
                const TextStyle(
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: darkGreen,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVE SUBSCRIPTION
  // ============================================================

  Widget _buildActiveSubscription() {
    final subscription =
    _savedSubscription!;

    final productName =
        subscription['productName']
            ?.toString() ??
            '';

    final frequency =
        subscription['frequency']
            ?.toString() ??
            '';

    final startDateRaw =
        subscription['startDate']
            ?.toString() ??
            '';

    final quantity =
        subscription['quantity']
            ?.toString() ??
            '1';

    final amount =
        (subscription[
        'estimatedMonthlyAmount']
        as num?)
            ?.toDouble() ??
            double.tryParse(
              subscription[
              'estimatedMonthlyAmount']
                  ?.toString() ??
                  '',
            ) ??
            0;

    DateTime? startDate;

    try {
      startDate =
          DateTime.parse(startDateRaw);
    } catch (_) {
      startDate = null;
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Subscription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color:
                      Color(0xFF7DFF9B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                padding:
                const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: Image.asset(
                  subscription['image']
                      ?.toString() ??
                      '',
                  fit: BoxFit.contain,
                  errorBuilder: (
                      _,
                      _,
                      _,
                      ) {
                    return const Icon(
                      Icons.local_drink_rounded,
                      color: primaryGreen,
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$quantity pack • $frequency',
                      style: TextStyle(
                        color:
                        Colors.white.withValues(
                          alpha: 0.75,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding:
            const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _activeInfo(
                    'Starts',
                    startDate == null
                        ? '-'
                        : _formatDate(
                      startDate,
                    ),
                  ),
                ),
                Expanded(
                  child: _activeInfo(
                    'Est. Monthly',
                    '₹${amount.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed:
              _cancelSubscription,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Colors.white,
                side: BorderSide(
                  color:
                  Colors.white.withValues(
                    alpha: 0.35,
                  ),
                ),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'CANCEL SUBSCRIPTION',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const DeliveryCalendarScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.calendar_month_rounded,
                size: 20,
              ),
              label: const Text(
                'VIEW DELIVERY CALENDAR',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.white,
                foregroundColor:
                primaryGreen,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                textStyle:
                const TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeInfo(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.6,
            ),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
