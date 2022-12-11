// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/auth/forget_password.dart';
import 'package:coralz/screens/auth/register_page.dart';
import 'package:coralz/screens/auth/verify_email.dart';
import 'package:coralz/screens/home/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/header_widget.dart';
import '../theme/colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _headerHeight = 240;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  String? emailError, passwordError;
  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
    });

    try {
      String? fcmToken = '';
      if (!kIsWeb) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      }
      var result =
          await http.post(Uri.parse(api_endpoint + "api/v1/login"), body: {
        "email": email.text,
        "password": password.text,
        "fcm_token" : fcmToken!
      });

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if (response['status']) {

          await updateUser(
            id: response['user']['id'].toString(),
            name: response['user']['name'],
            email: response['user']['email'],
            mobileNumber: response['user']['mobile_number'] ?? '',
            avatar: response['user']['avatar'] ?? '',
            paymentLink: response['user']['payment_link'] ?? '',
          );
          await setContactPrivacy(response['user']['contact_privacy'] == 1 ? true: false);

          await setBearerToken(response['bearer_token']);
          if (response['user']['email_verified_at'] == null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => VerifyEmailPage()));
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
                (route) => false);
          }
        } else {
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];
            setState(() {
              if (errors.containsKey('email')) {
                emailError = errors['email'][0];
              }
              if (errors.containsKey('password')) {
                passwordError = errors['password'][0];
              }
            });
          } else if (response['errors']['type'] == 2) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message: 'Invalid Credentials!',
                  contentType: ContentType.failure,
                ),
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message: 'Something went wrong!',
                contentType: ContentType.failure,
              ),
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Something went wrong!',
            contentType: ContentType.failure,
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      ));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true, Icons.person),
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Column(
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: email,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.email,
                            color: primaryColorRGB(1),
                          ),
                          labelText: 'Enter Email',
                          errorText: emailError,
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColorRGB(1)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColorRGB(1)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: password,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.password,
                            color: primaryColorRGB(1),
                          ),
                          labelText: 'Enter Password',
                          errorText: passwordError,
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColorRGB(1)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColorRGB(1)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      !isLoading
                          ? TextButton(
                              style: ButtonStyle(
                                  splashFactory: NoSplash.splashFactory),
                              onPressed: () {
                                print("test");
                                _login(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(colors: [
                                      primaryColorRGB(1),
                                      secondaryColorRGB(0.7),
                                    ])),
                                child: Center(
                                  child: Text("Login",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ))
                          : CircularProgressIndicator(
                              color: primaryColorRGB(1),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => RegisterPage()));
                        },
                        child: Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: secondaryColorRGB(1)),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ForgetPasswordPage()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: secondaryColorRGB(1)),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
