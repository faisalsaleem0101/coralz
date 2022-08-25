// This widget will draw header section of all page. Wich you will get with the project source code.
// ignore_for_file: unnecessary_new, sort_child_properties_last, no_logic_in_create_state, library_private_types_in_public_api, prefer_final_fields, unused_field, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:coralz/screens/profile/profile_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';

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
              Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Positioned(
                    left: 0,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Text(
                      'Profile ok',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Positioned(
                    right: 0,
                    child: Container(
                      child: Row(
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
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                  )
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
                          'Followers\n\n10',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/sample.jpg'),
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
                          'Followers\n\n10',
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
                  'Faisal Saleem',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  'faisal@gmail.com',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  '+92301-6745318',
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
