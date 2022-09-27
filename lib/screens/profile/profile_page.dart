// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/profile/profile_header.dart';
import 'package:coralz/screens/profile/profile_posts_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class User {
  String id;
  String name;
  String email;
  String? mobileNumber;
  String? avatar;
  double? rating;
  int following;
  int followers;

  User(this.id, this.name, this.email, this.mobileNumber, this.avatar,
      this.rating, this.following, this.followers);
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double _headerHeight = 350;

  int indexOfPage = 0;

  changePage(int index) {
    if (indexOfPage != index) {
      if (mounted) {
        setState(() {
          indexOfPage = index;
        });
      }
    }
  }

  bool isUserLoading = true;
  late User user;

  Future<void> _loadUserData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isUserLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse("${api_endpoint}api/v1/auth-user"),
          headers: {"Authorization": "Bearer ${token!}"});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              user = User(
                  response['user']['id'].toString(),
                  response['user']['name'].toString(),
                  response['user']['email'].toString(),
                  response['user']['mobile_number'],
                  response['user']['avatar'],
                  response['user']['rating'] == null
                      ? 0.0
                      : double.parse(response['user']['rating'].toString()),
                  response['user']['following'],
                  response['user']['followers']);
            });
          }
        } else {
          if (mounted) {
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
          }
        }
      } else {
        if (mounted) {
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
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
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
      }
    }

    if (mounted) {
      setState(() {
        isUserLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUserLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColorRGB(1),
              ),
            )
          :  Column(
        children: [
          Container(
            height: _headerHeight,
            child: ProfilePageHeader(user, _headerHeight, true, Icons.person),
          ),
          Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        changePage(0);
                      },
                      child: Text('My Listings'),
                      style: ElevatedButton.styleFrom(
                          onPrimary:
                              indexOfPage == 0 ? Colors.white : Colors.grey,
                          primary: indexOfPage == 0
                              ? primaryColorRGB(1)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        changePage(1);
                      },
                      child: Text('Sold'),
                      style: ElevatedButton.styleFrom(
                          onPrimary:
                              indexOfPage == 1 ? Colors.white : Colors.grey,
                          primary: indexOfPage == 1
                              ? primaryColorRGB(1)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        changePage(2);
                      },
                      child: Text('Saved'),
                      style: ElevatedButton.styleFrom(
                          onPrimary:
                              indexOfPage == 2 ? Colors.white : Colors.grey,
                          primary: indexOfPage == 2
                              ? primaryColorRGB(1)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        changePage(3);
                      },
                      child: Text('Won'),
                      style: ElevatedButton.styleFrom(
                          onPrimary:
                              indexOfPage == 3 ? Colors.white : Colors.grey,
                          primary: indexOfPage == 3
                              ? primaryColorRGB(1)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        changePage(4);
                      },
                      child: Text('Lost'),
                      style: ElevatedButton.styleFrom(
                          onPrimary:
                              indexOfPage == 4 ? Colors.white : Colors.grey,
                          primary: indexOfPage == 4
                              ? primaryColorRGB(1)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          )),
                    ),
                    
                  ],
                ),
              )),
          ProfilePostsPage((indexOfPage+1).toString(), key: Key((indexOfPage+1).toString()),)
        ],
      ),
    );
  }
}
