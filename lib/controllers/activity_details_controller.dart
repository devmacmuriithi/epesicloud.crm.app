import 'package:get/get.dart';
import '../../models/crm_models.dart';

class ActivityDetailsController extends GetxController {
  late ActivityModel activity;
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ActivityModel) {
      activity = Get.arguments;
    } else {
      activity = ActivityModel(
        id: 0,
        subject: 'Activity Details',
        type: 'Call',
        status: 'Not Started',
        dueDate: 'N/A',
      );
    }
  }
}
