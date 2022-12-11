import 'dart:convert';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Privacy"),
          ),
          Expanded(child: EditPageForm())
        ],
      ),
    );
  }
}

class EditPageForm extends StatefulWidget {
  const EditPageForm({Key? key}) : super(key: key);

  @override
  State<EditPageForm> createState() => _EditPageFormState();
}

class _EditPageFormState extends State<EditPageForm> {
  
  bool isLoading = false;
  bool contact_privacy = false;




  loadUserData(BuildContext context) async {
    bool? p = await getContactPrivacy();
    if (mounted) {
      setState(() {

        if(p != null) {
          contact_privacy = p;
        }
        
      });
    }
    
  }


  
  Future<void> _updateUserData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    
    
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/user/update-privacy/"), body: {
        "contact_privacy" : contact_privacy ? '1' : '0',
      } ,
      headers: {"Authorization": "Bearer " + token!}
      );
      print(result.statusCode);

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
       
        if(response['status']) {

          await setContactPrivacy(contact_privacy);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message:
                      'Privacy Updated!',
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
      isLoading = false;
    });

  }


  

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => loadUserData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 6,
                    shadowColor: Colors.grey.shade500,
                    child: ListTile(
                      title: Text('Anyone can see your contact number.'),
                      trailing: Switch(
                        value: contact_privacy,
                        onChanged: (value) {
                          setState(() {
                            contact_privacy = value;
                          });
                        },
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
                            _updateUserData(context);
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
