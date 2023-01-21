import 'dart:convert';

import 'package:project_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;

  factory Preferences() => Preferences._internal();

  Preferences._internal();

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  String get token => _preferences!.getString('token') ?? "";

  set token(String value) {
    _preferences!.setString('token', value);
  }

  User? get user {
    String userStr = _preferences!.getString('user') ?? "";
    if (userStr.isNotEmpty) {
      User user = userFromJson(userStr);
      return user;
    } else {
      return null;
    }
  }

  set user(User? value) {
    _preferences!.setString('user', json.encode(value));
  }

  clearPreferences() async {
    await _preferences!.clear();
  }
}
