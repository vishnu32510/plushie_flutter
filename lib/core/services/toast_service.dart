import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/services.dart';

class ToastService extends Services {
  static GlobalKey<ScaffoldMessengerState>? _messengerKey;

  static void initialize(GlobalKey<ScaffoldMessengerState> messengerKey) {
    _messengerKey = messengerKey;
  }

  static void showSuccess(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF6B8E5A),
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFB85C4A),
      icon: Icons.error,
    );
  }

  static void showInfo(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF4A7FA5),
      icon: Icons.info,
    );
  }

  static void showWarning(String message) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFD4A047),
      icon: Icons.warning,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _messengerKey?.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
