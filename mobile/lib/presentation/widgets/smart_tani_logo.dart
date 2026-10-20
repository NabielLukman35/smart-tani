import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum SmartTaniLogoVariant {
  neonLime,
  white,
}

/// Logo Iconik Smart Tani (S-Leaf Dynamic Wing)
/// Sesuai elemen desain resmi pada squircle badge palet
class SmartTaniLogo extends StatelessWidget {
  final double size;
  final SmartTaniLogoVariant variant;
  final bool showBadge;
  final bool hasGlow;

  const SmartTaniLogo({
    super.key,
    this.size = 64,
    this.variant = SmartTaniLogoVariant.neonLime,
    this.showBadge = true,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = variant == SmartTaniLogoVariant.neonLime
        ? AppTheme.neonLime
        : Colors.white;

    Widget emblem = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SmartTaniLogoPainter(
          color: logoColor,
          hasGlow: hasGlow,
        ),
      ),
    );

    if (!showBadge) {
      return emblem;
    }

    // Tampilkan di dalam Squircle Card seperti di referensi desain
    final borderRadius = BorderRadius.circular(size * 0.28);

    return Container(
      width: size * 1.35,
      height: size * 1.35,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF143B33),
            Color(0xFF0C2720),
            Color(0xFF061B14),
          ],
        ),
        border: Border.all(
          color: variant == SmartTaniLogoVariant.neonLime
              ? AppTheme.neonLime.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (variant == SmartTaniLogoVariant.neonLime
                    ? AppTheme.neonLime
                    : const Color(0xFF1ABC9C))
                .withValues(alpha: 0.18),
            blurRadius: size * 0.35,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: size * 0.2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: emblem),
    );
  }
}

class _SmartTaniLogoPainter extends CustomPainter {
  final Color color;
  final bool hasGlow;

  _SmartTaniLogoPainter({
    required this.color,
    required this.hasGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Soft glow shadow jika diaktifkan
    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.1)
        ..style = PaintingStyle.fill;

      _drawWings(canvas, size, glowPaint);
    }

    _drawWings(canvas, size, paint);
  }

  void _drawWings(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    // ── Upper Leaf / Dynamic Wing of 'S' ──
    final topPath = Path();
    topPath.moveTo(w * 0.18, h * 0.50);
    // Lengkungan naik ke puncak kiri-atas
    topPath.cubicTo(
      w * 0.18, h * 0.28,
      w * 0.38, h * 0.15,
      w * 0.65, h * 0.15,
    );
    // Ujung tajam sayap atas kanan
    topPath.cubicTo(
      w * 0.76, h * 0.15,
      w * 0.88, h * 0.20,
      w * 0.94, h * 0.26,
    );
    // Belok tajam ke dalam (sayap aerodinamis)
    topPath.cubicTo(
      w * 0.78, h * 0.32,
      w * 0.60, h * 0.30,
      w * 0.45, h * 0.38,
    );
    topPath.cubicTo(
      w * 0.32, h * 0.45,
      w * 0.24, h * 0.49,
      w * 0.18, h * 0.50,
    );
    topPath.close();

    // ── Lower Leaf / Dynamic Wing of 'S' ──
    final bottomPath = Path();
    bottomPath.moveTo(w * 0.82, h * 0.48);
    // Garis tajam melengkung ke kiri tengah
    bottomPath.cubicTo(
      w * 0.68, h * 0.56,
      w * 0.50, h * 0.58,
      w * 0.35, h * 0.63,
    );
    // Lengkungan bawah kiri
    bottomPath.cubicTo(
      w * 0.22, h * 0.68,
      w * 0.18, h * 0.76,
      w * 0.28, h * 0.84,
    );
    // Dasar bawah kanan
    bottomPath.cubicTo(
      w * 0.42, h * 0.92,
      w * 0.66, h * 0.86,
      w * 0.84, h * 0.76,
    );
    // Ujung tajam sayap bawah kanan (taper needle)
    bottomPath.cubicTo(
      w * 0.96, h * 0.70,
      w * 0.90, h * 0.66,
      w * 0.76, h * 0.68,
    );
    bottomPath.cubicTo(
      w * 0.60, h * 0.72,
      w * 0.45, h * 0.72,
      w * 0.38, h * 0.68,
    );
    bottomPath.cubicTo(
      w * 0.50, h * 0.60,
      w * 0.68, h * 0.54,
      w * 0.82, h * 0.48,
    );
    bottomPath.close();

    // ── Central Dynamic Streak / Speed Leaf ──
    final centerStreak = Path();
    centerStreak.moveTo(w * 0.16, h * 0.68);
    centerStreak.cubicTo(
      w * 0.35, h * 0.66,
      w * 0.60, h * 0.60,
      w * 0.88, h * 0.50,
    );
    centerStreak.cubicTo(
      w * 0.58, h * 0.56,
      w * 0.32, h * 0.62,
      w * 0.16, h * 0.68,
    );
    centerStreak.close();

    canvas.drawPath(topPath, paint);
    canvas.drawPath(bottomPath, paint);
    canvas.drawPath(centerStreak, paint);
  }

  @override
  bool shouldRepaint(covariant _SmartTaniLogoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.hasGlow != hasGlow;
  }
}
