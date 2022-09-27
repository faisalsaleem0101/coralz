import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/post_view_page.dart';
import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/notification_rating_page.dart';
import 'package:coralz/screens/setting/payment_link_update_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final double _headerHeight = 220;
  var outputFormat = DateFormat('hh:mm a MM/dd/yyyy');
  final controller = ScrollController();
  bool isLoading = false;
  String? url;
  List data = [];
  Future<void> _loadData(BuildContext context) async {
    if (url == null) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http
          .get(Uri.parse(url!), headers: {"Authorization": "Bearer " + token!});

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        if (response['status']) {
          url = response['data']['next_page_url'];
          print(response);
          if (mounted) {
            setState(() {
              data = response['data']['data'];
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

  Future<void> refreshData() async {
    url = "${api_endpoint}api/v1/notifications";
    data = [];
    _loadData(context);
  }

  @override
  void initState() {
    super.initState();
    url = "${api_endpoint}api/v1/notifications";
    controller.addListener(() {
      if (controller.position.atEdge) {
        bool isTop = controller.position.pixels == 0;
        if (!isTop) {
          _loadData(context);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Notifications"),
          ),
          Expanded(
              child: isLoading && data.length == 0
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
                      : RefreshIndicator(
                          color: primaryColorRGB(1),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                tileColor: data[index]['seen'] == 1 ? Colors.white :Colors.grey[200],
                                onTap: () {
                                  if(mounted) {
                                    setState(() {
                                      data[index]['seen'] = 1;
                                    });
                                  }
                                  int type = data[index]['type'];
                                  if(type == 1) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PostViewPage(data[index]['post_id'].toString(), notification_id: data[index]['id'].toString())));
                                  } else if(type == 2) {
                                    Navigator.push(context, MaterialPageRoute(builder: (builder) => UserProfilePage(data[index]['from_user_id'].toString(), notification_id: data[index]['id'].toString(),)));
                                  } else if(type == 4) {
                                    Navigator.push(context, MaterialPageRoute(builder: (builder) => FeedbackRatingPage(data[index]['id'].toString(),)));

                                  }

                                },
                                title: Text(data[index]['body']),
                                subtitle: Text(outputFormat.format(DateTime.parse(data[index]['created_at']).toLocal())),
                                trailing: Icon(Icons.navigate_next_rounded),
                              );
                            },
                          ),
                          onRefresh: refreshData))
        ],
      ),
    );
  }
}
