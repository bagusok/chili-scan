import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Toast {
  static void success({required String title, required String message}) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
    );
  }

  static void error({required String title, required String message}) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
    );
  }
}
