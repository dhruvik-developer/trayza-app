import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  late SharedPreferences _prefs;
  final _isLoggedIn = false.obs;
  final _token = RxnString();
  final _username = RxnString();
  final _userType = RxnString();

  bool get isLoggedIn => _isLoggedIn.value;
  String? get token => _token.value;
  String? get username => _username.value;
  String? get userType => _userType.value;

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token.value = _prefs.getString('token');
    _username.value = _prefs.getString('username');
    _userType.value = _prefs.getString('userType');
    
    if (_token.value != null) {
      _isLoggedIn.value = true;
    }
    return this;
  }

  void login(String token, String username, String userType) {
    _token.value = token;
    _username.value = username;
    _userType.value = userType;
    _isLoggedIn.value = true;
    
    _prefs.setString('token', token);
    _prefs.setString('username', username);
    _prefs.setString('userType', userType);
  }

  void logout() {
    _token.value = null;
    _username.value = null;
    _userType.value = null;
    _isLoggedIn.value = false;
    
    _prefs.remove('token');
    _prefs.remove('username');
    _prefs.remove('userType');
    
    Get.offAllNamed('/login');
  }
}
