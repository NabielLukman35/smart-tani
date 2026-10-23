import 'package:flutter/material.dart';

enum SmartTaniLogoVariant {
  neonLime,
  white,
}

/// Logo Resmi Smart Tani TaniGreen
/// Menampilkan murni aset gambar asli yang diunggah pengguna tanpa kode painter atau badge buatan
class SmartTaniLogo extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartTaniLogo({
    super.key,
    this.size = 48,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    // Parameter kompatibilitas agar tidak merusak pemanggilan di layar lain
    SmartTaniLogoVariant? variant,
    bool? showBadge,
    bool? hasGlow,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width ?? size,
      height: height ?? size,
      fit: fit,
    );
  }
}
