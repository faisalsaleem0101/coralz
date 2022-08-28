// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({Key? key}) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(padding: EdgeInsets.all(0),itemCount: 15,itemBuilder: (context, index) {
      return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey[100]!,
          period: Duration(seconds: 3),
          child: Container(
            height: 60,
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            decoration: ShapeDecoration(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        );
    },);
  }
}