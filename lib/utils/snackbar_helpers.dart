import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSaving(String message) {
  // No-op: saving snackbars are removed in favour of showing only the result.
}

void showSaved(String message) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    messageText: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    ),
    backgroundColor: const Color(0xFF2E7D32),
    duration: const Duration(seconds: 2),
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  );
}

void showSaveError(String message) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    messageText: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    ),
    backgroundColor: const Color(0xFFC62828),
    duration: const Duration(seconds: 4),
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 12,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  );
}
