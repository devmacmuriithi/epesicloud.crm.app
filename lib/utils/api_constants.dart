class ApiConstants {
  static const String baseUrl = 'https://crmepesicloudcom-production.up.railway.app';
  
  // Auth endpoints
  static const String login = '/api/agent-auth/login';
  static const String register = '/api/auth/register';
  static const String initialize = '/api/auth/initialize';
  
  // CRM endpoints
  static const String leads = '/api/leads';
  static const String accounts = '/api/accounts';
  static const String contacts = '/api/contacts';
  static const String deals = '/api/deals';
  static const String activities = '/api/activities';
  static const String tasks = '/api/tasks';
  static const String cases = '/api/cases';
  static const String payments = '/api/payments';
  static const String products = '/api/products';
  static const String projects = '/api/projects';
  static const String lookups = '/api/lookups';
}
