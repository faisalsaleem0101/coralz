// This widget will draw header section of all page. Wich you will get with the project source code.
// ignore_for_file: unnecessary_new, sort_child_properties_last, no_logic_in_create_state, library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:coralz/config/app.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/home/show_image_page.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/profile/profile_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePageHeader extends StatefulWidget {
  final double _height;
  final bool _showIcon;
  final IconData _icon;

  const ProfilePageHeader(this._height, this._showIcon, this._icon, {Key? key})
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

  loadUserData(BuildContext context) async {
    Map<String, dynamic>? userMap = await getUserData();

    if (mounted && userMap != null) {
      setState(() {
        name = userMap['name'];
        mobile_number = userMap['mobile_number'];
        email = userMap['email'];
        avatar = userMap['avatar'];
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => loadUserData(context));
    super.didChangeDependencies();
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
                          onPressed: () {},
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ProfilePage()));
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
                          'Followers\n\n0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    avatar != null
                        ? GestureDetector(
                          onTap: (){
                            displayDialog(api_endpoint + avatar!, context);
                          },
                            child: CachedNetworkImage(
                              imageUrl: api_endpoint + avatar!,
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ProfilePage()));
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
                          'Followers\n\n0',
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
                  name,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  email,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  mobile_number,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
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
                            onPressed: () {},
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
                            onPressed: () {},
                            icon: Icon(
                              Icons.message,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              )
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
