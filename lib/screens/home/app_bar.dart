// This widget will draw header section of all page. Wich you will get with the project source code.
// ignore_for_file: unnecessary_new, sort_child_properties_last, no_logic_in_create_state, library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:coralz/config/app.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/home/chat/chats_page.dart';
import 'package:coralz/screens/home/search_page.dart';
import 'package:coralz/screens/home/socket_page.dart';
import 'package:coralz/screens/profile/profile_page.dart';
import 'package:coralz/screens/setting/setting_page.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppBarWidget extends StatefulWidget {
  final double _height;
  final bool _showIcon;
  final IconData _icon;

  const AppBarWidget(this._height, this._showIcon, this._icon, {Key? key})
      : super(key: key);

  @override
  _AppBarWidgetState createState() =>
      _AppBarWidgetState(_height, _showIcon, _icon);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  double _height;
  bool _showIcon;
  IconData _icon;

  String? avatar;

  _AppBarWidgetState(this._height, this._showIcon, this._icon);

  loadUserData(BuildContext context) async {

    String? t = await getAvatar();
    if (mounted && t != null) {
      setState(() {
        avatar = t.isEmpty ? null : t;
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
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => ProfilePage()));
                  },
                  child: avatar != null
                      ? CachedNetworkImage(
                          imageUrl: api_endpoint + avatar!,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 18,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage("assets/images/image_loader.gif"),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage("assets/images/image_not_found.png"),
                          ),
                        )
                      : CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(
                              "assets/images/default-profile-picture.jpg"),
                        ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => ChatsPage()));
                    },
                    icon: Icon(
                      Icons.chat,
                      color: Colors.white,
                    )),
                Image.asset('assets/images/logo.png',
                    width: 150, fit: BoxFit.cover),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => SettingPage()));
                    },
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      searchDialog(context);
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              ],
            ),
          )
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
