import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getBearerToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<bool> setBearerToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeBearerToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    return true;
  } catch (e) {
    return false;
  }
}