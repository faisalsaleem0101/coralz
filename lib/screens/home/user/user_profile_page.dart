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

import '../../post/posts_view_page.dart';
import 'User.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String? notification_id;
  const UserProfilePage(this.userId, {this.notification_id,Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final double _headerHeight = 460;
  bool isUserLoading = true;
  late User user;

  Future<void> onRefresh() async {}

  Future<void> _loadUserData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isUserLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse("${api_endpoint}api/v1/user/${widget.userId}?notification_id=${widget.notification_id}"),
          headers: {"Authorization": "Bearer ${token!}"});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              user = User(
                  response['user']['id'].toString(),
                  response['auth_user_id'].toString(),
                  response['user']['name'].toString(),
                  response['user']['email'].toString(),
                  response['user']['mobile_number'],
                  response['user']['avatar'],
                  response['user']['rating'] == null
                      ? 0.0
                      : double.parse(response['user']['rating'].toString()),
                  response['user']['comments'] == null
                      ? ''
                      : response['user']['comments'],
                  response['user']['is_rated'],
                  response['user']['is_followed'],
                  response['user']['contact_privacy'] == 1 ? true : false);
            });
            print(response['user']['contact_privacy'] == 1 ? true : false);
            print(user.id);
            _loadData(context);
          }
        } else {
          if (mounted) {
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
        if (mounted) {
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
    } catch (e) {
      print(e);
      if (mounted) {
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

    if (mounted) {
      setState(() {
        isUserLoading = false;
      });
    }
  }

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
    url = "${api_endpoint}api/v1/user-posts/${widget.userId}";
    data = [];
    _loadData(context);
  }

  @override
  void initState() {
    super.initState();
    url = "${api_endpoint}api/v1/user-posts/${widget.userId}";
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUserLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColorRGB(1),
              ),
            )
          : Column(
              children: [
                Container(
                  height: _headerHeight,
                  child: UserProfileHeader(
                      _headerHeight, true, Icons.person, user),
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
                            : RefreshIndicator(
                              color: primaryColorRGB(1),
                                child: PageData(data, controller),
                                onRefresh: refreshData)),
                isLoading && data.length > 0
                    ? Container(
                        padding: EdgeInsets.all(5),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: primaryColorRGB(1),
                        ),
                      )
                    : Container()
              ],
            ),
    );
  }
  
}
