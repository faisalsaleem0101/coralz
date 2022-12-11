import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/post_view_page.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/notification_rating_page.dart';
import 'package:coralz/screens/setting/payment_link_update_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Broadcast {
  TextEditingController item;
  TextEditingController manufacturer;
  TextEditingController model;
  TextEditingController qty;
  TextEditingController notes;
  Broadcast(this.item, this.manufacturer, this.model, this.qty, this.notes);
}

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({Key? key}) : super(key: key);

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  final double _headerHeight = 220;
  int id = 1;
  List<Broadcast> list = [
    Broadcast(
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController()),
  ];
  bool isLoading = false;
  Future<void> _storeData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List body = [];
    list.forEach((element) {
      body.add({
        "Item": element.item.text,
        "Manufacturer": element.manufacturer.text,
        "Model#": element.model.text,
        "Quantity": element.qty.text,
        "Notes": element.notes.text,
      });
    });

    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint + "api/v1/broadcast"),
          headers: {"Authorization": "Bearer " + token!},
          body: {"data": jsonEncode(body)});

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        if (response['status']) {
          if (mounted) {
            setState(() {
              list = [];
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Successfully Uploaded!',
              contentType: ContentType.success,
            ),
          ));
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
      print(e);
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Broadcast"),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                if (list.length == 0) {
                  return Container();
                }
                return !isLoading
                    ? FractionallySizedBox(
                        alignment: Alignment.topCenter,
                        widthFactor: 0.6,
                        child: Container(
                            margin: EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                _storeData(context);
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
                        child: Center(
                          child: CircularProgressIndicator(
                            color: secondaryColorRGB(1),
                          ),
                        ),
                      );
              }
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Item",
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
                            controller: list[index].item,
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
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Manufacturer",
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
                            controller: list[index].manufacturer,
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
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Model #",
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
                            controller: list[index].model,
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
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quantity",
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
                            controller: list[index].qty,
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
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notes",
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
                            minLines: 3,
                            maxLines: 4,
                            controller: list[index].notes,
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
                    height: 10,
                  ),
                  IconButton(
                      iconSize: 30,
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            list.removeAt(index);
                          });
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        color: primaryColorRGB(1),
                      )),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              );
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mounted) {
            setState(() {
              list.add(Broadcast(
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController()));
            });
          }
        },
        child: Icon(Icons.create_new_folder),
      ),
    );
  }
}
