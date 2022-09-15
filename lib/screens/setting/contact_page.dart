import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Img;
import 'package:http_parser/http_parser.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final double _headerHeight = 220;
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController comments = TextEditingController();
  XFile? attach_image;

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    if (mounted && image != null) {
      setState(() {
        attach_image = image;
      });
    }
  }

  displayDialog(File file, BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          attach_image = null;
                        });
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                ],
              ),
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: Image.file(file).image))))
            ],
          ),
        ));
      },
    );
  }

  bool isLoading = false;

  Future<void> _contact(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();

      var request = http.MultipartRequest(
          "POST", Uri.parse(api_endpoint + "api/v1/contact"));
      request.headers['Authorization'] = "Bearer " + token!;
      if (attach_image != null) {
        // // resized Image
        // Img.Image? image_temp =
        //     Img.decodeImage(File(attach_image!.path).readAsBytesSync());
        // if (image_temp == null) {
        //   return;
        // }
        // Img.Image resized_img = Img.copyResize(image_temp, width: 300);
        // // End

        // request.files.add(http.MultipartFile.fromBytes(
        //     'attach_image', Img.encodeJpg(resized_img),
        //     filename: 'resized_image.jpg',
        //     contentType: MediaType.parse('image/jpeg')));

        request.files.add(http.MultipartFile.fromBytes(
            'attach_image', File(attach_image!.path).readAsBytesSync(),
            filename: attach_image!.path));
      }
      request.fields['name'] = name.text;
      request.fields['email'] = email.text;
      request.fields['comments'] = comments.text;

      var response = await request.send();
      var responseData = await response.stream.toBytes();

      if (response.statusCode == 200) {
        var result = String.fromCharCodes(responseData);
        var response = jsonDecode(result);
        if (response['status']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'Saved!',
                contentType: ContentType.success,
              ),
            ));
          }
        } else {
          if (mounted)
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
      } else {
        if (mounted)
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
      if (mounted)
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

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Contact The Coralz Team"),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 25),
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                            controller: name,
                            decoration: InputDecoration(
                              hintText: 'John Doe',
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
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                            controller: email,
                            decoration: InputDecoration(
                              hintText: 'info@gmail.com',
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
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Comments",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                            controller: comments,
                            minLines: 5,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Text...',
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
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      attach_image != null
                          ? GestureDetector(
                              onTap: () {
                                displayDialog(
                                    File(attach_image!.path), context);
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image:
                                            Image.file(File(attach_image!.path))
                                                .image,
                                        fit: BoxFit.fill)),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                pickImage();
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                        color: Colors.grey.shade400)),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                    ],
                  ),
                  !isLoading
                      ? FractionallySizedBox(
                          alignment: Alignment.topCenter,
                          widthFactor: 0.6,
                          child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  _contact(context);
                                },
                                child: Text('Submit'),
                                style: ElevatedButton.styleFrom(
                                    primary: secondaryColorRGB(1),
                                    padding: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
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
              ),
            ),
          ))
        ],
      ),
    );
  }
}
