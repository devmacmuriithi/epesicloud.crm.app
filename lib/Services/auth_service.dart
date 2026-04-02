import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'lookups_service.dart';

class AuthService extends GetxService {
  final ApiService _api = Get.put(ApiService());
  final _storage = GetStorage();

  var currentUser = Rxn<UserModel>();
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final token = _storage.read('access_token');
    final userData = _storage.read('user_data');
    if (token != null && userData != null) {
      currentUser.value = UserModel.fromJson(userData);
      isLoggedIn.value = true;
      Get.find<LookupsService>().fetchAllLookups();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final responseBody = await _api.post(
        ApiConstants.baseUrl,
        ApiConstants.login,
        {
          'email': email,
          'password': password,
        },
      );

      final data = json.decode(responseBody);
      final token = data['token'];
      final userJson = data['user'];

      if (token != null) {
        await _storage.write('access_token', token);
        await _storage.write('user_data', userJson);
        
        currentUser.value = UserModel.fromJson(userJson);
        isLoggedIn.value = true;
        Get.find<LookupsService>().fetchAllLookups();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.remove('access_token');
    await _storage.remove('user_data');
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
