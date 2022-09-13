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

class PaymentLinkUpdatePage extends StatefulWidget {
  const PaymentLinkUpdatePage({Key? key}) : super(key: key);

  @override
  State<PaymentLinkUpdatePage> createState() => _PaymentLinkUpdatePageState();
}

class _PaymentLinkUpdatePageState extends State<PaymentLinkUpdatePage> {
  final double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Payment Link"),
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
  String? user_avatar = null;
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile_number = TextEditingController();
  String? mobileNumberError, nameError;
  bool isLoading = false;
  final TextEditingController payment_link = TextEditingController();


  XFile? avatar;
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));
    
    if (mounted && image != null) {
      setState(() {
        avatar = image;
      });
    }
  }

  loadUserData(BuildContext context) async {
    Map<String, dynamic>? userMap = await getUserData();

    if (mounted && userMap != null) {
      name.text = userMap['name'];
      mobile_number.text = userMap['mobile_number'];
      email.text = userMap['email'];
      payment_link.text = userMap['payment_link'];
      setState(() {
        user_avatar = userMap['avatar'];
      });
    }
  }


  
  Future<void> _updateUserData(BuildContext context) async {
    setState(() {
      isLoading = true;

    });
    
    
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint+"api/v1/user/update-payment-link"), body: {
        "payment_link" : payment_link.text,
      } ,
      headers: {"Authorization": "Bearer " + token!}
      );
      

      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
       
        if(response['status']) {
          Map<String, dynamic> userMap = {
            'id': response['user']['id'],
            'name': response['user']['name'],
            'email': response['user']['email'],
            'avatar': response['user']['avatar'],
            'mobile_number': response['user']['mobile_number'],
            'payment_link' : response['user']['payment_link'],
          };
          await setUserData(userMap);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message:
                      'Link Updated!',
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
                  Text(
                    "Link",
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
                      maxLines: 5,
                      minLines: 4,
                      controller: payment_link,
                      decoration: InputDecoration(
                        hintText: 'Enter paypal link or any other sort of link through which you want to receive payments.',
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
