// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_interpolation_to_compose_strings
import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/verify_email.dart';
import 'package:flutter/material.dart';
import '../theme/header_widget.dart';
import '../theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  double _headerHeight = 240;

  // Forms fields
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController password_confirmation = TextEditingController();
  String? nameError,emailError,passwordError;
  bool isLoading = false;

  Future<void> _register(BuildContext context) async {
    setState(() {
      isLoading = true;
      nameError = null;
      emailError = null;
      passwordError = null;

    });
    
    try {
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/register"), body: {
        "name" : name.text,
        "email" : email.text,
        "password" : password.text,
        "password_confirmation" : password_confirmation.text
      });

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if(response['status']) {
          await setBearerToken(response['bearer_token']);
          Navigator.push(context, MaterialPageRoute(builder: (builder) => VerifyEmailPage()));
        } else {
          if(response['errors']['type'] == 1) {

            var errors = response['errors']['errors'];
            setState(() {  
              if(errors.containsKey('name')) {
                nameError = errors['name'][0];
              }
              if(errors.containsKey('email')) {
                emailError = errors['email'][0];
              }
              if(errors.containsKey('password')) {
                passwordError = errors['password'][0];
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
                        'Sign up',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline
                        ),
                      ),

                      SizedBox(height: 30,),

                      TextFormField(
                        controller: name,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.people, color:  primaryColorRGB(1),),
                          labelText: 'Enter Name',
                          errorText: nameError,
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

                      SizedBox(height: 15,),

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

                      SizedBox(height: 15,),

                      TextFormField(
                        controller: password,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.password ,color:  primaryColorRGB(1),),
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

                      SizedBox(height: 15,),

                      TextFormField(
                        controller: password_confirmation,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.password ,color:  primaryColorRGB(1),),
                          labelText: 'Confirm Password',
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
                            _register(context);
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
                              child: Text("Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        )
                      : 
                        CircularProgressIndicator(
                          color: primaryColorRGB(1),
                        ),

                      

                      SizedBox(height: 20,),
                      
                      TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Already have an account? Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColorRGB(1)),),),

                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}