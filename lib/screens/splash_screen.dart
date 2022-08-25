import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/screens/auth/verify_email.dart';
import 'package:coralz/screens/home/home_page.dart';
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
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse(api_endpoint+"api/v1/user"), headers: {
        "Authorization": "Bearer "+token!
      });

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if(response['status']) {

          

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