import 'package:flutter/material.dart';

class BusinessLogo extends StatelessWidget {
  const BusinessLogo({
    super.key,
    this.logoUrl,
    this.height = 100,
    this.width,
    this.fit = BoxFit.contain,
  });

  final String? logoUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget fallbackLogo() => Image.asset(
          'assets/icons/logo1.png',
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => Icon(
            Icons.storefront_rounded,
            size: height * 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
        );

    final normalizedLogoUrl = logoUrl?.trim();
    if (normalizedLogoUrl == null || normalizedLogoUrl.isEmpty) {
      return fallbackLogo();
    }

    return Image.network(
      normalizedLogoUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => fallbackLogo(),
    );
  }
}
