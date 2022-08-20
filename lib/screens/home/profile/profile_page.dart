// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/aquariums_page.dart';
import 'package:coralz/screens/home/profile/profile_header.dart';
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

  final double _headerHeight = 600;
  int indexOfPage = 0;

  Future<void> logout(BuildContext context) async {
    try {
      String? token = await getBearerToken();
      await http.post(Uri.parse(api_endpoint+"api/v1/logout"), headers: {
        "Authorization": "Bearer "+token!
      });
      await removeBearerToken();
    } catch (e) {

    } finally {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(),), (route) => false);
    }
  }


  Widget WidgetPage( ) {
    if(indexOfPage == 0) {
      return AquariumsPage();
    }

    return Container(child: Text('under construction'),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Container(
            height: 240,
            child: ProfileHeaderWidget(_headerHeight, true, Icons.person),
          ),
          
        ],
      ),
      bottomNavigationBar: CircleNavBar(
        
        activeIcons: [
          Icon(Icons.person, color: primaryColorRGB(1)),
          Icon(Icons.home, color: primaryColorRGB(1)),
          Icon(Icons.favorite, color: primaryColorRGB(1)),
          Icon(Icons.home, color: primaryColorRGB(1)),
          Icon(Icons.favorite, color: primaryColorRGB(1)),
        ],
        inactiveIcons: const [
          Icon(Icons.person, color: Colors.black),
          Icon(Icons.home, color: Colors.black),
          Icon(Icons.favorite, color: Colors.black),
          Icon(Icons.home, color: Colors.black),
          Icon(Icons.favorite, color: Colors.black),
        ],
        color: Colors.white,
        height: 70,
        circleWidth: 60,
        initIndex: 0,
        onChanged: (v) {
          setState(() {
            indexOfPage = v;
          });
        },
        shadowColor: Colors.grey.shade500,
        elevation: 20,
      ),
    );
  }
}