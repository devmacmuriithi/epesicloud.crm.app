import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme/app_theme.dart';
import 'utils/initial_binding.dart';
import 'views/login/login_view.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/leads/leads_view.dart';
import 'views/leads/lead_details_view.dart';
import 'views/accounts/accounts_view.dart';
import 'views/accounts/account_details_view.dart';
import 'views/contacts/contacts_view.dart';
import 'views/contacts/contact_details_view.dart';
import 'views/deals/deals_view.dart';
import 'views/deals/deal_details_view.dart';
import 'views/activities/new_activity_view.dart';
import 'views/activities/activity_details_view.dart';
import 'views/tasks/tasks_view.dart';
import 'views/payments/payments_view.dart';
import 'views/notifications/notifications_view.dart';
import 'views/cases/cases_view.dart';
import 'views/cases/case_details_view.dart';
import 'views/products/products_view.dart';
import 'views/calendar/calendar_view.dart';
import 'views/sales/live_map_view.dart';
import 'views/sales/accounts_map_view.dart';
import 'navigation/AppNavigator.dart';

void main() async {
  await GetStorage.init();
  final storage = GetStorage();
  final token = storage.read('access_token');
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Epesicloud Crm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: isLoggedIn ? '/main' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/dashboard', page: () => const DashboardView()),
        GetPage(name: '/leads', page: () => const LeadsView()),
        GetPage(name: '/lead-details', page: () => const LeadDetailsView()),
        GetPage(name: '/accounts', page: () => const AccountsView()),
        GetPage(name: '/account-details', page: () => const AccountDetailsView()),
        GetPage(name: '/contacts', page: () => const ContactsView()),
        GetPage(name: '/contact-details', page: () => const ContactDetailsView()),
        GetPage(name: '/deals', page: () => const DealsView()),
        GetPage(name: '/deal-details', page: () => const DealDetailsView()),
        GetPage(name: '/new-activity', page: () => const NewActivityView(), fullscreenDialog: true),
        GetPage(name: '/activity-details', page: () => const ActivityDetailsView()),
        GetPage(name: '/tasks', page: () => const TasksView()),
        GetPage(name: '/payments', page: () => const PaymentsView()),
        GetPage(name: '/notifications', page: () => const NotificationsView()),
        GetPage(name: '/cases', page: () => const CasesView()),
        GetPage(name: '/case-details', page: () => const CaseDetailsView()),
        GetPage(name: '/products', page: () => const ProductsView()),
        GetPage(name: '/calendar', page: () => const CalendarView()),
        GetPage(name: '/live-map', page: () => const LiveMapView()),
        GetPage(name: '/accounts-map', page: () => const AccountsMapView()),
        GetPage(name: '/main', page: () => const AppNavigator()),
      ],
    );
  }
}
