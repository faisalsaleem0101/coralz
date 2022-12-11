// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/shop/broadcast_page.dart';
import 'package:coralz/screens/home/shop/coralz_shop_page.dart';
import 'package:coralz/screens/home/shop/map_data.dart';
import 'package:coralz/screens/home/shop/suppliers_map_page.dart';
import 'package:coralz/screens/home/shop/wanted_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool isLoading = true;
  var data;

  String? image1,image2,image3, image4;

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      var result = await http.get(Uri.parse(api_endpoint + "api/v1/settings"));
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
            setState(() {
              image1 = response['data']['coralz_shop'];
              image2 = response['data']['suppliers_map'];
              image3 = response['data']['wanted'];
              image4 = response['data']['broadcast'];
            });
          }
        } else {
        }
      } else {
      }
    } catch (e) {
     
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

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
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: isLoading
                  ? ShimmerLoading() : PageData(context, [image1, image2, image3, image4]))
        ],
      ),
    );
  }
}

// return CategoryPage('1', 'Aquariums', key: Key(indexOfPage.toString()));
Widget PageData(BuildContext context, List images) {
  return GridView.count(
    padding: EdgeInsets.all(15),
    crossAxisCount: 2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    children: [
      makeShopOption(context, "Coralz Shop", images[0], 1),
      makeShopOption(context, "Suppliers Map", images[1] ?? null, 2),
      makeShopOption(context, "Wanted", images[2] ?? null, 3),
      makeShopOption(context, "Broadcast", images[3] ?? null, 4),
      // GestureDetector(
      //   onTap: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (builder) => CoralzShopPage()));
      //   },
      //   child: Container(
      //     padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
      //     alignment: Alignment.bottomCenter,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(10),
      //         image: DecorationImage(
      //           image: AssetImage("assets/images/post-default.png"),
      //           fit: BoxFit.cover,
      //         )),
      //     child: Text(
      //       "Coralz Shop",
      //       style: TextStyle(
      //           fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
      // GestureDetector(
      //   onTap: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (builder) => SuppliersMapPage()));
      //   },
      //   child: Container(
      //     padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
      //     alignment: Alignment.bottomCenter,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(10),
      //         image: DecorationImage(
      //           image: AssetImage("assets/images/post-default.png"),
      //           fit: BoxFit.cover,
      //         )),
      //     child: Text(
      //       "Suppliers Map",
      //       style: TextStyle(
      //           fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
      // GestureDetector(
      //   onTap: () {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (builder) => WantedPostsPage('Wanted')));
      //   },
      //   child: Container(
      //     padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
      //     alignment: Alignment.bottomCenter,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(10),
      //         image: DecorationImage(
      //           image: AssetImage("assets/images/post-default.png"),
      //           fit: BoxFit.cover,
      //         )),
      //     child: Text(
      //       "Wanted",
      //       style: TextStyle(
      //           fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // )
    ],
  );
}

Widget makeShopOption(
    BuildContext context, String title, String? image, int order) {
  return GestureDetector(
    onTap: () {
      if (order == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (builder) => CoralzShopPage()));
      } else if (order == 2) {
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => SuppliersMapPage()));
      } else if (order == 3) {
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => WantedPostsPage('Wanted')));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => BroadcastPage()));
      }
    },
    child: image == null
        ? Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage("assets/images/post-default.png"),
                  fit: BoxFit.cover,
                )),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        : CachedNetworkImage(
            imageUrl: api_endpoint + image,
            imageBuilder: (context, imageProvider) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            placeholder: (context, url) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/image_loader.gif"),
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            errorWidget: (context, url, error) => Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/post-default.png"),
                        fit: BoxFit.cover,
                      )),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
  );
}
