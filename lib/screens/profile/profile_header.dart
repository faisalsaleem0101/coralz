// This widget will draw header section of all page. Wich you will get with the project source code.
// ignore_for_file: unnecessary_new, sort_child_properties_last, no_logic_in_create_state, library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/home/calendar_page.dart';
import 'package:coralz/screens/home/show_image_page.dart';
import 'package:coralz/screens/home/user/user_rating.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/profile/followers_following_page.dart';
import 'package:coralz/screens/profile/profile_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePageHeader extends StatefulWidget {
  final double _height;
  final bool _showIcon;
  final IconData _icon;

  final User user;

  const ProfilePageHeader(this.user, this._height, this._showIcon, this._icon,
      {Key? key})
      : super(key: key);

  @override
  _ProfilePageHeaderState createState() =>
      _ProfilePageHeaderState(_height, _showIcon, _icon);
}

class _ProfilePageHeaderState extends State<ProfilePageHeader> {
  double _height;
  bool _showIcon;
  IconData _icon;

  String name = "-";
  String email = "-";
  String mobile_number = "-";
  String? avatar = null;

  _ProfilePageHeaderState(this._height, this._showIcon, this._icon);

  


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
                          child: Row(
                            children: [
                              BackButton(
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                CalendarPage()));
                                  },
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                  ))
                            ],
                          ))),
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
                            Share.share("${share_endpoint}share?user=${widget.user.id}");

                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => EditProfilePage()));
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
                    GestureDetector(
                      onTap: () {
                        showFollowersFollowing(context, '1');
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(79, 73, 75, 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white)),
                        alignment: Alignment.center,
                        child: Text(
                          'Followers\n\n${widget.user.followers}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
                    GestureDetector(
                      onTap: () {
                        showFollowersFollowing(context, '2');
                        
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(79, 73, 75, 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white)),
                        alignment: Alignment.center,
                        child: Text(
                          'Following\n\n${widget.user.following}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
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
              SizedBox(
                height: 20,
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
