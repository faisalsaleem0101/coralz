// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/aquariums_page.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:coralz/screens/profile/profile_page.dart';
import 'package:coralz/screens/home/shop_page.dart';
import 'package:coralz/screens/post/post_view_page.dart';
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

  


  Widget WidgetPage( ) {
    if(indexOfPage == 0) {
      return CategoryPage('1', 'Aquariums', key: Key(indexOfPage.toString()));
    } else if(indexOfPage == 1) {
      return CategoryPage('2', 'Buy It Now', key: Key(indexOfPage.toString()));
    } else if(indexOfPage == 2) {
      return CategoryPage('3', 'Auctions', key: Key(indexOfPage.toString()));
    } else if(indexOfPage == 3) {
      return CategoryPage('4', 'Fish', key: Key(indexOfPage.toString()));
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
    // return PostViewPage();
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