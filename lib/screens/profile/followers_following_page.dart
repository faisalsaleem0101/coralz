import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/posts_view_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

showFollowersFollowing(BuildContext context, String type) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return FollowersFollowingPage(type);
    },
  );
}

class FollowersFollowingPage extends StatefulWidget {
  final String query;
  const FollowersFollowingPage(this.query, {Key? key}) : super(key: key);

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage> {
  final _controller = ScrollController();

  Future<void> onRefresh() async {}

  List data = [];
  bool isLoading = false;
  String? url;

  Future<void> _loadData(BuildContext context) async {
    if (url == null || widget.query.isEmpty) {
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
        // print(response);
        if (response['status']) {
          url = response['users']['next_page_url'];
          if (mounted) {
            setState(() {
              data = response["users"]["data"];
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    url = "${api_endpoint}api/v1/user/followers-following/${widget.query}";
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          _loadData(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            toolbarHeight: 70,
            backgroundColor: Colors.white,
            leading: BackButton(
              color: Colors.black,
            )),
        body: isLoading && data.length == 0
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColorRGB(1),
                ),
              )
            : data.length == 0
                ? Center(
                    child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/nodata-found.png"),
                            fit: BoxFit.contain)),
                  ))
                : RefreshIndicator(
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => UserProfilePage(
                                        data[index]['id'].toString())));
                          },
                          leading: imageHead(data[index]['avatar'] != null
                              ? api_endpoint + data[index]['avatar']
                              : null),
                          title: Text(data[index]['name']),
                          subtitle: Text(data[index]['email']),
                        );
                      },
                    ),
                    onRefresh: onRefresh),
      ),
    );
  }
}

Widget imageHead(String? url) {
  if (url == null) {
    return CircleAvatar(
      backgroundImage: AssetImage('assets/images/default-profile-picture.jpg'),
    );
  }

  return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
            backgroundImage: imageProvider,
          ),
      placeholder: (context, url) => CircleAvatar(
            backgroundImage: AssetImage('assets/images/image_loader.gif'),
          ),
      errorWidget: (context, url, error) => CircleAvatar(
            backgroundImage:
                AssetImage('assets/images/default-profile-picture.jpg'),
          ));
}
