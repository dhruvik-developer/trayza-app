import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    required this.primaryColor,
  });

  final Widget child;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundBase =
        isDark ? const Color(0xFF081018) : const Color(0xFFF7F4EE);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              primaryColor.withValues(alpha: isDark ? 0.20 : 0.14),
              backgroundBase,
            ),
            backgroundBase,
            Color.alphaBlend(
              primaryColor.withValues(alpha: isDark ? 0.10 : 0.06),
              backgroundBase,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _GlowOrb(
              color: primaryColor.withValues(alpha: 0.26),
              size: 230,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -70,
            child: _GlowOrb(
              color: primaryColor.withValues(alpha: 0.18),
              size: 260,
            ),
          ),
          Positioned(
            top: 130,
            left: 32,
            child: _AccentRing(
              color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
              size: 84,
            ),
          ),
          Positioned(
            bottom: 150,
            right: 42,
            child: _AccentRing(
              color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
              size: 56,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.25),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentRing extends StatelessWidget {
  const _AccentRing({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
