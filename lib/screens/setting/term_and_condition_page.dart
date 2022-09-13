import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/screens/home/chat/shimmer_loading.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TermAndConditionPage extends StatefulWidget {
  const TermAndConditionPage({Key? key}) : super(key: key);

  @override
  State<TermAndConditionPage> createState() => _TermAndConditionPageState();
}

class _TermAndConditionPageState extends State<TermAndConditionPage> {
  final double _headerHeight = 220;
  bool isLoading = true;
  String data = '';

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
        print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              data = response['data']['terms_and_conditions'].toString();
            });
          }
        } else {
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
        }
      } else {
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
      }
    } catch (e) {
      print(e);
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
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Terms & Conditions"),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColorRGB(1),
                    ),
                  )
                : data.length == 0
                    ? Center(
                        child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/nodata-found.png"),
                                fit: BoxFit.contain)),
                      ))
                    : SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15, bottom: 25),
                          child: Text(
                            data,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
          )
        ],
      ),
    );
  }
}
