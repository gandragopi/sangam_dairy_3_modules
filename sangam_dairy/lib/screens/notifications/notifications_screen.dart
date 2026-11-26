import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_offer_rounded,
      'title': 'Special Offer',
      'message':
      'Get fresh Sangam Dairy products at special prices.',
      'time': 'Today',
      'type': 'Offer',
      'read': false,
    },
    {
      'icon': Icons.local_shipping_rounded,
      'title': 'Fresh Delivery',
      'message':
      'Your fresh dairy products are available for delivery.',
      'time': 'Today',
      'type': 'Delivery',
      'read': false,
    },
    {
      'icon': Icons.water_drop_rounded,
      'title': 'Fresh Milk Available',
      'message':
      'Sangam fresh milk is available now. Order your daily milk today.',
      'time': 'Yesterday',
      'type': 'Milk',
      'read': true,
    },
    {
      'icon': Icons.card_giftcard_rounded,
      'title': 'Welcome to Sangam Dairy',
      'message':
      'Thank you for choosing Sangam Dairy for your everyday dairy needs.',
      'time': 'Yesterday',
      'type': 'Welcome',
      'read': true,
    },
  ];

  // ============================================================
  // UNREAD COUNT
  // ============================================================

  int get _unreadCount {
    return _notifications
        .where(
          (notification) => notification['read'] == false,
    )
        .length;
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  void _markAsRead(int index) {
    if (_notifications[index]['read'] == true) {
      return;
    }

    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  void _markAllAsRead() {
    if (_unreadCount == 0) {
      return;
    }

    setState(() {
      for (final notification in _notifications) {
        notification['read'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'All notifications marked as read',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> _clearAll() async {
    if (_notifications.isEmpty) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear Notifications',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to clear all notifications?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) {
      return;
    }

    setState(() {
      _notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'All notifications cleared',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NOTIFICATION COLOR
  // ============================================================

  Color _getIconBackground(String type) {
    switch (type) {
      case 'Offer':
        return const Color(0xFFFFF4DF);

      case 'Delivery':
        return const Color(0xFFEAF4FF);

      case 'Milk':
        return const Color(0xFFE8F5E9);

      case 'Welcome':
        return const Color(0xFFF3EAFB);

      default:
        return lightGreen;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'Offer':
        return orange;

      case 'Delivery':
        return const Color(0xFF2878C8);

      case 'Milk':
        return primaryGreen;

      case 'Welcome':
        return const Color(0xFF7B4AA8);

      default:
        return primaryGreen;
    }
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(
      Map<String, dynamic> notification,
      int index,
      ) {
    final bool isRead = notification['read'] == true;
    final String type = notification['type'] as String;

    return InkWell(
      onTap: () {
        _markAsRead(index);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFFF0FAF2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE1E9E2)
                : const Color(0xFFBDE4C7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _getIconBackground(type),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: _getIconColor(type),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String,
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(
                            top: 5,
                            left: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    notification['message'] as String,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        notification['time'] as String,
                        style: const TextStyle(
                          color: primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 80,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: primaryGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Notifications',
              style: TextStyle(
                color: darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are all caught up.\nNew updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(double width) {
    final bool isDesktop = width >= 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 34 : 18,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Row(
            children: [
              // BACK
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Back',
              ),

              const SizedBox(width: 6),

              // TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 23 : 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _unreadCount == 0
                          ? 'You are all caught up'
                          : '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // UNREAD BADGE
              if (_unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_unreadCount New',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isDesktop = width >= 800;

            return Column(
              children: [
                _buildHeader(width),

                Expanded(
                  child: _notifications.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal:
                      isDesktop ? 32 : 16,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                        const BoxConstraints(
                          maxWidth: 1100,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ACTION BAR
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .notifications_active_outlined,
                                        color:
                                        primaryGreen,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${_notifications.length} Notifications',
                                        style:
                                        const TextStyle(
                                          color:
                                          darkGreen,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight
                                              .w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (_unreadCount > 0)
                                  TextButton(
                                    onPressed:
                                    _markAllAsRead,
                                    child:
                                    const Text(
                                      'Mark all as read',
                                      style:
                                      TextStyle(
                                        color:
                                        primaryGreen,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight
                                            .w800,
                                      ),
                                    ),
                                  ),

                                IconButton(
                                  onPressed: _clearAll,
                                  tooltip: 'Clear all',
                                  icon: const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color:
                                    Colors.redAccent,
                                    size: 21,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // NOTIFICATION LIST
                            ...List.generate(
                              _notifications.length,
                                  (index) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    bottom: 14,
                                  ),
                                  child:
                                  _buildNotificationCard(
                                    _notifications[index],
                                    index,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // FOOTER
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/sangam_logo.png',
                                    height: 34,
                                    fit: BoxFit.contain,
                                    errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                        ) {
                                      return const Icon(
                                        Icons
                                            .water_drop_rounded,
                                        color:
                                        primaryGreen,
                                        size: 30,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'Sangam Dairy',
                                    style: TextStyle(
                                      color:
                                      primaryGreen,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Pure goodness. Every day.',
                                    style: TextStyle(
                                      color:
                                      Colors.black45,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
