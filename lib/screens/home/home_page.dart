// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/aquariums_page.dart';
import 'package:coralz/screens/home/profile/profile_page.dart';
import 'package:coralz/screens/home/shop_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import './buyitnow_page.dart';
import './auctions_page.dart';
import './fish_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final double _headerHeight = 220;
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
    } else if(indexOfPage == 1) {
      return BuyItNowPage();
    } else if(indexOfPage == 2) {
      return AuctionsPage();
    } else if(indexOfPage == 3) {
      return FishPage();
    } else if(indexOfPage == 4) {
      return ShopPage();
    }

    return Container(child: Text('under construction'),);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return (
  //     ProfilePage()
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Expanded(child: WidgetPage())
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColorRGB(1),
        gradient: LinearGradient(
          colors: [
            primaryColorRGB(1),
            secondaryColorRGB(1),
          ]
        ),
        items: [
          TabItem(icon: Icons.home, title: 'Aquariums'),
          TabItem(icon: Icons.shop, title: 'Buy It Now'),
          TabItem(icon: Icons.add, title: 'Auctions'),
          TabItem(icon: Icons.message, title: 'Fish'),
          TabItem(icon: Icons.people, title: 'Shop'),
        ],
        initialActiveIndex: 0,//optional, default as 0
        onTap: (int i) {
          setState(() {
            indexOfPage = i;
          });
        },
      ),
    );
  }
}