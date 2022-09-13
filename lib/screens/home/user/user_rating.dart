import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

ratingDialog(String id, BuildContext context) {
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
      return RatingPage(id);
    },
  );
}

class RatingPage extends StatefulWidget {
  final String id;
  const RatingPage(this.id, {Key? key}) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final _controller = ScrollController();

  Future<void> onRefresh() async {
    _loadData(context);
  }

  List data = [];
  bool isLoading = false;

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse("${api_endpoint}api/v1/ratings/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }


  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          // TODO : Add infinite scroll
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
        ),
      ),
      body: Container(
          child: isLoading && data.length == 0
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
                              image:
                                  AssetImage("assets/images/nodata-found.png"),
                              fit: BoxFit.contain)),
                    ))
                  :RefreshIndicator(
              child: ListView.builder(
                controller: _controller,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: RatingBarIndicator(
                      itemCount: 5,
                      itemSize: 20,
                      rating: double.parse(data[index]['rating'] != null ? data[index]['rating'].toString() : '0'),
                      itemBuilder: (context, index) {
                        return Icon(
                        Icons.star,
                        color: Colors.amber,
                      );
                      },
                    ),
                    subtitle: Text(data[index]['comments'] ?? '-'),
                  );
                },
              ),
              onRefresh: onRefresh)),
    ));
  }
}




