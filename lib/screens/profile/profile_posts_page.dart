// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';

import 'package:coralz/screens/home/user/user_profile_header.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../post/posts_view_page.dart';

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
                data.add(Post(
                    k['id'].toString(),
                    k['title'],
                    k['price'].toString(),
                    k['image'] == null
                        ? null
                        : api_endpoint + k['image']['image']));
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
    url = "${api_endpoint}api/v1/profile-posts/${widget.id}";
    data = [];
    _loadData(context);
  }

  @override
  void initState() {
    super.initState();
    url = "${api_endpoint}api/v1/profile-posts/${widget.id}";
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