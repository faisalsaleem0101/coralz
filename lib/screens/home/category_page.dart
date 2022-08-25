// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/sub_category_page.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryPage extends StatefulWidget {
  final String title;
  final String id;
  const CategoryPage(this.id, this.title, {Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState(id, title);
}

class _CategoryPageState extends State<CategoryPage> {
  bool isLoading = false;
  List data = [];

  final String title;
  final String id;

  _CategoryPageState(this.id, this.title);

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint + "api/v1/categories/"+id),
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
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          FittedBox(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
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
                          width: 100,
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
      String id = data[index]["id"].toString();
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (builder) => SubCategoryPage(id,name)));
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
                        image: AssetImage("assets/images/image_not_found.png"),
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
                )),
      );
    },
  );
}
