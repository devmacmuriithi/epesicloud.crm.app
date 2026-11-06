import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Services/app_exceptions.dart';
import '../Services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      isLoading.value = true;
      try {
        final success = await _authService.login(email.trim(), password);
        
        if (success) {
          Get.offNamed('/main');
        } else {
          Get.snackbar(
            'Login Failed',
            'Invalid email or password',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      } catch (e) {
        String errorMessage = 'Invalid email or password';
        if (e is AppException && e.message != null && e.message!.isNotEmpty) {
          errorMessage = e.message!;
        } else if (e is String) {
          errorMessage = e;
        }
        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar(
        'Required Fields',
        'Please enter both email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
