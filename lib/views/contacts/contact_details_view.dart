import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/contact_details_controller.dart';
import '../../utils/app_colors.dart';
import '../activities/modals/log_call_modal.dart';
import '../activities/modals/send_email_modal.dart';
import '../activities/modals/send_sms_modal.dart';

class ContactDetailsView extends StatelessWidget {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactDetailsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Contact Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          // Show 'Edit Contact' Bottom Sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.background,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Get.back(),
                  ),
                  title: const Text('Edit Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  centerTitle: true,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Full Name', controller.contact.fullName),
                      const SizedBox(height: 16),
                      _buildTextField('Job Title', controller.contact.title ?? 'N/A'),
                      const SizedBox(height: 16),
                      _buildTextField('Company', 'Unknown Company'),
                      const SizedBox(height: 16),
                      _buildTextField('Email Address', controller.contact.email, TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildTextField('Phone Number', controller.contact.phone ?? 'N/A', TextInputType.phone),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.snackbar('Success', 'Contact updated successfully',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.success,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Profile
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.contact.fullName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.contact.title ?? 'N/A',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                ),
                Text(
                  'Sales Department',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Account ID: ${controller.contact.accountId ?? "N/A"}',
                      style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleAction(Icons.phone, 'Call', onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => LogCallModal(
                            initialEntityType: 'contact',
                            initialEntityId: controller.contact.id,
                            initialEntityName: controller.contact.fullName,
                          ),
                        )),
                        _buildCircleAction(Icons.chat_bubble, 'SMS', onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SendSMSModal(
                            initialEntityType: 'contact',
                            initialEntityId: controller.contact.id,
                            initialPhone: controller.contact.phone,
                          ),
                        )),
                        _buildCircleAction(Icons.email, 'Email', onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SendEmailModal(
                            initialEntityType: 'contact',
                            initialEntityId: controller.contact.id,
                            initialEmail: controller.contact.email,
                          ),
                        )),
                        _buildCircleAction(Icons.diamond_outlined, 'Deal'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // TabBar (Scrollable)
                TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  dividerColor: AppColors.divider,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  tabs: const [
                    Tab(text: 'Identity'),
                    Tab(text: 'Professional'),
                    Tab(text: 'Contact'),
                    Tab(text: 'Address'),
                    Tab(text: 'CRM Data'),
                  ],
                ),
              ],
            ),
          ),
          
          // Using SliverFillRemaining for the scrollable content of the tab
          SliverFillRemaining(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildIdentityTabContent(controller),
                _buildProfessionalTabContent(controller),
                _buildContactTabContent(controller),
                _buildAddressTabContent(controller),
                _buildCrmDataTabContent(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTabContent(ContactDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('IDENTITY'),
          _buildInfoBox([
            _buildStackedInfoRow('Full Name', controller.contact.fullName),
            const Divider(color: AppColors.divider, height: 24),
            _buildStackedInfoRow('First Name', controller.contact.firstName),
            const Divider(color: AppColors.divider, height: 24),
            _buildStackedInfoRow('Last Name', controller.contact.lastName),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProfessionalTabContent(ContactDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('PROFESSIONAL'),
          _buildInfoBox([
            _buildRowWithTrailingIcon('Job Title', controller.contact.title ?? 'N/A', Icons.badge_outlined),
            const Divider(color: AppColors.divider, height: 24),
            _buildRowWithTrailingIcon('Department', controller.contact.department ?? 'N/A', Icons.groups_outlined),
            const Divider(color: AppColors.divider, height: 24),
            _buildRowWithTrailingIcon('Account ID', controller.contact.accountId?.toString() ?? 'N/A', Icons.business_outlined),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildContactTabContent(ContactDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('CONTACT INFORMATION'),
          _buildInfoBox([
            _buildContactRow(Icons.phone, 'Mobile', controller.contact.phone ?? 'N/A'),
            const Divider(color: AppColors.divider, height: 24),
            _buildContactRow(Icons.alternate_email, 'Work Email', controller.contact.email),
            const Divider(color: AppColors.divider, height: 24),
            _buildContactRow(Icons.phone_android, 'Other Phone', controller.contact.otherPhone ?? 'N/A'),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAddressTabContent(ContactDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ADDRESS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://snazzy-maps-cdn.azureedge.net/assets/74-one-light.png?v=20170626083204',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: AppColors.background,
                      child: const Center(child: Icon(Icons.map_outlined, color: AppColors.textSecondary)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(controller.contact.mailingStreet ?? 'No street provided', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${controller.contact.mailingCity ?? ''}, ${controller.contact.mailingState ?? ''} ${controller.contact.mailingZip ?? ''}', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13)),
                Text(controller.contact.mailingCountry ?? '', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCrmDataTabContent(ContactDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('CRM DATA'),
          Row(
            children: [
              Expanded(
                child: _buildCrmTagBox('Lead Source', controller.contact.leadSource ?? 'N/A', AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCrmTagBox('Created Time', controller.contact.createdTime ?? 'N/A', AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBox([
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Kes 124,500', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Expected Close: Dec 15', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('75% of target goal reached', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 10)),
          ]),
          const SizedBox(height: 16),
          _buildInfoBox([
            _buildStackedInfoRow('Last Contacted', 'Oct 24, 2023 • 10:15 AM'),
          ]),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildStackedInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildRowWithTrailingIcon(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Icon(icon, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildCrmTagBox(String label, String tagText, Color tagColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tagText,
              style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, [String? initialValue, TextInputType? keyboardType]) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
