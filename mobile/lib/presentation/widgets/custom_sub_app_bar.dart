import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomSubAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBackPressed;

  const CustomSubAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.ground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderQuiet,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Flat Back Button
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.borderQuiet,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.ink,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle (Left aligned, max 2 lines, clean hierarchy)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.headline.copyWith(
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.inkSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
