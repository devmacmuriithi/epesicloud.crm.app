import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales/visits_controller.dart';
import '../../utils/app_colors.dart';

class VisitsView extends StatelessWidget {
  const VisitsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VisitsController controller = Get.put(VisitsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open contact/account search to start unplanned visit
          Get.snackbar('Unplanned', 'Select account dialog...');
          // E.g. controller.startUnplannedVisit(mockAccountId);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Unplanned Visit', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Render simple list of historical visits
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            Text(
              'Recent Visits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.divider),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.location_on, color: Colors.white),
                ),
                title: Text('Placeholder Account'),
                subtitle: Text('Unplanned • Today 11:00 AM'),
                trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      }),
    );
  }
}
