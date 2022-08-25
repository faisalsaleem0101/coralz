import 'dart:convert';
import 'dart:io';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;

class ProfilePasswordUpdatePage extends StatefulWidget {
  const ProfilePasswordUpdatePage({Key? key}) : super(key: key);

  @override
  State<ProfilePasswordUpdatePage> createState() => _ProfilePasswordUpdatePageState();
}

class _ProfilePasswordUpdatePageState extends State<ProfilePasswordUpdatePage> {
  final double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Update Password"),
          ),
          Expanded(child: PasswordUpdateForm())
        ],
      ),
    );
  }
}

class PasswordUpdateForm extends StatefulWidget {
  const PasswordUpdateForm({Key? key}) : super(key: key);

  @override
  State<PasswordUpdateForm> createState() => _PasswordUpdateFormState();
}

class _PasswordUpdateFormState extends State<PasswordUpdateForm> {
  String? user_avatar = null;
  final TextEditingController old_password = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController password_confirmation = TextEditingController();
  String? oldPasswordError, passwordError;
  bool isLoading = false;


  Future<void> _passwordUpdate(BuildContext context) async {
    setState(() {
      isLoading = true;
      oldPasswordError = null;
      passwordError = null;

    });
    
    
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/user/update-password"), body: {
        "old_password" : old_password.text,
        "password" : password.text,
        "password_confirmation" : password_confirmation.text
      } ,
      headers: {"Authorization": "Bearer " + token!}
      );
      

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
                      'Password Updated!',
                  contentType: ContentType.success,
                ),
              )
            );
        } else {
          if(response['errors']['type'] == 1) {


            var errors = response['errors']['errors'];            
            setState(() {  
              if(errors.containsKey('old_password')) {
                oldPasswordError = errors['old_password'][0];
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Old Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 6,
                    shadowColor: Colors.grey.shade500,
                    child: TextFormField(
                      obscureText: true,
                      controller: old_password,
                      decoration: InputDecoration(
                        hintText: '********',
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            oldPasswordError != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      oldPasswordError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Center(),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "New Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 6,
                    shadowColor: Colors.grey.shade500,
                    child: TextFormField(
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        hintText: '********',
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            passwordError != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Center(),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 6,
                    shadowColor: Colors.grey.shade500,
                    child: TextFormField(
                      obscureText: true,
                      controller: password_confirmation,
                      decoration: InputDecoration(
                        hintText: '********',
                        hintStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
           
            !isLoading
                ? FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.6,
                    child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            _passwordUpdate(context);
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                              primary: secondaryColorRGB(1),
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              elevation: 6),
                        )),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: secondaryColorRGB(1),
                    ),
                  ),
          ],
        ));
  }
}
