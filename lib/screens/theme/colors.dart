import 'package:flutter/material.dart';

String primaryColor = "#E30F0F";
String secondaryColor = "#000000";

Color primaryColorRGB(double intensity) {
  return Color.fromRGBO(227, 15, 15, intensity);
}

Color secondaryColorRGB(double intensity) {
  return Color.fromRGBO(0, 0, 0, intensity);
}

Color bottomBarColor() {
  // return Colors.grey.shade300;
  return Color.fromRGBO(214, 214, 214, 1);
}