import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../color_class.dart';

/// Show a Snack bar using Fluttertoast
class CustomeToast {
  static void showSuccess(String message) {
    Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.notifications_active),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: ColorsClass.primary,
      alignment: Alignment.topRight,
    );
  }

  static void showError(String message) {
    Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.error),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: Colors.red,
      alignment: Alignment.topRight,
    );
  }
}
