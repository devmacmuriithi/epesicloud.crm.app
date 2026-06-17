import 'package:get/get.dart';

class AppNavigatorController extends GetxController {
  var selectedIndex = 0.obs;
  var salesTabIndex = 0.obs; // Default to 'Deals'

  void changeTabIndex(int index) {
    if (index != 4) {
      selectedIndex.value = index;
    }
  }

  void goToSalesTab(int subTabIndex) {
    salesTabIndex.value = subTabIndex;
    selectedIndex.value = 1; // 1 is Sales in AppNavigator.dart
  }
}
