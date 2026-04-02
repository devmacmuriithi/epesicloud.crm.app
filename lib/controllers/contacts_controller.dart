import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';

class ContactsController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  var contacts = <ContactModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    isLoading.value = true;
    try {
      final fetchedContacts = await _crmService.getContacts();
      contacts.assignAll(fetchedContacts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openContactDetails(ContactModel contact) {
    Get.toNamed('/contact-details', arguments: contact);
  }

  void filterContacts(String query) {
    if (query.isEmpty) {
      fetchContacts();
      return;
    }
    final filtered = contacts.where((contact) => 
      contact.fullName.toLowerCase().contains(query.toLowerCase()) ||
      contact.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
    contacts.assignAll(filtered);
  }

  Future<bool> createContact(Map<String, dynamic> contactData) async {
    try {
      await _crmService.createContact(contactData);
      fetchContacts();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create contact: $e');
      return false;
    }
  }
}
