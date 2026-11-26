import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  // ============================================================
  // STORAGE
  // ============================================================

  static const String _storageKey = 'sangam_referral_data';

  // ============================================================
  // REFERRAL DATA
  // ============================================================

  String _referralCode = 'SANGAMGOPI10';

  int _friendsReferred = 0;
  double _totalRewards = 0;

  List<Map<String, dynamic>> _referralHistory = [];

  bool _loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadReferralData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_storageKey);

    if (savedData != null && savedData.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedData);

        if (decoded is Map<String, dynamic>) {
          _referralCode =
              decoded['referralCode']?.toString() ?? _referralCode;

          _friendsReferred =
              int.tryParse(
                decoded['friendsReferred']?.toString() ?? '',
              ) ??
                  0;

          _totalRewards =
              double.tryParse(
                decoded['totalRewards']?.toString() ?? '',
              ) ??
                  0;

          final history = decoded['history'];

          if (history is List) {
            _referralHistory = history
                .whereType<Map>()
                .map(
                  (item) => Map<String, dynamic>.from(item),
            )
                .toList();
          }
        }
      } catch (_) {
        // Keep default values if saved data is invalid.
      }
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  // ============================================================
  // COPY CODE
  // ============================================================

  Future<void> _copyReferralCode() async {
    await Clipboard.setData(
      ClipboardData(text: _referralCode),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Referral code copied successfully.',
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SHARE CODE
  // ============================================================

  void _shareReferralCode() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // HANDLE
                // ------------------------------------------------

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Invite Friends',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Share your Sangam Dairy referral code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------
                // REFERRAL MESSAGE
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: pageBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE0E7E1),
                    ),
                  ),
                  child: Text(
                    'Enjoy fresh Sangam Dairy products every day! '
                        'Use my referral code $_referralCode and '
                        'get rewarded.',
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: darkGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // SHARE OPTIONS
                // ------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.copy_rounded,
                        title: 'Copy',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _copyReferralCode();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.message_rounded,
                        title: 'Message',
                        onTap: () {
                          Navigator.of(sheetContext).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Message sharing will be connected in the final release.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShareOption(
                        icon: Icons.share_rounded,
                        title: 'Share',
                        onTap: () {
                          Navigator.of(sheetContext).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Share option selected.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SHARE OPTION
  // ============================================================

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primaryGreen,
              size: 23,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REFERRAL CODE CARD
  // ============================================================

  Widget _buildReferralCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075C2A),
            Color(0xFF087A35),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------
          // TOP
          // ------------------------------------------------

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFER & EARN',
                      style: TextStyle(
                        color: orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Invite your friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Share Sangam Dairy with your friends and earn rewards when they join.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // CODE
          // ------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Referral Code',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _referralCode,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _copyReferralCode,
                  tooltip: 'Copy',
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // SHARE BUTTON
          // ------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _shareReferralCode,
              icon: const Icon(
                Icons.share_rounded,
                size: 20,
              ),
              label: const Text(
                'INVITE FRIENDS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: darkGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_alt_outlined,
            value: '$_friendsReferred',
            label: 'Friends Referred',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.currency_rupee_rounded,
            value:
            '₹${_totalRewards.toStringAsFixed(0)}',
            label: 'Total Rewards',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOW IT WORKS
  // ============================================================

  Widget _buildHowItWorks() {
    final steps = [
      (
      Icons.share_outlined,
      'Share your code',
      'Send your referral code to friends and family.',
      ),
      (
      Icons.person_add_alt_1_rounded,
      'Friend joins',
      'Your friend signs up using your referral code.',
      ),
      (
      Icons.card_giftcard_rounded,
      'Earn rewards',
      'You receive rewards after the referral is completed.',
      ),
    ];

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
          const Text(
            'How Refer & Earn Works',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            steps.length,
                (index) {
              final step = steps[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == steps.length - 1
                      ? 0
                      : 18,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: Icon(
                        step.$1,
                        color: primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.$3,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARD CARD
  // ============================================================

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFE0A3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: orange,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn ₹50 per successful referral',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Referral rewards will be added to your Sangam Wallet.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REFERRAL HISTORY
  // ============================================================

  Widget _buildReferralHistory() {
    if (_referralHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE0E7E1),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                color: primaryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No referrals yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Invite your friends and start earning rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0E7E1),
        ),
      ),
      child: Column(
        children: List.generate(
          _referralHistory.length,
              (index) {
            final referral = _referralHistory[index];

            final name =
                referral['name']?.toString() ?? 'Friend';

            final status =
                referral['status']?.toString() ?? 'Pending';

            final reward =
                referral['reward']?.toString() ?? '₹0';

            return Padding(
              padding: EdgeInsets.only(
                bottom: index ==
                    _referralHistory.length - 1
                    ? 0
                    : 15,
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: status == 'Completed'
                                ? primaryGreen
                                : Colors.orange.shade700,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    reward,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >= 900;

            return Column(
              children: [
                // ==================================================
                // APP BAR
                // ==================================================

                Container(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 16,
                    14,
                    16,
                    14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE4E9E5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Refer & Earn',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: darkGreen,
                          ),
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          color: primaryGreen,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 28 : 16,
                      22,
                      isDesktop ? 28 : 16,
                      35,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 1100
                              : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ========================================
                            // HERO
                            // ========================================

                            _buildReferralCodeCard(),

                            const SizedBox(height: 18),

                            // ========================================
                            // STATS
                            // ========================================

                            _buildStats(),

                            const SizedBox(height: 22),

                            // ========================================
                            // REWARD
                            // ========================================

                            _buildRewardCard(),

                            const SizedBox(height: 22),

                            // ========================================
                            // HOW IT WORKS
                            // ========================================

                            _buildHowItWorks(),

                            const SizedBox(height: 22),

                            // ========================================
                            // HISTORY TITLE
                            // ========================================

                            const Text(
                              'Referral History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: darkGreen,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ========================================
                            // HISTORY
                            // ========================================

                            _buildReferralHistory(),
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
