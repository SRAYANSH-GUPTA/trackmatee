import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  // reactive values
  final _isLoggedIn = false.obs;
  final _token = ''.obs;
  final _email = ''.obs;
  final _username = ''.obs;

  final _box = GetStorage();

  // For UI listening (ValueListenableBuilder, etc.)
  static final ValueNotifier<bool> loginState = ValueNotifier<bool>(false);

  // --------------------
  // GETTERS
  // --------------------

  bool get isLoggedIn => _isLoggedIn.value;

  /// REQUIRED: Token getter used in API calls
  String? get token => _token.value.isNotEmpty ? _token.value : null;

  String get email => _email.value;
  String get username => _username.value;

  @override
  void onInit() {
    super.onInit();

    // load stored data
    _isLoggedIn.value = _box.read('isLoggedIn') ?? false;
    _token.value = _box.read('token') ?? '';
    _email.value = _box.read('email') ?? '';
    _username.value = _box.read('username') ?? 'User';

    // update ValueNotifier
    loginState.value = _isLoggedIn.value;

    // keep ValueNotifier synced
    ever(_isLoggedIn, (val) {
      loginState.value = val as bool;
    });
  }

  // --------------------
  // LOGIN
  // --------------------

  /// Call this after successful API response
  Future<void> login({
    required String token,
    required String email,
    required String username,
  }) async {
    _isLoggedIn.value = true;
    _token.value = token;
    _email.value = email;
    _username.value = username;

    await _box.write('isLoggedIn', true);
    await _box.write('token', _token.value);
    await _box.write('email', _email.value);
    await _box.write('username', _username.value);

    // navigation example (optional)
    if (Get.currentRoute != '/home') {
      Get.offAllNamed('/home');
    }
  }

  // --------------------
  // LOGOUT
  // --------------------

  Future<void> logout() async {
    _isLoggedIn.value = false;
    _token.value = '';
    _email.value = '';
    _username.value = '';

    /// DELETE ONLY AUTH KEYS (do NOT wipe all local storage)
    await _box.remove('isLoggedIn');
    await _box.remove('token');
    await _box.remove('email');
    await _box.remove('username');

    Get.offAllNamed('/login');
  }
}

// --------------------
// INITIALIZER
// --------------------

Future<AuthService> initAuthService() async {
  Get.put(AuthService());
  return Get.find<AuthService>();
}
