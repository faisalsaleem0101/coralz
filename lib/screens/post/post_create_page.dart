// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCreatePage extends StatefulWidget {
  final String title;
  final String id;
  final String type;
  const PostCreatePage(this.id, this.title, this.type, {Key? key})
      : super(key: key);

  @override
  State<PostCreatePage> createState() => _PostCreatePageState(id, title, type);
}

class _PostCreatePageState extends State<PostCreatePage> {
  bool isLoading = false;
  List data = [];
  final double _headerHeight = 220;

  final String title;
  final String id;
  final String type;

  _PostCreatePageState(this.id, this.title, this.type);

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint + "api/v1/sub-categories/" + id),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if (response['status']) {
          // responsedata.forEach((k, v) => list.add(Customer(k, v)));
          if (mounted) {
            setState(() {
              data = response["data"];
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
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: BackButton(
                    color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )),
                Expanded(
                  child: Container(
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerRight,
                ))
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: PostForm(id, type))
        ],
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final String id;
  final String type;
  const PostForm(this.id, this.type, {Key? key}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState(id, type);
}

class PostImage {
  XFile image;
  bool showDeleteButton;
  PostImage(this.image, this.showDeleteButton);
}

class _PostFormState extends State<PostForm> {
  List files = [1, 2, 3];
  final ImagePicker _picker = ImagePicker();
  final DateTime initialDate = DateTime.now();
  final String id;
  final String type;
  _PostFormState(this.id, this.type);

  // Params
  DateTime selectedDate = DateTime.now();

  int duration = 1;
  void setDuration(int d) {
    if (mounted) {
      setState(() {
        duration = d;
      });
    }
  }

  ButtonStyle durationActive(int d) {
    if (duration == d) {
      return ElevatedButton.styleFrom(
          primary: primaryColorRGB(1), elevation: 6);
    }

    return ElevatedButton.styleFrom(
        primary: Colors.white, onPrimary: Colors.black, elevation: 6);
  }

  // List<XFile> images = [];
  List<PostImage> images = [];
  Future<void> pickImage() async {
    if (images.length < 3) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          setState(() {
            images.add(PostImage(image, false));
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Warning!',
          message: 'You can only select 3 image!',
          contentType: ContentType.warning,
        ),
      ));
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: initialDate,
        lastDate: DateTime(2050));
    if (selected != null && selected != selectedDate && mounted) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 30),
      child: Column(
        children: [
          GridView.builder(
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              itemCount: images.length + 1,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: ((context, index) {
                if (index != images.length) {
                  return GestureDetector(
                    onTap: () {
                      if (mounted) {
                        if (images[index].showDeleteButton) {
                          setState(() {
                            images.removeAt(index);
                          });
                        } else {
                          setState(() {
                            images[index].showDeleteButton = true;
                          });
                        }
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                image:
                                    Image.file(File(images[index].image.path))
                                        .image,
                                fit: BoxFit.fill)),
                        child: images[index].showDeleteButton
                            ? Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: secondaryColorRGB(0.6)),
                                child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    )
                              )
                            : Container()),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade400)),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              })),
          SizedBox(
            height: 15,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title",
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
                    cursorColor: primaryColorRGB(1),
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
                  "Description",
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
                    cursorColor: primaryColorRGB(1),
                    maxLines: 5,
                    minLines: 4,
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
                  type == '3' ? "Start Price" : "Price",
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
                    cursorColor: primaryColorRGB(1),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.currency_pound,
                        color: primaryColorRGB(1),
                      ),
                      hintText: 'Type..',
                      focusColor: primaryColorRGB(1),
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
                  child: DropdownButtonFormField(
                    onChanged: (value) => {},
      items: <String>['A', 'B', 'C', 'D'].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Container(
        width: 20,
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Text(value,style: TextStyle(color: Colors.red),),
        ),
      ),
    );
  }).toList()
    )
    
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Start Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      pickDate(context);
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      size: 30,
                    )),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 6,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Duration",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            setDuration(1);
                          },
                          child: Text('1 Day'),
                          style: durationActive(1),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            setDuration(3);
                          },
                          child: Text('3 Day'),
                          style: durationActive(3),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            setDuration(5);
                          },
                          child: Text('5 Day'),
                          style: durationActive(5),
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            setDuration(7);
                          },
                          child: Text('7 Day'),
                          style: durationActive(7),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            setDuration(10);
                          },
                          child: Text('10 Day'),
                          style: durationActive(10),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  setDuration(14);
                                },
                                child: Text('14 Day'),
                                style: durationActive(14))),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
              child: ElevatedButton(
                onPressed: () {
                  print(id);
                  print(type);
                },
                child: Text('Post'),
                style: ElevatedButton.styleFrom(
                  primary: primaryColorRGB(1),
                  elevation: 6,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              )),
          SizedBox(
            height: 5,
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                    primary: secondaryColorRGB(1),
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 6),
              )),
        ],
      ),
    );
  }
}
