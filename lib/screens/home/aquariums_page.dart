// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:ui';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/sub_category_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AquariumsPage extends StatefulWidget {
  const AquariumsPage({Key? key}) : super(key: key);

  @override
  State<AquariumsPage> createState() => _AquariumsPageState();
}

class _AquariumsPageState extends State<AquariumsPage> {
  bool isLoading = false;
  List data = [];

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint + "api/v1/categories/1"),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }
  // @override
  // Widget build(BuildContext context) {
  //   return
  //     Container(
  //       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
  //       height: double.infinity,
  //       width: double.infinity,
  //       child: Column(
  //         children: [
  //           Stack(
  //             alignment: AlignmentDirectional.centerStart,
  //             children: [
  //               Container(
  //                 child: IconButton(
  //                   icon: Icon(Icons.arrow_back),
  //                   onPressed: (){},
  //                 ),
  //               ),
  //               Container(
  //                 width: double.infinity,
  //                 child: Text(
  //                   'Zoas',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 26,
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),

  //           SizedBox(height: 20,),
  //           Expanded(
  //             child: PostForm()
  //           )
  //         ],
  //       ),
  //     );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Aquariums',
            style: TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: isLoading
                  ? ShimmerLoading()
                  : data.length == 0
                      ? Center(
                          child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/nodata-found.png"),
                                  fit: BoxFit.contain)),
                        ))
                      : PageData(data))
        ],
      ),
    );
  }
}

Widget PageData(List data) {
  return GridView.builder(
    padding: EdgeInsets.all(15),
    itemCount: data.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
    itemBuilder: (BuildContext context, int index) {
      String name = data[index]["name"];
      return GestureDetector(
        onTap: (){
          // Navigator.push(context, MaterialPageRoute(builder: (builder) => SubCategoryPage('1',name)));
        },
        child: CachedNetworkImage(
            imageUrl: api_endpoint + data[index]["image"],
            imageBuilder: (context, imageProvider) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    data[index]["name"],
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            placeholder: (context, url) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/image_loader.gif"),
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    data[index]["name"],
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            errorWidget: (context, url, error) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/image_not_found.png"),
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    data[index]["name"],
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
      );
    },
  );
}

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  List files = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          GridView.count(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                        image: AssetImage('assets/images/Equipment.jpg'),
                        fit: BoxFit.fill)),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey.shade400)),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
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
                  "Price",
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
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.currency_pound),
                      hintText: 'Type...',
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
                  "Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 6,
                  child: TextFormField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      suffixIcon: Icon(Icons.location_searching),
                      hintText: 'Select',
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
                          onPressed: () {},
                          child: Text('1 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: primaryColorRGB(1), elevation: 6),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Text('3 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 6),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Text('5 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 6),
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Text('7 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 6),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Text('10 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 6),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Text('14 Day'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 6),
                        )),
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
                onPressed: () {},
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
                onPressed: () {},
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
