import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'support_chat_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);

  // ============================================================
  // SUPPORT CONTACT DETAILS
  // ============================================================

  // IMPORTANT:
  // Replace these with your REAL Sangam Dairy support details.
  static const String supportPhone = '18004567890';
  static const String supportPhoneDisplay = '1800-456-7890';

  static const String supportEmail = 'care@sangamdairy.com';

  // ============================================================
  // FAQ DATA
  // ============================================================

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How can I track my order?',
      'answer':
      'Open My Orders from your profile and tap Track Order on the order you want to track.',
    },
    {
      'question': 'What payment methods are available?',
      'answer':
      'You can pay using PhonePe, Google Pay, Debit/Credit Card, Net Banking, or Cash on Delivery.',
    },
    {
      'question': 'How does milk subscription work?',
      'answer':
      'Choose your preferred milk, quantity, delivery frequency and start date from the Subscriptions section.',
    },
    {
      'question': 'Can I change my delivery address?',
      'answer':
      'Yes. You can update your delivery address, city and pincode from your Profile section.',
    },
    {
      'question': 'Can I cancel my order?',
      'answer':
      'Order cancellation depends on the current order status. Please contact support for assistance.',
    },
    {
      'question': 'What should I do if an item is missing?',
      'answer':
      'Please contact Sangam Dairy support with your order number and details of the missing item.',
    },
  ];

  final Set<int> _expandedFaqs = <int>{};

  // ============================================================
  // SUPPORT DIALOG
  // ============================================================

  void _showSupportDialog({
    required String title,
    required IconData icon,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: primaryGreen,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CHAT
  // ============================================================

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SupportChatScreen(),
      ),
    );
  }

  // ============================================================
  // CALL
  // ============================================================

  Future<void> _openCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );

    try {
      final bool launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showSupportDialog(
          title: 'Call Us',
          icon: Icons.phone_outlined,
          message:
          'Unable to open the phone application.\n\n'
              'Please call:\n\n'
              '$supportPhoneDisplay',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSupportDialog(
        title: 'Call Us',
        icon: Icons.phone_outlined,
        message:
        'Unable to open the phone application.\n\n'
            'Please call:\n\n'
            '$supportPhoneDisplay',
      );
    }
  }

  // ============================================================
  // EMAIL
  // ============================================================

  Future<void> _openEmail() async {
    final Map<String, String> queryParameters = {
      'subject': 'Sangam Dairy Support',
      'body':
      'Hello Sangam Dairy Support,\n\n'
          'I need help regarding my Sangam Dairy order.\n\n'
          'Please assist me.\n',
    };

    final String query = queryParameters.entries
        .map(
          (entry) =>
      '${Uri.encodeComponent(entry.key)}='
          '${Uri.encodeComponent(entry.value)}',
    )
        .join('&');

    final Uri emailUri = Uri.parse(
      'mailto:$supportEmail?$query',
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showSupportDialog(
          title: 'Email Support',
          icon: Icons.email_outlined,
          message:
          'Unable to open the email application.\n\n'
              'Please email:\n\n'
              '$supportEmail',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showSupportDialog(
        title: 'Email Support',
        icon: Icons.email_outlined,
        message:
        'Unable to open the email application.\n\n'
            'Please email:\n\n'
            '$supportEmail',
      );
    }
  }

  // ============================================================
  // FAQ TILE
  // ============================================================

  Widget _buildFaqTile({
    required int index,
    required String question,
    required String answer,
  }) {
    final bool expanded = _expandedFaqs.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE1E8E2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedFaqs.remove(index);
                } else {
                  _expandedFaqs.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primaryGreen,
                    size: 25,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
              ),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SUPPORT OPTION CARD
  // ============================================================

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE1E8E2),
            ),
          ),
          child: Column(
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
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: darkGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT CARD
  // ============================================================

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF075C2A),
            Color(0xFF087A35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 600;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We are here to help',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get help with your Sangam Dairy experience.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (compact)
                Column(
                  children: [
                    _buildContactButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Chat',
                      onTap: _openChat,
                    ),
                    const SizedBox(height: 10),
                    _buildContactButton(
                      icon: Icons.phone_outlined,
                      title: 'Call',
                      onTap: _openCall,
                    ),
                    const SizedBox(height: 10),
                    _buildContactButton(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      onTap: _openEmail,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Chat',
                        onTap: _openChat,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.phone_outlined,
                        title: 'Call',
                        onTap: _openCall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        onTap: _openEmail,
                      ),
                    ),
                  ],
                ),
            ],
          );

          return content;
        },
      ),
    );
  }

  // ============================================================
  // CONTACT BUTTON
  // ============================================================

  Widget _buildContactButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.35),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
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
      appBar: AppBar(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 0 : 16,
                vertical: 24,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1180,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HERO
                        // ==================================================

                        _buildContactCard(),

                        const SizedBox(height: 32),

                        // ==================================================
                        // QUICK HELP
                        // ==================================================

                        const Text(
                          'How can we help you?',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'Choose a support option for quick assistance.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        LayoutBuilder(
                          builder: (context, innerConstraints) {
                            final double width =
                                innerConstraints.maxWidth;

                            int columns;

                            if (width >= 1000) {
                              columns = 4;
                            } else if (width >= 700) {
                              columns = 2;
                            } else {
                              columns = 1;
                            }

                            const double spacing = 14;

                            final double cardWidth =
                                (width - ((columns - 1) * spacing)) /
                                    columns;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _buildSupportCard(
                                    icon: Icons.shopping_bag_outlined,
                                    title: 'Order Help',
                                    subtitle:
                                    'Track or manage your orders',
                                    onTap: () {
                                      _showSupportDialog(
                                        title: 'Order Help',
                                        icon:
                                        Icons.shopping_bag_outlined,
                                        message:
                                        'For order related assistance, open My Orders and check your order status or Track Order option.',
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _buildSupportCard(
                                    icon:
                                    Icons.local_shipping_outlined,
                                    title: 'Delivery Help',
                                    subtitle:
                                    'Questions about delivery',
                                    onTap: () {
                                      _showSupportDialog(
                                        title: 'Delivery Help',
                                        icon:
                                        Icons.local_shipping_outlined,
                                        message:
                                        'For delivery assistance, check your order tracking information or contact Sangam Dairy support.',
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _buildSupportCard(
                                    icon: Icons
                                        .account_balance_wallet_outlined,
                                    title: 'Payment Help',
                                    subtitle:
                                    'Payment related assistance',
                                    onTap: () {
                                      _showSupportDialog(
                                        title: 'Payment Help',
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        message:
                                        'Sangam Dairy supports PhonePe, Google Pay, Debit/Credit Card, Net Banking and Cash on Delivery.',
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _buildSupportCard(
                                    icon: Icons.repeat_rounded,
                                    title: 'Subscription Help',
                                    subtitle:
                                    'Manage your milk subscription',
                                    onTap: () {
                                      _showSupportDialog(
                                        title: 'Subscription Help',
                                        icon: Icons.repeat_rounded,
                                        message:
                                        'You can manage your milk subscription from the Subscriptions section and view delivery dates in Delivery Calendar.',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // FAQ TITLE
                        // ==================================================

                        const Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'Quick answers to common questions.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // FAQ LIST
                        // ==================================================

                        ...List.generate(
                          _faqs.length,
                              (index) {
                            final faq = _faqs[index];

                            return _buildFaqTile(
                              index: index,
                              question: faq['question'] ?? '',
                              answer: faq['answer'] ?? '',
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // CONTACT US
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFE1E8E2),
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
                                      color: lightGreen,
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.headset_mic_outlined,
                                      color: primaryGreen,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Still need help?',
                                          style: TextStyle(
                                            color: darkGreen,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Our support team is ready to assist you.',
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

                              const SizedBox(height: 18),

                              const Divider(
                                color: Color(0xFFE8EDE9),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      supportPhoneDisplay,
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _openCall,
                                    child: const Text(
                                      'Contact',
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      supportEmail,
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _openEmail,
                                    child: const Text(
                                      'Email',
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // FOOTER
                        // ==================================================

                        const Center(
                          child: Column(
                            children: [
                              Text(
                                'Sangam Dairy',
                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Quality milk. Trusted every day.',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
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
