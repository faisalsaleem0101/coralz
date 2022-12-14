import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/auth/verify_email.dart';
import 'package:coralz/screens/home/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../config/token.dart';
import './auth/login_page.dart';
import './theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  // 0 - all ok (email verified) - home page
  // 1 - all ok (email not verified) - verify email page
  // 2 - try again
  Future<int> _validEmail() async {
    try {
      String? fcmToken = '';
      if (!kIsWeb) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      }
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse(api_endpoint+"api/v1/user?fcm_token=${fcmToken!}"), headers: {
        "Authorization": "Bearer "+token!
      });

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if(response['status']) {

          await updateUser(
            id: response['user']['id'].toString(),
            name: response['user']['name'],
            email: response['user']['email'],
            mobileNumber: response['user']['mobile_number'] ?? '',
            avatar: response['user']['avatar'] ?? '',
            paymentLink: response['user']['payment_link'] ?? '',
          );

          await setContactPrivacy(response['user']['contact_privacy'] == 1 ? true: false);
          

          if(response['user']['email_verified_at'] == null) {
            return 1;
          } else {
            return 0;
          }
        } else {
          return 2;
        }

      } else {
        return 2;
      }
    } catch (e) {
      print(e);
      return 2;
    }


  }

  void gotoNextScreen(BuildContext context) async {
    String? token = await getBearerToken();
    if(token == null) {
      
      Timer( Duration(seconds: 3),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage())));
    } else {

      int result = await _validEmail();
      if(result == 0) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(),), (route) => false);
      } else if(result == 1) {
        Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => VerifyEmailPage()));
      } else {
        Timer( Duration(seconds: 1),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage())));
      }
      
    }
    
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => gotoNextScreen(context));    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColorRGB(1),
      body: Center(
        child: Image.asset("assets/images/loader.gif"),
      ),
    );
  }
}