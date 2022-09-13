// ignore_for_file: prefer_const_constructors

import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:flutter/material.dart';


class CoralzShopPage extends StatefulWidget {
  const CoralzShopPage({Key? key}) : super(key: key);

  @override
  State<CoralzShopPage> createState() => _CoralzShopPageState();
}

class _CoralzShopPageState extends State<CoralzShopPage> {
  final double _headerHeight = 220;
  int indexOfPage = 2;


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
          Expanded(child:CategoryPage('5', 'Coralz Shop'))
        ],
      ),
    );
  }
}
