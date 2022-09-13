// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/image_dialog.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/post/post_create_page.dart';
import 'package:coralz/screens/post/posts_view_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SubCategoryPage extends StatefulWidget {
  final String title;
  final String id;
  final String type;
  const SubCategoryPage(this.id, this.title, this.type, {Key? key})
      : super(key: key);

  @override
  State<SubCategoryPage> createState() =>
      _SubCategoryPageState(id, title, type);
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  bool isLoading = false;
  List data = [];
  final double _headerHeight = 220;

  final String title;
  final String id;
  final String type;

  _SubCategoryPageState(this.id, this.title, this.type);

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  flex: 3,
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
          Expanded(
              child: isLoading
                  ? ShimmerLoading()
                  : PageData(data, id: id, title: title))
        ],
      ),
      floatingActionButton: type != '5'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => PostCreatePage(id, title, type)));
              },
              backgroundColor: primaryColorRGB(1),
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }
}

Widget PageData(List data, {String? id, String? title}) {
  return GridView.builder(
    padding: EdgeInsets.all(15),
    itemCount: data.length + 1,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
    itemBuilder: (BuildContext context, int index) {
      if (index != data.length) {
        return GestureDetector(
            onTap: () async {
              if (data[index]["event_image"] != null) {
                await showDialog(
                    context: context,
                    builder: (_) => ImageDialog(
                        api_endpoint + data[index]["event_image"].toString()));
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => PostsViewPage(
                          data[index]['id'].toString(),
                          data[index]["name"],
                          1)));
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
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
                            image:
                                AssetImage("assets/images/image_not_found.png"),
                            fit: BoxFit.cover,
                          )),
                      child: Text(
                        data[index]["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )));
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) =>
                      PostsViewPage(id ?? '1', title ?? 'All', 0)));
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage("assets/images/post-default.png"),
                fit: BoxFit.cover,
              )),
          child: Text(
            "All",
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    },
  );
}
