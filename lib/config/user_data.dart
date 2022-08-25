import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String,dynamic>?> getUserData() async {
  final prefs = await SharedPreferences.getInstance();

  String? userPref = prefs.getString('user');
  Map<String,dynamic> userMap = jsonDecode(userPref!) as Map<String, dynamic>;
  return userMap;
}

Future<bool> setUserData(Map<String, dynamic> user) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user', jsonEncode(user));
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    return true;
  } catch (e) {
    return false;
  }
}