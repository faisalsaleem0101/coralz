// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/app_bar.dart';

import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/post/post_view_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Post {
  String id;
  String title;
  String price;
  String? image;
  Post(this.id, this.title, this.price, this.image);
}

class PostsViewPage extends StatefulWidget {
  final String id;
  final String title;
  final int type; // 0 - all, 1 - specific
  const PostsViewPage(this.id, this.title, this.type, {Key? key})
      : super(key: key);

  @override
  State<PostsViewPage> createState() => _PostsViewPageState();
}

class _PostsViewPageState extends State<PostsViewPage> {
  @override
  PostsViewPage get widget => super.widget;


  final double _headerHeight = 220;
  int indexOfPage = 0;

  final controller = ScrollController();
  bool firstPage = true;
  bool isLoading = true;
  String? url;

  List<Post> data = [];
  Future<void> _loadData(BuildContext context) async {
    if (url == null) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http
          .get(Uri.parse(url!), headers: {"Authorization": "Bearer " + token!});

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        if (response['status']) {
          if (firstPage) {
            firstPage = false;
          }
          url = response['posts']['next_page_url'];
          print(response);
          if (mounted) {
            setState(() {
              response['posts']['data'].forEach((k) {
                data.add(Post(k['id'].toString(), k['title'], k['price'].toString(), k['image'] == null ? null : api_endpoint + k['image']['image']));
              });
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

  Future<void> refreshData() async {
    url = widget.type == 0
        ? "${api_endpoint}api/v1/posts?parent_category_id=${widget.id}"
        : "${api_endpoint}api/v1/posts?category_id=${widget.id}";
    data = [];
    _loadData(context);
  }

  @override
  void initState() {
    super.initState();
    url = widget.type == 0
        ? "${api_endpoint}api/v1/posts?parent_category_id=${widget.id}"
        : "${api_endpoint}api/v1/posts?category_id=${widget.id}";
    controller.addListener(() {
      if (controller.position.atEdge) {
        bool isTop = controller.position.pixels == 0;
        if (!isTop) {
          _loadData(context);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
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
        Expanded(
            child: Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
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
                              widget.title,
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
                  child: isLoading && data.length == 0
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
                          : RefreshIndicator(child: PageData(data, controller), onRefresh: refreshData)),
              isLoading && data.length > 0 ? Container(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: primaryColorRGB(1),
                ),
              ) : Container(), 
              
            ],
          ),
        ))
      ],
    ));
  }

}
  Widget PageData(List<Post> data, ScrollController controller) {
    return GridView.builder(
      controller: controller,
      padding: EdgeInsets.all(15),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () async {
              var deleted_post_id = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PostViewPage(data[index].id)));
                  if(deleted_post_id != null) {
                    data.where((element) => element.id == deleted_post_id.toString(),);
                  }
            },
            child: Stack(
              children: [
                image(data[index].image),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 0.2,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          FittedBox(
                            child: Text(
                              data[index].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }

Widget image(String? url) {
  if (url == null) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage('assets/images/post-default.png'),
            fit: BoxFit.cover,
          )),
    );
  }

  return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )),
          ),
      placeholder: (context, url) => Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/images/image_loader.gif'),
                  fit: BoxFit.cover,
                )),
          ),
      errorWidget: (context, url, error) => Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/images/post-default.png'),
                  fit: BoxFit.cover,
                )),
          ));
}
