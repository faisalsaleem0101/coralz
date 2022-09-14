// ignore_for_file: prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:flutter/material.dart';


class SuppliersMapPage extends StatefulWidget {
  const SuppliersMapPage({Key? key}) : super(key: key);

  @override
  State<SuppliersMapPage> createState() => _SuppliersMapPageState();
}

class _SuppliersMapPageState extends State<SuppliersMapPage> {
  final double _headerHeight = 220;
  int indexOfPage = 2;

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Something went wrong!',
            contentType: ContentType.failure,
          ),
        ));
    });
    super.didChangeDependencies();
  }


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
          Expanded(child:Container())
        ],
      ),
    );
  }
}
