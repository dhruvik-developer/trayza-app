import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/business_logo.dart';

class AppBootstrapScreen extends StatelessWidget {
  const AppBootstrapScreen({
    super.key,
    this.logoUrl,
    this.catersName,
    required this.primaryColor,
    this.error,
    required this.onRetry,
  });

  final String? logoUrl;
  final String? catersName;
  final Color primaryColor;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = catersName?.trim().isNotEmpty == true
        ? catersName!.trim()
        : 'Trayza Admin';
    final isDark = theme.brightness == Brightness.dark;
    final backgroundBase =
        isDark ? const Color(0xFF081018) : const Color(0xFFF7F4EE);
    final panelColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = Colors.white.withValues(alpha: isDark ? 0.12 : 0.65);
    final shadowColor = primaryColor.withValues(alpha: isDark ? 0.28 : 0.16);

    return Scaffold(
      body: DecoratedBox(
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
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.92, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0, 1),
                          child: child,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 360),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 34,
                          ),
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 36,
                                spreadRadius: 2,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 134,
                                height: 134,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: primaryColor.withValues(
                                      alpha: isDark ? 0.18 : 0.10,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: BusinessLogo(
                                  logoUrl: logoUrl,
                                  height: 88,
                                  width: 88,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 52,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                  letterSpacing: -1.1,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
