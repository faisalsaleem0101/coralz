import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'User.dart';

// starRatingDialog(String user_id, BuildContext context) {

// }

class StarRating extends StatefulWidget {
  final User user;
  const StarRating(this.user, {Key? key}) : super(key: key);

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  TextEditingController comment = TextEditingController();
  String ratingValue = '3';
  bool isLoading = false;

  Future<void> _rateUser(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
// rating
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse("${api_endpoint}api/v1/rating/"),
          headers: {
            "Authorization": "Bearer " + token!
          },
          body: {
            "to_user_id": widget.user.id,
            "rating": ratingValue,
            "comments": comment.text
          });
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
          widget.user.isRated = true;
          widget.user.comment = comment.text;
          widget.user.rating = double.parse(response['avg_rating'].toString());

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'Saved Successfully!',
                contentType: ContentType.success,
              ),
            ));
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
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    comment.text = widget.user.comment;
    ratingValue = widget.user.rating == 0 ? '3' : widget.user.rating.toString();
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
                onPressed: () => Navigator.pop(context, widget.user),
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, widget.user);
                return true;
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    RatingBar.builder(
                      glow: false,
                      initialRating: double.parse(ratingValue),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        ratingValue = rating.toString();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Comments",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                            shadowColor: Colors.grey.shade500,
                            child: TextFormField(
                              controller: comment,
                              minLines: 5,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'Text...',
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
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
                    !isLoading
                        ? FractionallySizedBox(
                            alignment: Alignment.topCenter,
                            widthFactor: 0.6,
                            child: Container(
                                margin: EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _rateUser(context);
                                  },
                                  child: Text('Save'),
                                  style: ElevatedButton.styleFrom(
                                      primary: secondaryColorRGB(1),
                                      padding: EdgeInsets.all(15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      elevation: 6),
                                )),
                          )
                        : Container(
                            margin: EdgeInsets.only(top: 20),
                            child: CircularProgressIndicator(
                              color: secondaryColorRGB(1),
                            ),
                          ),
                  ],
                ),
              ),
            )));
  }
}
