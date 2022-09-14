// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/shop/coralz_shop_page.dart';
import 'package:coralz/screens/home/shop/suppliers_map_page.dart';
import 'package:coralz/screens/home/shop/wanted_page.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Category {
  String? id;
  String? name;
  String? image;
}

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _AquariumsPageState();
}

class _AquariumsPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Shop',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: PageData(context))
        ],
      ),
    );
  }
}

// return CategoryPage('1', 'Aquariums', key: Key(indexOfPage.toString()));
Widget PageData(BuildContext context) {
  return GridView.count(
    padding: EdgeInsets.all(15),
    crossAxisCount: 2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) => CoralzShopPage()));
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage("assets/images/Equipment.jpg"),
                fit: BoxFit.cover,
              )),
          child: Text(
            "Coralz Shop",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) => SuppliersMapPage()));

        },
        child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage("assets/images/Equipment.jpg"),
              fit: BoxFit.cover,
            )),
        child: Text(
          "Suppliers Map",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) => WantedPostsPage('Wanted')));

        },
        child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage("assets/images/Equipment.jpg"),
              fit: BoxFit.cover,
            )),
        child: Text(
          "Wanted",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      )
      
    ],
  );
}
