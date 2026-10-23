import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum SmartTaniLogoVariant {
  neonLime,
  white,
}

/// Logo Resmi Smart Tani TaniGreen
/// Menggunakan aset asli tanpa distorsi atau bayangan berlebihan
class SmartTaniLogo extends StatelessWidget {
  final double size;
  final SmartTaniLogoVariant variant;
  final bool showBadge;
  final bool hasGlow;

  const SmartTaniLogo({
    super.key,
    this.size = 48,
    this.variant = SmartTaniLogoVariant.neonLime,
    this.showBadge = true,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.eco_rounded,
          size: size,
          color: AppTheme.accent,
        );
      },
    );

    if (!showBadge) {
      return imageWidget;
    }

    final boxSize = size * 1.35;
    final borderRadius = BorderRadius.circular(12);

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: borderRadius,
        border: Border.all(
          color: AppTheme.borderQuiet,
          width: 1,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: imageWidget,
        ),
      ),
    );
  }
}
