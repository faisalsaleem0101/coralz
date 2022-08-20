// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_interpolation_to_compose_strings
import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/reset_forget_password.dart';
import 'package:coralz/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import '../theme/header_widget.dart';
import '../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class VerifyForgetPasswordPage extends StatefulWidget {
  String? currentEmail;
  VerifyForgetPasswordPage({Key? key, this.currentEmail}) : super(key: key);

  @override
  _VerifyForgetPasswordPageState createState() => _VerifyForgetPasswordPageState(currentEmail);
}

class _VerifyForgetPasswordPageState extends State<VerifyForgetPasswordPage> {
  String? currentEmail;
  double _headerHeight = 240;

  _VerifyForgetPasswordPageState(this.currentEmail);

  // Forms fields 
  final TextEditingController code = TextEditingController();
  String? codeError;
  bool isLoading = false;
  bool emailSending = false;

  Future<void> _verifyEmail(BuildContext context) async {
    setState(() {
      isLoading = true;
      codeError = null;
    });
    
    try {

      String otp = code.text.isNotEmpty ? code.text : 'dummy';
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/forget-password/"+otp));

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);

        if(response['status']) {
          Navigator.push(context, MaterialPageRoute(builder: (builder) => ResetForgetPasswordPage(currentToken: otp,)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message:
                    'Invalid Token!',
                contentType: ContentType.failure,
              ),
            )
          );
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

  Future<void> _sendEmail(BuildContext context) async {
    setState(() {
      emailSending = true;
    });
    
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/forget-password"), body: {
        'email' : currentEmail
      });

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if(response['status']) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message:
                    'Confirmation email has been sent!',
                contentType: ContentType.success,
              ),
            )
          );

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
      emailSending = false;
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
                        'Verification',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline
                        ),
                      ),

                      SizedBox(height: 30,),

                      TextFormField(
                        controller: code,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.numbers, color:  primaryColorRGB(1),),
                          labelText: 'Enter Code',
                          errorText: codeError,
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
                            _verifyEmail(context);
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

                      

                      SizedBox(height: 20,),
                      
                      !emailSending ?
                        TextButton(onPressed: (){_sendEmail(context);}, child: Text("Haven't received confirmation email? Resend", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: secondaryColorRGB(1)),),)
                      :
                        CircularProgressIndicator(
                          color: primaryColorRGB(1),
                        ),

                      SizedBox(height: 20,),

                      TextButton(onPressed: (){Navigator.pop(context);}, child: Text(currentEmail!+" Incorrect email? Edit", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: secondaryColorRGB(1)),),)

                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}