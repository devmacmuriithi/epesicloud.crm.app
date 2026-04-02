import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/crm_models.dart';
import '../../controllers/contacts_controller.dart';

class ContactDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late ContactModel contact;

  @override
  void onInit() {
    super.onInit();
    contact = Get.arguments as ContactModel? ??
        ContactModel(
          id: 0,
          firstName: 'Alex',
          lastName: 'Thompson',
          title: 'Senior Account Manager',
          email: 'alex@example.com',
          phone: '+1 (555) 123-4567',
          isActive: true,
        );
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
