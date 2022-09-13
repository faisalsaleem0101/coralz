// This widget will draw header section of all page. Wich you will get with the project source code.
// ignore_for_file: unnecessary_new, sort_child_properties_last, no_logic_in_create_state, library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/chat/chat_page.dart';
import 'package:coralz/screens/home/show_image_page.dart';
import 'package:coralz/screens/home/user/user_rating.dart';
import 'package:coralz/screens/home/user/user_rating_add_edit.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;


import 'User.dart';

class UserProfileHeader extends StatefulWidget {
  final double _height;
  final bool _showIcon;
  final IconData _icon;
  final User user;

  const UserProfileHeader(this._height, this._showIcon, this._icon, this.user,
      {Key? key})
      : super(key: key);

  @override
  _UserProfileHeaderState createState() =>
      _UserProfileHeaderState(_height, _showIcon, _icon);
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  double _height;
  bool _showIcon;
  IconData _icon;

  bool isLoading = false;

  Future<void> updateFollowing(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
// rating
    try {
      String? token = await getBearerToken();
      var result = await http.post(Uri.parse("${api_endpoint}api/v1/user/follow-unfollow/${widget.user.id}"),
          headers: {
            "Authorization": "Bearer " + token!
          });
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              widget.user.isFollowed = !widget.user.isFollowed;
            });
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

  _UserProfileHeaderState(this._height, this._showIcon, this._icon);

  _launchCaller(String number) async {
    String url = "tel:$number";
     
    if (await canLaunchUrlString(url)) {
       await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }   
}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      child: Stack(
        children: [
          ClipPath(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [primaryColorRGB(0.4), secondaryColorRGB(0.7)],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            clipper: new ShapeClipper([
              Offset(width / 5, _height),
              Offset(width / 10 * 5, _height - 60),
              Offset(width / 5 * 4, _height + 20),
              Offset(width, _height - 18)
            ]),
          ),
          ClipPath(
            // ignore: sort_child_properties_last
            child: Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [primaryColorRGB(0.4), secondaryColorRGB(0.4)],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            clipper: new ShapeClipper([
              Offset(width / 3, _height + 20),
              Offset(width / 10 * 8, _height - 60),
              Offset(width / 5 * 4, _height - 60),
              Offset(width, _height - 20)
            ]),
          ),
          ClipPath(
            child: Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [primaryColorRGB(1), secondaryColorRGB(0.6)],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            clipper: new ShapeClipper([
              Offset(width / 5, _height),
              Offset(width / 2, _height - 40),
              Offset(width / 5 * 4, _height - 80),
              Offset(width, _height - 20)
            ]),
          ),
          SafeArea(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerLeft,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Share.share("$api_endpoint/user/${widget.user.id}");
                          },
                        )
                      ],
                    ),
                  ))
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.user.avatar != null
                        ? GestureDetector(
                            onTap: () {
                              displayDialog(api_endpoint + widget.user.avatar!,
                                  context, null);
                            },
                            child: CachedNetworkImage(
                              imageUrl: api_endpoint + widget.user.avatar!,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage: imageProvider,
                                  radius: 48,
                                ),
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      "assets/images/image_loader.gif"),
                                  radius: 48,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      "assets/images/image_not_found.png"),
                                  radius: 48,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/default-profile-picture.jpg"),
                              radius: 48,
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  widget.user.name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  widget.user.email,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  widget.user.mobileNumber ?? '-',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ratingDialog(widget.user.id, context);
                },
                child: Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.rating != null
                              ? widget.user.rating.toString()
                              : '0',
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                        )
                      ],
                    )),
              ),
              Container(
                margin: EdgeInsets.only(top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 21,
                      child: CircleAvatar(
                        backgroundColor: primaryColorRGB(1),
                        radius: 20,
                        child: IconButton(
                            onPressed: () {
                              _launchCaller(widget.user.mobileNumber ?? '0');
                            },
                            icon: Icon(
                              Icons.phone,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 21,
                      child: CircleAvatar(
                        backgroundColor: secondaryColorRGB(1),
                        radius: 20,
                        child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => ChatPage(
                                            widget.user.authUserId,
                                              widget.user.id,
                                              widget.user.name)));
                            },
                            icon: Icon(
                              Icons.message,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading ? CircularProgressIndicator(color: Colors.white,) : ElevatedButton(
                      onPressed: () {
                        updateFollowing(context);
                      },
                      child:
                          Text(widget.user.isFollowed ? 'Unfollow' : 'Follow'),
                      style: ElevatedButton.styleFrom(
                          primary: primaryColorRGB(1),
                          side: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {

                        showGeneralDialog(
                          context: context,
                          barrierDismissible: false,
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return StarRating(widget.user);
                          },
                        ).then((value) {
                          if(mounted) {
                            setState(() {
                              User updateUser = value as User;
                              widget.user.rating = updateUser.rating;
                              widget.user.isRated = updateUser.isRated;
                              widget.user.comment = updateUser.comment;
                            });
                          }
                          print(value);
                        });
                      },
                      child: Text(widget.user.isRated ? 'Edit Rating' : 'Rate this user'),
                      style: ElevatedButton.styleFrom(
                          primary: secondaryColorRGB(1),
                          side: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(top: 5),
              //   child: RatingBar.builder(
              //     initialRating: 3.2,
              //     minRating: 1,
              //     direction: Axis.horizontal,
              //     itemCount: 5,
              //     itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              //     itemBuilder: (context, _) => Icon(
              //       Icons.star,
              //       color: Colors.amber,
              //     ),
              //     onRatingUpdate: (rating) {
              //       print(rating);
              //     },
              //   ),
              // )
            ],
          )),
        ],
      ),
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  List<Offset> _offsets = [];
  ShapeClipper(this._offsets);
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height - 20);

    // path.quadraticBezierTo(size.width/5, size.height, size.width/2, size.height-40);
    // path.quadraticBezierTo(size.width/5*4, size.height-80, size.width, size.height-20);

    path.quadraticBezierTo(
        _offsets[0].dx, _offsets[0].dy, _offsets[1].dx, _offsets[1].dy);
    path.quadraticBezierTo(
        _offsets[2].dx, _offsets[2].dy, _offsets[3].dx, _offsets[3].dy);

    // path.lineTo(size.width, size.height-20);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
