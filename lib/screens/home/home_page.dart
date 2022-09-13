// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/bottom_bar_icons_icons.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:coralz/screens/home/shop_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:permission_handler/permission_handler.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final double _headerHeight = 220;
  int indexOfPage = 2;

  Widget WidgetPage(int indexOfPage) {
    if (indexOfPage == 0) {
      return CategoryPage('1', 'Aquariums', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 1) {
      return CategoryPage('2', 'Buy It Now', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 2) {
      return CategoryPage('3', 'Auctions', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 3) {
      return CategoryPage('4', 'Fish', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 4) {
      return ShopPage();
    }

    return Container(
      child: Text('under construction'),
    );
  }

  getPermission() async {
    await [
      Permission.storage,
      Permission.camera,
    ].request();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPermission();
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Expanded(child: WidgetPage(indexOfPage))
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColorRGB(1),
        color: bottomBarColor(),

        items: [
          TabItem(
              icon: Icon(
                BottomBarIcons.aquariums,
                color: indexOfPage == 0 ? primaryColorRGB(1) : bottomBarColor(),
              ),
              title: 'Aquariums'),
          TabItem(
              icon: Icon(BottomBarIcons.buy_it_now,
                  color:
                      indexOfPage == 1 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Buy It Now'),
          TabItem(
              icon: Icon(BottomBarIcons.auction,
                  color:
                      indexOfPage == 2 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Auctions'),
          TabItem(
              icon: Icon(BottomBarIcons.fish,
                  color:
                      indexOfPage == 3 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Fish'),
          TabItem(
            icon: Icon(BottomBarIcons.shop,
                color:
                    indexOfPage == 4 ? primaryColorRGB(1) : bottomBarColor()),
            title: 'Shop',
          ),
        ],
        initialActiveIndex: 2, //optional, default as 0
        onTap: (int i) {
          setState(() {
            indexOfPage = i;
          });
        },
      ),
    );
  }
}
