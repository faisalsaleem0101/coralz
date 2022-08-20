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
    return 
    GridView.builder(
      padding: EdgeInsets.all(15),
      itemCount: 10,  
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(  
          crossAxisCount: 2,  
          crossAxisSpacing: 15,  
          mainAxisSpacing: 15  
      ),  
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey[100]!,
          period: Duration(seconds: 3),
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.grey[400]!,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        );
      },  
    );
  }
}