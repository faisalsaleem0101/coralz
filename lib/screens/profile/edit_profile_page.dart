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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Edit Profile"),
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
      setState(() {
        user_avatar = userMap['avatar'];
      });
    }
  }

  Future<void> _updateUserData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        nameError = null;
        mobileNumberError = null;
      });
    }

    try {
      String? token = await getBearerToken();

      var request = http.MultipartRequest("POST",Uri.parse(api_endpoint + "api/v1/user"));
      request.headers['Authorization'] = "Bearer " + token!;
      if(avatar != null) {
        request.files.add(http.MultipartFile.fromBytes('avatar', File(avatar!.path).readAsBytesSync(), filename: avatar!.path));
      }
      request.fields['name'] = name.text;
      request.fields['mobile_number'] = mobile_number.text;

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      
      if (response.statusCode == 200) {
        var result = String.fromCharCodes(responseData);
        var response = jsonDecode(result);
        if (response['status']) {
          Map<String, dynamic> userMap = {
            'id': response['user']['id'],
            'name': response['user']['name'],
            'email': response['user']['email'],
            'avatar': response['user']['avatar'],
            'mobile_number': response['user']['mobile_number'],
          };
          await setUserData(userMap);
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
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];

            if (mounted) {
              setState(() {
                if (errors.containsKey('name')) {
                  nameError = errors['name'][0];
                }
                if (errors.containsKey('mobile_number')) {
                  mobileNumberError = errors['mobile_number'][0];
                }
              });
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
            GestureDetector(
              onTap: () {
                pickImage();
              },
              child: CircleAvatar(
                  radius: 60,
                  backgroundColor: primaryColorRGB(1),
                  child: Stack(children: [
                    avatar != null
                        ? Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 59,
                                backgroundImage:
                                    Image.file(File(avatar!.path)).image),
                          )
                        : user_avatar != null
                            ? CachedNetworkImage(
                                imageUrl: api_endpoint + user_avatar!,
                                imageBuilder: (context, imageProvider) => Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 59,
                                      backgroundImage: imageProvider),
                                ),
                                placeholder: (context, url) => Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 59,
                                      backgroundImage: AssetImage(
                                          "assets/images/image_loader.gif")),
                                ),
                                errorWidget: (context, url, error) => Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 59,
                                      backgroundImage: AssetImage(
                                          "assets/images/image_not_found.png")),
                                ),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 59,
                                    backgroundImage: AssetImage(
                                        "assets/images/default-profile-picture.jpg")),
                              ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColorRGB(1),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: Icon(
                            Icons.add,
                            color: primaryColorRGB(1),
                          ),
                        ),
                      ),
                    ),
                  ])),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name",
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
            nameError != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      nameError!,
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
                    "Email",
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
                      controller: email,
                      decoration: InputDecoration(
                        enabled: false,
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
                    "Mobile Number",
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
                      controller: mobile_number,
                      decoration: InputDecoration(
                        hintText: '92 301-2154789',
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
            mobileNumberError != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      mobileNumberError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Center(),
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
