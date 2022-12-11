// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/swap/swap_view_page.dart';

import 'package:coralz/screens/home/user/user_profile_header.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../post/posts_view_page.dart';

class SwapSingle {
  String id;
  String title;
  String? image;
  SwapSingle(this.id, this.title, this.image);
}

class ProfilePostsPage extends StatefulWidget {
  final String id;
  const ProfilePostsPage(this.id, {Key? key}) : super(key: key);

  @override
  State<ProfilePostsPage> createState() => _ProfilePostsPageState();
}

class _ProfilePostsPageState extends State<ProfilePostsPage> {
  
  final controller = ScrollController();
  bool firstPage = true;
  bool isLoading = true;
  String? url;

  List<Post> data = [];
  List<SwapSingle> data_swap = [];

  Future<void> _loadData(BuildContext context) async {
    print(url);
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
              if(widget.id == '6') {

                response['posts']['data'].forEach((k) {
                  data_swap.add(SwapSingle(k['id'].toString(), k['title'], k['image'] == null ? null : api_endpoint + k['image']));
                });
              } else {
                response['posts']['data'].forEach((k) {
                  data.add(Post(
                      k['id'].toString(),
                      k['title'],
                      k['price'].toString(),
                      k['image'] == null
                          ? null
                          : api_endpoint + k['image']['image']));
                });
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

  Future<void> refreshData() async {
    if(widget.id == '6') {
      url = "${api_endpoint}api/v1/swaps-users";
    } else {
      url = "${api_endpoint}api/v1/profile-posts/${widget.id}";
    }
    data = [];
    data_swap = [];
    _loadData(context);
  }

  @override
  void initState() {
    super.initState();

    if(widget.id == '6') {
      url = "${api_endpoint}api/v1/swaps-users";
    } else {
      url = "${api_endpoint}api/v1/profile-posts/${widget.id}";
    }
    
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
    if(widget.id == '6') {
      return Expanded(
                    child: isLoading && data_swap.length == 0
                        ? ShimmerLoading()
                        : data_swap.length == 0
                            ? Center(
                                child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "assets/images/nodata-found.png"),
                                        fit: BoxFit.contain)),
                              ))
                            : RefreshIndicator(
                              color: primaryColorRGB(1),
                                child:PageDataOfSwap(data_swap, controller),
                                onRefresh: refreshData));
    }
    
    return Expanded(
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
                            : RefreshIndicator(
                              color: primaryColorRGB(1),
                                child: PageData(data, controller),
                                onRefresh: refreshData));
  }
}

Widget PageDataOfSwap(List<SwapSingle> data, ScrollController controller) {
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
                  builder: (BuildContext context) => SwapPostViewPage(data[index].id)));
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