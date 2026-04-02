import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';

class ProjectsController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  var projects = <ProjectModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    isLoading.value = true;
    try {
      final fetchedProjects = await _crmService.getProjects();
      projects.assignAll(fetchedProjects);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch projects: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterProjects(String query) {
    if (query.isEmpty) {
      fetchProjects();
      return;
    }
    final filtered = projects.where((project) => 
      project.name.toLowerCase().contains(query.toLowerCase()) ||
      (project.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
    projects.assignAll(filtered);
  }
}
