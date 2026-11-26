import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SangamLogo extends StatelessWidget {
  final double size;
  final bool hasBorder;
  final bool isCircular;

  const SangamLogo({
    super.key,
    this.size = 80,
    this.hasBorder = true,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(size * 0.3),
        border: hasBorder
            ? Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle background glow
          Container(
            decoration: BoxDecoration(
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircular ? null : BorderRadius.circular(size * 0.2),
              gradient: RadialGradient(
                colors: [
                  AppTheme.cream.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(isCircular ? size : size * 0.15),
            child: Image.asset(
              'assets/images/sangam_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.water_drop_rounded,
                  color: AppTheme.primaryGreen,
                  size: size * 0.5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SangamWatermark extends StatelessWidget {
  final Widget child;
  final double opacity;

  const SangamWatermark({
    super.key,
    required this.child,
    this.opacity = 0.025, // Even subtler for premium feel
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class SangamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;

  const SangamCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 28),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 28),
        child: card,
      );
    }

    return card;
  }
}

class SangamScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showWatermark;
  final Color? backgroundColor;

  const SangamScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showWatermark = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (showWatermark) {
      content = SangamWatermark(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.background,
      appBar: appBar,
      body: SafeArea(child: content),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
