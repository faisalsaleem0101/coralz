// ignore_for_file: prefer_const_constructors

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/aquariums_page.dart';
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

class PostsViewPage extends StatefulWidget {
  const PostsViewPage({Key? key}) : super(key: key);

  @override
  State<PostsViewPage> createState() => _PostsViewPageState();
}

class _PostsViewPageState extends State<PostsViewPage> {
  final double _headerHeight = 220;
  int indexOfPage = 0;

  List data = [
    {'name': 'Test', 'image': 'images/categories/demo.jpg'},
    {'name': 'Test', 'image': 'images/categories/demo.jpg'},
    {'name': 'Test', 'image': 'images/categories/demo.jpg'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('object');
                        Navigator.pop(context);
                      },
                      child: Container(
                       
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                          ),
                          onPressed: () {
                            print('object 2');
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Zoas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(child: PageData(data))
              ],
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColorRGB(1),
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget PageData(List data) {
  return GridView.builder(
    padding: EdgeInsets.all(15),
    itemCount: data.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15),
    itemBuilder: (BuildContext context, int index) {
      return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => PostsViewPage()));
          },
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(api_endpoint + data[index]["image"]),
                      fit: BoxFit.cover,
                    )),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.5,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Regular',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Regular',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '#20',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ));
    },
  );
}
