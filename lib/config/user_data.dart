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

// -- New Data

Future<bool> setUserId(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', t);
    return true;
  } catch (e) {
    return false;
  }
}


Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id');
}

Future<bool> setUserName(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', t);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_name');
}

Future<bool> setMobileNumber(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_number', t);
    return true;
  } catch (e) {
    return false;
  }
}
Future<String?> getMobileNumber() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('mobile_number');
}


Future<bool> setEmail(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', t);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

Future<bool> setAvatar(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', t);
    return true;
  } catch (e) {
    return false;
  }
}
Future<String?> getAvatar() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('avatar');
}

Future<bool> setPaymentLink(String t) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_link', t);
    return true;
  } catch (e) {
    return false;
  }
}
Future<String?> getPaymentLink() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('payment_link');
}
Future<bool> updateUser({required String id, required String name, required String mobileNumber, required String avatar, required String email, required String paymentLink}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('mobile_number', mobileNumber);
    await prefs.setString('avatar', avatar);
    await prefs.setString('email', email);
    await prefs.setString('payment_link', paymentLink);
    return true;
  } catch (e) {
    return false;
  }
}