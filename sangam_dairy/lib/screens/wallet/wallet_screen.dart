import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color cream = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  // ============================================================
  // STORAGE
  // ============================================================

  static const String walletStorageKey = 'sangam_wallet_data';

  // ============================================================
  // STATE
  // ============================================================

  double _walletBalance = 0.0;
  int _loyaltyPoints = 120;

  List<Map<String, dynamic>> _transactions = [];

  bool _loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  // ============================================================
  // LOAD WALLET
  // ============================================================

  Future<void> _loadWallet() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(walletStorageKey);

    if (savedData != null && savedData.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedData);

        if (decoded is Map<String, dynamic>) {
          final savedTransactions =
          decoded['transactions'] as List<dynamic>?;

          if (!mounted) return;

          setState(() {
            _walletBalance =
                (decoded['walletBalance'] ?? 0).toDouble();

            _loyaltyPoints =
                (decoded['loyaltyPoints'] ?? 120).toInt();

            _transactions = savedTransactions == null
                ? []
                : savedTransactions
                .whereType<Map>()
                .map(
                  (item) => Map<String, dynamic>.from(item),
            )
                .toList();

            _loading = false;
          });

          return;
        }
      } catch (_) {
        // If saved data is corrupted, use default values.
      }
    }

    if (!mounted) return;

    setState(() {
      _walletBalance = 0.0;
      _loyaltyPoints = 120;
      _transactions = [];
      _loading = false;
    });
  }

  // ============================================================
  // SAVE WALLET
  // ============================================================

  Future<void> _saveWallet() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'walletBalance': _walletBalance,
      'loyaltyPoints': _loyaltyPoints,
      'transactions': _transactions,
    };

    await prefs.setString(
      walletStorageKey,
      jsonEncode(data),
    );
  }

  // ============================================================
  // ADD MONEY
  // ============================================================

  Future<void> _addMoney(double amount) async {
    if (!mounted) return;

    setState(() {
      _walletBalance += amount;

      _transactions.insert(
        0,
        {
          'title': 'Money Added',
          'description': 'Wallet top-up',
          'amount': amount,
          'type': 'credit',
          'date': _formatDate(DateTime.now()),
        },
      );
    });

    await _saveWallet();

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹${amount.toStringAsFixed(0)} added to your wallet.',
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // ADD MONEY DIALOG
  // ============================================================

  void _showAddMoneyDialog() {
    const amounts = [
      100.0,
      200.0,
      500.0,
      1000.0,
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Add Money',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an amount to add to your Sangam wallet.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...amounts.map(
                    (amount) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _addMoney(amount);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: const BorderSide(
                            color: primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Add ₹${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // REDEEM POINTS
  // ============================================================

  Future<void> _redeemPoints() async {
    if (_loyaltyPoints < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need at least 100 points to redeem.',
          ),
        ),
      );
      return;
    }

    const pointsToRedeem = 100;
    const walletReward = 10.0;

    if (!mounted) return;

    setState(() {
      _loyaltyPoints -= pointsToRedeem;
      _walletBalance += walletReward;

      _transactions.insert(
        0,
        {
          'title': 'Points Redeemed',
          'description': '100 loyalty points → ₹10 wallet',
          'amount': walletReward,
          'type': 'credit',
          'date': _formatDate(DateTime.now()),
        },
      );
    });

    await _saveWallet();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '100 points redeemed for ₹10 wallet credit.',
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Wallet & Loyalty',
              style: TextStyle(
                fontWeight: FontWeight.w900,
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
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: _loadWallet,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 18,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (isDesktop)
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildWalletCard(),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _buildLoyaltyCard(),
                            ),
                          ],
                        )
                      else ...[
                        _buildWalletCard(),
                        const SizedBox(height: 18),
                        _buildLoyaltyCard(),
                      ],
                      const SizedBox(height: 22),
                      _buildRewardsInfo(),
                      const SizedBox(height: 22),
                      _buildTransactionHistory(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WALLET CARD
  // ============================================================

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075C2A),
            Color(0xFF087A35),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
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
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Sangam Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: orange,
                size: 23,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${_walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showAddMoneyDialog,
              icon: const Icon(
                Icons.add_rounded,
                size: 21,
              ),
              label: const Text(
                'ADD MONEY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOYALTY CARD
  // ============================================================

  Widget _buildLoyaltyCard() {
    const int nextReward = 200;

    final double progress =
    (_loyaltyPoints / nextReward).clamp(0.0, 1.0);

    final int pointsRemaining =
    nextReward - _loyaltyPoints <= 0
        ? 0
        : nextReward - _loyaltyPoints;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DC),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: orange,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sangam Loyalty',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Earn points on every purchase',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '$_loyaltyPoints',
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'points',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: lightGreen,
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$pointsRemaining points more to reach ₹20 reward',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _redeemPoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'REDEEM 100 POINTS',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARDS INFO
  // ============================================================

  Widget _buildRewardsInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: primaryGreen,
                size: 23,
              ),
              SizedBox(width: 10),
              Text(
                'How you earn rewards',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildRewardRow(
            Icons.shopping_bag_outlined,
            'Shop on Sangam Dairy',
            'Earn loyalty points on eligible purchases.',
          ),
          const SizedBox(height: 12),
          _buildRewardRow(
            Icons.people_outline_rounded,
            'Refer friends',
            'Earn rewards when your friends join.',
          ),
          const SizedBox(height: 12),
          _buildRewardRow(
            Icons.local_shipping_outlined,
            'Subscribe',
            'Enjoy convenient recurring milk deliveries.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARD ROW
  // ============================================================

  Widget _buildRewardRow(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION HISTORY
  // ============================================================

  Widget _buildTransactionHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_transactions.isNotEmpty)
                Text(
                  '${_transactions.length} transactions',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          if (_transactions.isEmpty)
            _buildEmptyTransactions()
          else
            Column(
              children: List.generate(
                _transactions.length,
                    (index) {
                  return _buildTransactionItem(
                    _transactions[index],
                    index ==
                        _transactions.length - 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION ITEM
  // ============================================================

  Widget _buildTransactionItem(
      Map<String, dynamic> transaction,
      bool isLast,
      ) {
    final String title =
        transaction['title']?.toString() ??
            'Transaction';

    final String description =
        transaction['description']?.toString() ??
            '';

    final String date =
        transaction['date']?.toString() ?? '';

    final String type =
        transaction['type']?.toString().toLowerCase() ??
            'credit';

    final dynamic rawAmount =
    transaction['amount'];

    final double amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(
      rawAmount?.toString() ?? '',
    ) ??
        0;

    final bool isCredit = type == 'credit';

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredit
                  ? lightGreen
                  : const Color(0xFFFFEEEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit
                  ? primaryGreen
                  : Colors.red.shade600,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isCredit
                  ? primaryGreen
                  : Colors.red.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY TRANSACTIONS
  // ============================================================

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primaryGreen,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No transactions yet',
            style: TextStyle(
              color: darkGreen,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your wallet activity will appear here.',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
