import 'package:flutter/material.dart';

class RewardsCouponsScreen extends StatelessWidget {
  const RewardsCouponsScreen({super.key});

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);
  static const Color textGrey = Color(0xFF69736B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: orange, size: 22),
            SizedBox(width: 8),
            Text(
              'Rewards & Gift Cards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // COMING SOON HERO BANNER
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [darkGreen, primaryGreen],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'COMING SOON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exciting Rewards &\nGift Cards on the Way!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We are cooking up an amazing rewards program and gift card coupon system for Sangam Dairy customers. Stay tuned!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Upcoming Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'What you will experience very soon in Sangam Dairy',
              style: TextStyle(
                fontSize: 12,
                color: textGrey,
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // FEATURE 1: REWARDS & LOYALTY
            // ============================================================
            _buildFeatureCard(
              icon: Icons.stars_rounded,
              title: 'Dairy Loyalty Rewards',
              subtitle: 'Earn points on every milk, ghee, paneer & sweet purchase and redeem them for direct discounts.',
              badge: 'Coming Soon',
            ),

            const SizedBox(height: 14),

            // ============================================================
            // FEATURE 2: GIFT CARD COUPONS
            // ============================================================
            _buildFeatureCard(
              icon: Icons.redeem_rounded,
              title: 'Gift Card Coupons',
              subtitle: 'Send digital gift cards to your family & friends or apply festival special promo coupons at checkout.',
              badge: 'Coming Soon',
            ),

            const SizedBox(height: 14),

            // ============================================================
            // FEATURE 3: MILESTONE PERKS
            // ============================================================
            _buildFeatureCard(
              icon: Icons.military_tech_rounded,
              title: 'Milestone Tier Perks',
              subtitle: 'Unlock silver, gold, and platinum member tiers with exclusive dairy delivery privileges and cashbacks.',
              badge: 'Coming Soon',
            ),

            const SizedBox(height: 28),

            // ============================================================
            // NOTIFICATION NOTICE BOX
            // ============================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: primaryGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Want to be notified?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: darkGreen,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'We will notify you via app notifications as soon as rewards and coupons go live.',
                          style: TextStyle(
                            fontSize: 12,
                            color: textGrey,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2EAE3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: darkGreen,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
