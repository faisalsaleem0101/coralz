import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shop/location_picker_page.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Img;
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';

class SupplierFormPage extends StatefulWidget {
  const SupplierFormPage({Key? key}) : super(key: key);

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final double _headerHeight = 220;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController webAddress = TextEditingController();
  final TextEditingController description = TextEditingController();
  String location = '';
  String latitude = '';
  String longitude = '';

  String? nameError, emailError, phoneError, locationError;

  bool locationLoading = false;

  List<String> data = [
    "Home Users",
    "Online Shops",
    "Local Shops",
    "Wholesale"
  ];
  int type = 0;

  Future<void> _determinePosition(BuildContext context) async {
    Position? pos = await showDialog(
        context: context, builder: (_) => LocationPickerPage());

    if (pos != null) {
      if (mounted) {
        setState(() {
          locationLoading = true;
        });
      }
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.length > 0) {
        Placemark placemark = placemarks.first;
        if (mounted) {
          setState(() {
            latitude = pos.latitude.toString();
            longitude = pos.longitude.toString();
            location =
                "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea} ${placemark.postalCode} ,${placemark.country}";
          });
        }
      }
      if (mounted) {
        setState(() {
          locationLoading = false;
        });
      }
    }
  }

  bool isLoading = false;

  Future<void> _request(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        nameError = null;
        emailError = null;
        phoneError = null;
        locationError = null;
      });
    }

    try {
      String? token = await getBearerToken();
      var result =
          await http.post(Uri.parse(api_endpoint + "api/v1/supplier"), body: {
        'name': name.text,
        'email': email.text,
        'phone': phone.text,
        'address': location,
        'latitude': latitude,
        'longitude': longitude,
        'web_address': webAddress.text,
        'description': description.text,
        'type': (type+1).toString()
      }, headers: {
        "Authorization": "Bearer " + token!
      });

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success!',
                  message: "You will receive email of your request confirmation or rejection!",
                  contentType: ContentType.success,
                ),
              ));

              setState(() {
                name.text = '';
                email.text = '';
                phone.text = '';
                location = '';
                latitude = '';
                longitude = '';
                webAddress.text = '';
                description.text = '';
                type = 0;
                

              });
            }
        } else {
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];
            if (mounted) {
              setState(() {
                if (errors.containsKey('name')) {
                  nameError = errors['name'][0];
                }
                if (errors.containsKey('email')) {
                  emailError = errors['email'][0];
                }
                if (errors.containsKey('phone')) {
                  phoneError = errors['phone'][0];
                }
                if (errors.containsKey('address')) {
                  locationError = errors['address'][0];
                }
              });
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message: "Something went wrong!",
                  contentType: ContentType.failure,
                ),
              ));
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: "Something went wrong!",
              contentType: ContentType.failure,
            ),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
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
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // {
  //           "name": [
  //               "The name field is required."
  //           ],
  //           "email": [
  //               "The email field is required."
  //           ],
  //           "phone": [
  //               "The phone field is required."
  //           ],
  //           "address": [
  //               "The address field is required."
  //           ],
  //           "latitude": [
  //               "The latitude field is required."
  //           ],
  //           "longitude": [
  //               "The longitude field is required."
  //           ],
  //           "type": [
  //               "The type field is required."
  //           ]
  //       }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Supplier Form"),
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
                  emailError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            emailError!,
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
                          "Phone no",
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
                            controller: phone,
                            decoration: InputDecoration(
                              hintText: '92 300121218',
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
                  phoneError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            phoneError!,
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
                          "Website Address",
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
                            controller: webAddress,
                            decoration: InputDecoration(
                              hintText: 'htpp//....',
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
                        Row(
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            locationLoading
                                ? CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Colors.transparent,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: Colors.grey.shade500,
                          child: ListTile(
                            onTap: () {
                              _determinePosition(context);
                            },
                            title: Text(location),
                            trailing: Icon(Icons.location_on),
                          ),
                        ),
                      ],
                    ),
                  ),
                  locationError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            locationError!,
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
                          "Description",
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
                            controller: description,
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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Category",
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
                            child: InputDecorator(
                              decoration: InputDecoration(
                                hintText: 'Select',
                                focusColor: primaryColorRGB(1),
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 15, right: 15),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: data.elementAt(type),
                                  isDense: true,
                                  isExpanded: true,
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        type = data.indexOf(value!);
                                      });
                                    }
                                  },
                                  items: data
                                      .map((e) => DropdownMenuItem(
                                          child: Text(e), value: e))
                                      .toList(),
                                ),
                              ),
                            ))
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
                                  _request(context);
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
