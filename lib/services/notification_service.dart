import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

class NotificationService {
  void showNotification(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info,
  }) {
    try {
      DelightToastBar(
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        builder: (ctx) {
          return ToastCard(
            leading: Icon(icon, size: 30),
            title: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
      ).show(context);
    } catch (e) {
      throw Exception("Notification: $e couldn't be loaded");
    }
  }
}
