import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/clickable.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color darkGreen = Color(0xFF087A35);
  static const Color orange = Color(0xFFFFAE18);
  static const Color white = Colors.white;

  // ============================================================
  // BANNER DATA
  // ============================================================

  final List<Map<String, String>> banners = [
    {
      'image': 'assets/images/sangam_farm.png',
      'title': 'Farm Fresh. Pure Always.',
      'subtitle':
      'Sourced directly from co-operative farmers for unparalleled purity & nutrition.',
    },
    {
      'image': 'assets/images/sangam_milk_collection.png',
      'title': 'Pure Dairy. Every Day.',
      'subtitle':
      'Fresh and trusted dairy products delivered with care to your doorstep.',
    },
    {
      'image': 'assets/images/sangam_dairy_products.png',
      'title': 'Quality You Can Trust.',
      'subtitle':
      'Fresh, hygienic and delicious dairy products for your family.',
    },
  ];

  // ============================================================
  // CONTROLLER
  // ============================================================

  late final PageController _pageController;

  Timer? _autoSlideTimer;

  int _currentPage = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
    );

    _startAutoSlide();
  }

  // ============================================================
  // AUTO SLIDE
  // ============================================================

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!_pageController.hasClients) {
          return;
        }

        int nextPage = _currentPage + 1;

        if (nextPage >= banners.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  // ============================================================
  // PAGE CHANGE
  // ============================================================

  void _onPageChanged(int page) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _nextPage() {
    if (!_pageController.hasClients) {
      return;
    }

    int nextPage = _currentPage + 1;

    if (nextPage >= banners.length) {
      nextPage = 0;
    }

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  void _previousPage() {
    if (!_pageController.hasClients) {
      return;
    }

    int previousPage = _currentPage - 1;

    if (previousPage < 0) {
      previousPage = banners.length - 1;
    }

    _pageController.animateToPage(
      previousPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  // ============================================================
  // GET STARTED
  // ============================================================

  void _getStarted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isSmallScreen = size.height < 700;
    final bool isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: darkGreen,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = isMobile
                ? constraints.maxWidth - 32
                : 1240;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 0,
                      vertical: isSmallScreen ? 10 : 18,
                    ),
                    child: Column(
                      children: [
                        // ==================================================
                        // LOGO
                        // ==================================================

                        _buildLogo(
                          isMobile: isMobile,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(
                          height: isSmallScreen ? 8 : 12,
                        ),

                        // ==================================================
                        // BRAND NAME
                        // ==================================================

                        const Text(
                          'SANGAM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.5,
                            height: 1,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'DAIRY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'FARM FRESH. PURE ALWAYS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: orange,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),

                        SizedBox(
                          height: isSmallScreen ? 22 : 32,
                        ),

                        // ==================================================
                        // BANNER
                        // ==================================================

                        _buildBanner(
                          width: maxWidth,
                          isMobile: isMobile,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(
                          height: isSmallScreen ? 12 : 18,
                        ),

                        // ==================================================
                        // DOTS
                        // ==================================================

                        _buildPageIndicators(),

                        SizedBox(
                          height: isSmallScreen ? 16 : 28,
                        ),

                        // ==================================================
                        // GET STARTED
                        // ==================================================

                        _buildGetStartedButton(
                          isMobile: isMobile,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(
                          height: isSmallScreen ? 16 : 28,
                        ),

                        // ==================================================
                        // FOOTER FEATURES
                        // ==================================================

                        _buildFooterFeatures(
                          isMobile: isMobile,
                        ),

                        SizedBox(
                          height: isSmallScreen ? 8 : 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo({
    required bool isMobile,
    required bool isSmallScreen,
  }) {
    final double logoSize = isMobile
        ? (isSmallScreen ? 78 : 88)
        : (isSmallScreen ? 90 : 108);

    return Container(
      width: logoSize,
      height: logoSize,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: orange,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.asset(
          'assets/images/sangam_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: darkGreen,
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  Widget _buildBanner({
    required double width,
    required bool isMobile,
    required bool isSmallScreen,
  }) {
    final double bannerHeight = isMobile
        ? (isSmallScreen ? 280 : 350)
        : (isSmallScreen ? 400 : 460);

    return SizedBox(
      width: width,
      height: bannerHeight,
      child: Stack(
        children: [
          // ========================================================
          // PAGE VIEW
          // ========================================================

          ClipRRect(
            borderRadius: BorderRadius.circular(
              isMobile ? 24 : 30,
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildBannerItem(
                  banners[index],
                  isMobile: isMobile,
                );
              },
            ),
          ),

          // ========================================================
          // LEFT ARROW
          // ========================================================

          if (!isMobile)
            Positioned(
              left: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _previousPage,
                ),
              ),
            ),

          // ========================================================
          // RIGHT ARROW
          // ========================================================

          if (!isMobile)
            Positioned(
              right: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _nextPage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BANNER ITEM
  // ============================================================

  Widget _buildBannerItem(
      Map<String, String> banner, {
        required bool isMobile,
      }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ========================================================
        // IMAGE
        // ========================================================

        Image.asset(
          banner['image']!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFE8F5E9),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: darkGreen,
                  size: 50,
                ),
              ),
            );
          },
        ),

        // ========================================================
        // DARK GRADIENT
        // ========================================================

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0.35,
                0.68,
                1.0,
              ],
              colors: [
                Colors.transparent,
                Color(0x22000000),
                Color(0xE6000000),
              ],
            ),
          ),
        ),

        // ========================================================
        // TEXT
        // ========================================================

        Positioned(
          left: isMobile ? 22 : 28,
          right: isMobile ? 22 : 28,
          bottom: isMobile ? 22 : 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner['title']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: white,
                  fontSize: isMobile ? 22 : 27,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                banner['subtitle']!,
                maxLines: isMobile ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: white,
                  fontSize: isMobile ? 12.5 : 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // PREMIUM CORNER ICON
        // ========================================================

        Positioned(
          right: 24,
          bottom: 24,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: white.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: white,
              size: 19,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ARROW BUTTON
  // ============================================================

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Clickable(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.40),
              shape: BoxShape.circle,
              border: Border.all(
                color: white.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(
              icon,
              color: white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE INDICATORS
  // ============================================================

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        banners.length,
            (index) {
          final bool active = index == _currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: active ? 34 : 9,
            height: 9,
            decoration: BoxDecoration(
              color: active
                  ? orange
                  : white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // GET STARTED BUTTON
  // ============================================================

  Widget _buildGetStartedButton({
    required bool isMobile,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isMobile
          ? (isSmallScreen ? 58 : 66)
          : (isSmallScreen ? 62 : 72),
      child: Clickable(
        onTap: _getStarted,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _getStarted,
            borderRadius: BorderRadius.circular(24),
            mouseCursor: SystemMouseCursors.click,
            child: Ink(
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Get Started',
                    style: TextStyle(
                      color: white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER FEATURES
  // ============================================================

  Widget _buildFooterFeatures({
    required bool isMobile,
  }) {
    if (isMobile) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: const [
          _FooterItem(
            icon: Icons.verified_rounded,
            text: 'Fresh',
          ),
          _FooterItem(
            icon: Icons.verified_user_rounded,
            text: 'Trusted',
          ),
          _FooterItem(
            icon: Icons.favorite_rounded,
            text: 'Quality Dairy',
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _FooterItem(
          icon: Icons.verified_rounded,
          text: 'Fresh',
        ),
        SizedBox(width: 22),
        _FooterDot(),
        SizedBox(width: 22),
        _FooterItem(
          icon: Icons.verified_user_rounded,
          text: 'Trusted',
        ),
        SizedBox(width: 22),
        _FooterDot(),
        SizedBox(width: 22),
        _FooterItem(
          icon: Icons.favorite_rounded,
          text: 'Quality Dairy',
        ),
      ],
    );
  }
}

// ==================================================================
// FOOTER ITEM
// ==================================================================

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FooterItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// FOOTER DOT
// ==================================================================

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
