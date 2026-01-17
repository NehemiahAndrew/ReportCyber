import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final bool isDark;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    // Try to load the image, fallback to icon if not available
    if (icon.contains('google')) {
      return Icon(
        Icons.g_mobiledata,
        size: 24,
        color: isDark ? Colors.white : Colors.red,
      );
    } else if (icon.contains('github')) {
      return Icon(
        Icons.code,
        size: 24,
        color: isDark ? Colors.white : Colors.black87,
      );
    }
    return const SizedBox(width: 24, height: 24);
  }
}
