import 'package:get/get.dart';

class AppNavigatorController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTabIndex(int index) {
    if (index != 4) {
      selectedIndex.value = index;
    }
  }
}
