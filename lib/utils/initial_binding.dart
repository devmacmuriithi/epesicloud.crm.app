import 'package:get/get.dart';
import '../Services/auth_service.dart';
import '../Services/api_service.dart';
import '../Services/crm_service.dart';
import '../Services/lookups_service.dart';
import '../Services/fieldforce_service.dart';
import '../controllers/sales/map_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(LookupsService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(CrmService(), permanent: true);
    Get.put(FieldforceService(), permanent: true);
    Get.put(CrmMapController(), permanent: true);
  }
}
