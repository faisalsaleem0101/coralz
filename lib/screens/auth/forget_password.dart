// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_interpolation_to_compose_strings
import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/verify_forget_password.dart';
import 'package:coralz/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import '../theme/header_widget.dart';
import '../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  double _headerHeight = 240;

  // Forms fields 
  final TextEditingController email = TextEditingController();
  String? emailError;
  bool isLoading = false;

  Future<void> _forgetPassword(BuildContext context) async {
    setState(() {
      isLoading = true;
      emailError = null;
    });
    
    try {
      
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/forget-password"), body: {
        'email' : email.text
      });

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if(response['status']) {
          Navigator.push(context, MaterialPageRoute(builder: (builder) => VerifyForgetPasswordPage(currentEmail: email.text,)));
        } else {

          if(response['errors']['type'] == 1) {

            var errors = response['errors']['errors'];
            setState(() {  
              
              if(errors.containsKey('email')) {
                emailError = errors['email'][0];
              }
            });

          } else {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message:
                      'Something went wrong!',
                  contentType: ContentType.failure,
                ),
              )
            );

          }

        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message:
                  'Something went wrong!',
              contentType: ContentType.failure,
            ),
          )
        );
      }

      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message:
                e.toString(),
            contentType: ContentType.failure,
          ),
        )
      );
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
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline
                        ),
                      ),

                      SizedBox(height: 30,),

                      TextFormField(
                        controller: email,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.email, color:  primaryColorRGB(1),),
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

                      SizedBox(height: 30,),

                      !isLoading
                      ?
                        TextButton(
                          style: ButtonStyle(
                            splashFactory: NoSplash.splashFactory
                          ),
                          onPressed: (){
                            _forgetPassword(context);
                          }, 
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  primaryColorRGB(1),
                                  secondaryColorRGB(0.7),
                                ]
                              )
                            ),
                            child: Center(
                              child: Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        )
                      : 
                        CircularProgressIndicator(
                          color: primaryColorRGB(1),
                        ),

                    

                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}