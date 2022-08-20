// ignore_for_file: prefer_const_constructors
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColorRGB(1)),
    ),
  ));
}
