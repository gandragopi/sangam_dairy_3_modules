import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryCalendarScreen extends StatefulWidget {
  const DeliveryCalendarScreen({super.key});

  @override
  State<DeliveryCalendarScreen> createState() =>
      _DeliveryCalendarScreenState();
}

class _DeliveryCalendarScreenState extends State<DeliveryCalendarScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF075C2A);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  Map<String, dynamic>? _subscription;

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString('sangam_active_subscription');

    if (saved == null || saved.isEmpty) {
      if (!mounted) return;

      setState(() {
        _subscription = null;
      });

      return;
    }

    try {
      final decoded = jsonDecode(saved);

      if (decoded is Map<String, dynamic>) {
        setState(() {
          _subscription = decoded;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _subscription = null;
      });
    }
  }

  DateTime? _getStartDate() {
    final value = _subscription?['startDate'];

    if (value == null) {
      return null;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _getFrequency() {
    return _subscription?['frequency']?.toString() ?? 'Daily';
  }

  String _getProductName() {
    return _subscription?['productName']?.toString() ??
        _subscription?['name']?.toString() ??
        'Milk Subscription';
  }

  String _getProductImage() {
    return _subscription?['image']?.toString() ?? '';
  }

  int _getQuantity() {
    final value = _subscription?['quantity'];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  double _getPrice() {
    final value = _subscription?['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isDeliveryDate(DateTime date) {
    final startDate = _getStartDate();

    if (startDate == null) {
      return false;
    }

    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    if (target.isBefore(start)) {
      return false;
    }

    final difference = target.difference(start).inDays;

    switch (_getFrequency().toLowerCase()) {
      case 'daily':
        return true;

      case 'alternate day':
      case 'alternate days':
        return difference % 2 == 0;

      case '3 days':
      case 'every 3 days':
        return difference % 3 == 0;

      case 'weekly':
        return difference % 7 == 0;

      default:
        return true;
    }
  }

  List<DateTime> _getDeliveryDatesForMonth() {
    final dates = <DateTime>[];

    final lastDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        day,
      );

      if (_isDeliveryDate(date)) {
        dates.add(date);
      }
    }

    return dates;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
      _selectedDate = null;
    });
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      color: darkGreen,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delivery Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: primaryGreen,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Subscription',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create a milk subscription first to see your upcoming delivery dates.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('BACK TO SUBSCRIPTION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSummary() {
    final image = _getProductImage();
    final frequency = _getFrequency();
    final startDate = _getStartDate();
    final quantity = _getQuantity();
    final price = _getPrice();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: image.isNotEmpty
                ? Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder: (_,_,_) {
                return const Icon(
                  Icons.local_drink_rounded,
                  color: primaryGreen,
                  size: 38,
                );
              },
            )
                : const Icon(
              Icons.local_drink_rounded,
              color: primaryGreen,
              size: 38,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE SUBSCRIPTION',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _getProductName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$quantity × ₹${price.toStringAsFixed(0)}  •  $frequency',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (startDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Started: ${_formatDate(startDate)}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: darkGreen,
            size: 30,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _monthName(_selectedMonth.month),
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_selectedMonth.year}',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: darkGreen,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDay.weekday - 1;

    final cells = <Widget>[];

    for (int i = 0; i < startingWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        day,
      );

      final isDelivery = _isDeliveryDate(date);
      final isToday = _isToday(date);
      final isSelected = _selectedDate != null &&
          date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;

      cells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryGreen
                  : isDelivery
                  ? lightGreen
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isToday
                  ? Border.all(
                color: orange,
                width: 2,
              )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDelivery
                        ? primaryGreen
                        : Colors.black87,
                    fontSize: 14,
                    fontWeight: isDelivery || isToday
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                if (isDelivery && !isSelected)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const Row(
          children: [
            _WeekDay(label: 'MON'),
            _WeekDay(label: 'TUE'),
            _WeekDay(label: 'WED'),
            _WeekDay(label: 'THU'),
            _WeekDay(label: 'FRI'),
            _WeekDay(label: 'SAT'),
            _WeekDay(label: 'SUN'),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.15,
          children: cells,
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _buildCalendar(),
          const SizedBox(height: 15),
          const Row(
            children: [
              _Legend(
                color: primaryGreen,
                label: 'Delivery day',
              ),
              SizedBox(width: 18),
              _Legend(
                color: orange,
                label: 'Today',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeliveries() {
    final dates = _getDeliveryDatesForMonth();
    final now = DateTime.now();

    final upcoming = dates.where((date) {
      final current = DateTime(
        now.year,
        now.month,
        now.day,
      );

      return !date.isBefore(current);
    }).take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Deliveries',
            style: TextStyle(
              color: darkGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your next milk deliveries for this month.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          if (upcoming.isEmpty)
            const Text(
              'No upcoming deliveries this month.',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 14,
              ),
            )
          else
            ...upcoming.map(
                  (date) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_drink_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDate(date),
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Text(
                        'Milk Delivery',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateCard() {
    if (_selectedDate == null) {
      return const SizedBox.shrink();
    }

    final isDelivery = _isDeliveryDate(_selectedDate!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDelivery ? lightGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDelivery
              ? primaryGreen.withValues(alpha: 0.25)
              : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDelivery
                ? Icons.local_shipping_rounded
                : Icons.event_busy_rounded,
            color: isDelivery ? primaryGreen : Colors.black45,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(_selectedDate!),
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDelivery
                      ? 'Milk delivery is scheduled for this day.'
                      : 'No milk delivery is scheduled for this day.',
                  style: TextStyle(
                    color: isDelivery
                        ? primaryGreen
                        : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _subscription == null
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadSubscription,
              color: primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildSubscriptionSummary(),
                        const SizedBox(height: 22),
                        const Text(
                          'Your Delivery Schedule',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Delivery dates are automatically calculated from your subscription.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildCalendarCard(),
                        const SizedBox(height: 18),
                        _buildSelectedDateCard(),
                        const SizedBox(height: 18),
                        _buildUpcomingDeliveries(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final String label;

  const _WeekDay({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
