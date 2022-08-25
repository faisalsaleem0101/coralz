// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/aquariums_page.dart';
import 'package:coralz/screens/profile/profile_header.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double _headerHeight = 380;
  int indexOfPage = 0;

  Future<void> logout(BuildContext context) async {
    try {
      String? token = await getBearerToken();
      await http.post(Uri.parse(api_endpoint + "api/v1/logout"),
          headers: {"Authorization": "Bearer " + token!});
      await removeBearerToken();
    } catch (e) {
    } finally {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: ProfilePageHeader(_headerHeight, true, Icons.person),
          ),
          Container(
            padding: EdgeInsets.only(right: 10, left: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  offset: Offset(2, 4), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('My Listings'),
                  style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      primary: primaryColorRGB(1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)))),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Sold'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero))),
                ),
                
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Won'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero))),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Lost'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      )),
                ),
                
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
