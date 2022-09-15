// ignore_for_file: prefer_const_constructors
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(MaterialApp(
    title: 'Coralz',
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    theme: ThemeData(
      primaryColor: primaryColorRGB(1),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryColorRGB(1)),
    ),
  ));
}
