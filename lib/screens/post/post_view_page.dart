import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/chat/chat_page.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/mark_as_sold.dart';
import 'package:coralz/screens/post/post_comments_page.dart';
import 'package:coralz/screens/post/post_edit_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Post {
  String id;
  String user_id;
  String title;
  String description;
  String price;
  String delivery_price;
  String country;
  String delivery;
  String collection;
  String start_date;
  String end_date;
  String type;
  int views = 0;
  int likes = 0;
  int comments = 0;
  bool isLike = false;
  String post_user_id;
  String user_name;
  String? user_avatar;
  double user_rating = 0;
  String? paymentLink;
  int isSold = 0;
  bool expire;
  bool isWanted = false;
  bool isStart;
  String buy_it_now_price;
  Post(
      this.id,
      this.user_id,
      this.title,
      this.description,
      this.price,
      this.delivery_price,
      this.country,
      this.delivery,
      this.collection,
      this.start_date,
      this.end_date,
      this.type,
      this.views,
      this.likes,
      this.comments,
      this.isLike,
      this.post_user_id,
      this.user_name,
      this.user_avatar,
      this.user_rating,
      this.paymentLink,
      this.isSold,
      this.expire,
      this.isWanted,
      this.isStart,
      this.buy_it_now_price);
}

class Offer {
  String name;
  String email;
  double amount;
  Offer(this.name, this.email, this.amount);
}

class PostViewPage extends StatefulWidget {
  final String id;
  final String? notification_id;
  const PostViewPage(this.id, {this.notification_id, Key? key})
      : super(key: key);

  @override
  State<PostViewPage> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  bool isLoading = true;
  Post? data;
  List<Offer> offers = [];
  List<String> images = [];
  late String user_id;

  var bought_by = null;

  int like_state = 1; // 1-like, 2-wait
  bool deleting = false;
  bool markingAsSold = false;
  bool offerSubmitting = false;

  final TextEditingController amount = TextEditingController();
  String? amountError;

  Future<void> likeUnlike(BuildContext context) async {
    if (mounted) {
      setState(() {
        like_state = 2;
      });
    }
    try {
      String? token = await getBearerToken();
      var result = await http.post(
          Uri.parse("${api_endpoint}api/v1/post-like/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              data!.isLike = !data!.isLike;
              if (data!.isLike) {
                data!.likes++;
              } else {
                data!.likes--;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'Saved Successfully!',
                contentType: ContentType.success,
              ),
            ));
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
        like_state = 1;
      });
    }
  }

  Future<void> delete(BuildContext context) async {
    if (mounted) {
      setState(() {
        deleting = true;
      });
    }
    try {
      String? token = await getBearerToken();
      var result = await http.post(
          Uri.parse("${api_endpoint}api/v1/delete-post/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Successfully Deleted!',
              contentType: ContentType.success,
            ),
          ));
          Navigator.pop(context, widget.id);
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
        deleting = false;
      });
    }
  }

  Future<void> markAsSold(BuildContext context, String? id) async {
    if (mounted) {
      setState(() {
        markingAsSold = true;
      });
    }
    try {
      String? token = await getBearerToken();
      var result = await http.post(
          Uri.parse("${api_endpoint}api/v1/mark-as-sold-post/${widget.id}"),
          body: {
            "buyer_user_id": id,
          },
          headers: {
            "Authorization": "Bearer " + token!
          });
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        // print(response);
        if (response['status']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Successfully Sold!',
              contentType: ContentType.success,
            ),
          ));
          data!.isSold = 1;
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
        markingAsSold = false;
      });
    }
  }

  Future<void> _loadData(BuildContext context) async {
    print("Start");
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint +
              "api/v1/post/${widget.id}?notification_id=${widget.notification_id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
            user_id = response['user_id'].toString();
            if (response['data']['images'] != null) {
              response['data']['images'].forEach((k) {
                images.add(k['image'].toString());
              });
            }

            setState(() {
              data = Post(
                  response['data']['id'].toString(),
                  response['data']['user_id'].toString(),
                  response['data']['title'].toString(),
                  response['data']['description'].toString(),
                  response['data']['price'].toString(),
                  response['data']['delivery_price'].toString(),
                  response['data']['country'].toString(),
                  response['data']['delivery'].toString(),
                  response['data']['collection'].toString(),
                  response['data']['start_date'].toString(),
                  response['data']['end_date'].toString(),
                  response['data']['type'].toString(),
                  response['data']['post_views'],
                  response['data']['post_likes'],
                  response['data']['post_comments'],
                  response['data']['is_like'],
                  response['data']['user']['id'].toString(),
                  response['data']['user']['name'].toString(),
                  response['data']['user']['avatar'],
                  response['data']['user_rating'] != null
                      ? double.parse(response['data']['user_rating'].toString())
                      : double.parse('0'),
                  response['data']['user']['payment_link'],
                  response['data']['is_sold'],
                  response['data']['expire'],
                  response['data']['is_wanted'],
                  response['data']['is_start'],
                  response['data']['buy_it_now_price'].toString());

              if (response['data']['offers'] != null) {
                response['data']['offers'].forEach((el) {
                  offers.add(Offer(el['name'], el['email'],
                      double.parse(el['amount'].toString())));
                });
              }

              bought_by = response['data']['bought_by'];
            });
          }
        }
      } else {}
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitOffer(BuildContext context) async {
    setState(() {
      offerSubmitting = true;
      amountError = null;
    });

    try {
      String? token = await getBearerToken();
      var result =
          await http.post(Uri.parse(api_endpoint + "api/v1/post-offer"), body: {
        "post_id": widget.id,
        "amount": amount.text,
      }, headers: {
        "Authorization": "Bearer " + token!
      });

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        if (response['status']) {
          if (mounted) {
            amount.text = '';
            setState(() {
              offers = [];
              if (response['offers'] != null) {
                response['offers'].forEach((el) {
                  offers.add(Offer(el['name'], el['email'],
                      double.parse(el['amount'].toString())));
                });
              }
              if(response['is_sold']) {
                bought_by = response['bought_by'];
                data!.expire = true;
              }

            });
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Offer successfully submited!',
              contentType: ContentType.success,
            ),
          ));
        } else {
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];
            setState(() {
              if (errors.containsKey('amount')) {
                amountError = errors['amount'][0];
              }
            });
          } else {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      ));
    }

    setState(() {
      offerSubmitting = false;
    });
  }

  String getFormattedEndDate(String endDate) {
    DateTime dateTime = DateTime.parse(endDate);
    dateTime = dateTime.add(dateTime.timeZoneOffset);

    return DateFormat().format(dateTime);
  }

  Duration getDurationOfEndDate(String endDate) {
    DateTime dateTime = DateTime.parse(endDate);
    dateTime = dateTime.add(dateTime.timeZoneOffset);

    return Duration(
        microseconds: dateTime.difference(DateTime.now()).inMicroseconds);
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: primaryColorRGB(1),
                ),
              )
            : data != null
                ? Column(
                    children: [
                      Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              displayImagesDialog();
                            },
                            child: Stack(
                              children: [
                                postViewContainer(images.length > 0
                                    ? api_endpoint + images[0]
                                    : null),
                                SafeArea(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Container(
                                      alignment: Alignment.topLeft,
                                      child: BackButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 12),
                                        alignment: Alignment.topCenter,
                                        child: FittedBox(
                                          child: Text(
                                            data!.title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.share,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              Share.share(
                                                  "${share_endpoint}share?post=${widget.id}");
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              like_state == 1
                                                  ? (data!.isLike
                                                      ? Icons.favorite
                                                      : Icons
                                                          .favorite_border_outlined)
                                                  : Icons.watch_later,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              if (like_state == 1) {
                                                likeUnlike(context);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                  ],
                                )),
                              ],
                            ),
                          )),
                      Expanded(
                        flex: 7,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                  child: Container(
                                child: SingleChildScrollView(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 15, bottom: 35),
                                  child: Column(
                                    children: [
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 6,
                                          child: ListTile(
                                              title: Text(
                                                data!.title,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: data!.type == '1'
                                                  ? (data!.expire
                                                      ? const Text('Expired')
                                                      : (data!.isStart
                                                          ? SlideCountdownSeparated(
                                                              duration:
                                                                  getDurationOfEndDate(
                                                                      data!
                                                                          .end_date),
                                                            )
                                                          : Text(
                                                              'Start Time ${getFormattedEndDate(data!.start_date)}')))
                                                  : Text(data!.expire
                                                      ? 'Expired'
                                                      : 'End Time ${getFormattedEndDate(data!.end_date)}'),
                                              trailing: Text(
                                                "??" + "${data!.price}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))),
                                      data!.type == '1'
                                          ? Column(
                                              children: [
                                                Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    elevation: 6,
                                                    child: ListTile(
                                                        title: Text(
                                                          'Start Price',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        trailing: Text(
                                                          "??" +
                                                              "${data!.price}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ))),
                                                // Card(
                                                //     shape:
                                                //         RoundedRectangleBorder(
                                                //             borderRadius:
                                                //                 BorderRadius
                                                //                     .circular(
                                                //                         10)),
                                                //     elevation: 6,
                                                //     child: ListTile(
                                                //         title: Text(
                                                //           'Buy It Now Price',
                                                //           style: TextStyle(
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .bold),
                                                //         ),
                                                //         trailing: Text(
                                                //           "??" +
                                                //               "${data!.buy_it_now_price}",
                                                //           style: TextStyle(
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .bold),
                                                //         ))),
                                              ],
                                            )
                                          : Container(),
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 6,
                                          child: ListTile(
                                              title: Text(
                                                'Delivery Price',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Text(
                                                "??" + "${data!.delivery_price}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))),
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 6,
                                          child: ListTile(
                                              title: Text(
                                                'Delivery',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Icon(
                                                data!.delivery == '1'
                                                    ? Icons.check_box
                                                    : Icons
                                                        .check_box_outline_blank_outlined,
                                                color: primaryColorRGB(1),
                                              ))),
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 6,
                                          child: ListTile(
                                              title: Text(
                                                'Collection',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Icon(
                                                data!.collection == '1'
                                                    ? Icons.check_box
                                                    : Icons
                                                        .check_box_outline_blank_outlined,
                                                color: primaryColorRGB(1),
                                              ))),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      data!.type == '1' && data!.isStart
                                          ? Column(
                                              children: [
                                                data!.expire
                                                    ? Text('Post Expired')
                                                    : Column(
                                                        children: [
                                                          Text(
                                                            'Offer',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18),
                                                          ),
                                                          Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                            elevation: 6,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  amount,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText: '??',
                                                                hintStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                errorBorder:
                                                                    InputBorder
                                                                        .none,
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left:
                                                                            15,
                                                                        bottom:
                                                                            11,
                                                                        top: 11,
                                                                        right:
                                                                            15),
                                                              ),
                                                            ),
                                                          ),
                                                          amountError != null
                                                              ? Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    amountError!,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                )
                                                              : Center(),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          offerSubmitting
                                                              ? CircularProgressIndicator(
                                                                  color:
                                                                      secondaryColorRGB(
                                                                          1),
                                                                )
                                                              : Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          70,
                                                                          0,
                                                                          70,
                                                                          0),
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      if (user_id ==
                                                                          data!
                                                                              .user_id) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(SnackBar(
                                                                          elevation:
                                                                              0,
                                                                          behavior:
                                                                              SnackBarBehavior.floating,
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          content:
                                                                              AwesomeSnackbarContent(
                                                                            title:
                                                                                'Info!',
                                                                            message:
                                                                                "You can't submit offer on this is post!",
                                                                            contentType:
                                                                                ContentType.help,
                                                                          ),
                                                                        ));
                                                                      } else {
                                                                        _submitOffer(
                                                                            context);
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                        'Submit'),
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            secondaryColorRGB(
                                                                                1),
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                                15),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                32.0)),
                                                                        elevation:
                                                                            6),
                                                                  )),
                                                        ],
                                                      ),
                                                ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: offers.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      title: Text(
                                                          offers[index].name),
                                                      trailing: Text(
                                                          "??${offers[index].amount}"),
                                                    );
                                                  },
                                                )
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Description",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              elevation: 6,
                                              shadowColor: Colors.grey.shade500,
                                              child: TextFormField(
                                                initialValue: data!.description,
                                                maxLines: 15,
                                                minLines: 4,
                                                decoration: InputDecoration(
                                                  enabled: false,
                                                  hintText: "No Description",
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 15,
                                                          bottom: 11,
                                                          top: 11,
                                                          right: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 6,
                                          child: ListTile(
                                              title: Text(
                                                'Country',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: Text(
                                                "${data!.country}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ))),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      GridView(
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 10,
                                            bottom: 10),
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10),
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 6,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.remove_red_eye),
                                                    Text('${data!.views} views')
                                                  ]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 6,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.favorite),
                                                    Text('${data!.likes} Likes')
                                                  ]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          PostCommentPage(
                                                              widget.id)));
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 6,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.comment),
                                                    Text(
                                                        '${data!.comments} comments')
                                                  ]),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      user_id != data!.user_id
                                          ? Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              elevation: 6,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (builder) =>
                                                                  UserProfilePage(
                                                                      data!
                                                                          .post_user_id)));
                                                    },
                                                    title:
                                                        Text(data!.user_name),
                                                    subtitle:
                                                        RatingBarIndicator(
                                                      itemCount: 5,
                                                      itemSize: 20,
                                                      rating: data!.user_rating,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              70, 0, 70, 0),
                                                      child:
                                                          OutlinedButton.icon(
                                                        icon: Icon(
                                                          Icons.chat,
                                                          color: Colors.black,
                                                        ),
                                                        label: Text(
                                                          "Chat",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (builder) =>
                                                                          ChatPage(
                                                                            data!.user_id,
                                                                            data!.post_user_id,
                                                                            data!.user_name,
                                                                          )));
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          side: BorderSide(
                                                              width: 2.0,
                                                              color:
                                                                  Colors.black),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        32.0),
                                                          ),
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 0, 20, 0),
                                                      child:
                                                          ElevatedButton.icon(
                                                        icon:
                                                            Icon(Icons.payment),
                                                        label: Text(
                                                          "Payment Link",
                                                        ),
                                                        onPressed: () async {
                                                          if(data!.paymentLink == null || data!.paymentLink!.isEmpty) {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                elevation: 0,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                content:
                                                                    AwesomeSnackbarContent(
                                                                  title:
                                                                      'Info!',
                                                                  message:
                                                                      'Please contact the seller direct!',
                                                                  contentType:
                                                                      ContentType
                                                                          .warning,
                                                                ),
                                                              ));
                                                            }

                                                            return;

                                                          }
                                                          String url = data!
                                                              .paymentLink!;
                                                          var uri;
                                                          if (url.contains(
                                                              "https")) {
                                                            uri =
                                                                Uri.parse(url);
                                                          } else {
                                                            uri = Uri(
                                                                scheme: 'https',
                                                                path: url);
                                                          }

                                                          if (await canLaunchUrl(
                                                              uri)) {
                                                            await launchUrl(
                                                                uri);
                                                          } else {
                                                            if (mounted) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                elevation: 0,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                content:
                                                                    AwesomeSnackbarContent(
                                                                  title:
                                                                      'Info!',
                                                                  message:
                                                                      'Payment link is not valid!',
                                                                  contentType:
                                                                      ContentType
                                                                          .warning,
                                                                ),
                                                              ));
                                                            }
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: Colors.black,
                                                          onPrimary:
                                                              Colors.white,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          side: BorderSide(
                                                              width: 2.0,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                ],
                                              ))
                                          : Container(),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      user_id == data!.user_id &&
                                              data!.isSold != 1
                                          ? GridView(
                                              padding: EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 10,
                                                  bottom: 10),
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      crossAxisSpacing: 10,
                                                      mainAxisSpacing: 10),
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (data!.isWanted) {
                                                      return;
                                                    }
                                                    var selected_id =
                                                        await showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                MarkAsSold());
                                                    if (selected_id != null) {
                                                      markAsSold(
                                                          context, selected_id);
                                                    }
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.green,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                          spreadRadius: 1,
                                                          blurRadius: 6,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: markingAsSold
                                                        ? Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white),
                                                          )
                                                        : Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                Icon(
                                                                  Icons
                                                                      .done_all_outlined,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(
                                                                    data!.isWanted
                                                                        ? '-'
                                                                        : 'Mark as sold',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white))
                                                              ]),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (builder) =>
                                                                PostEditPage(
                                                                    data!.id)));
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.blue,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                          spreadRadius: 1,
                                                          blurRadius: 6,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                          ),
                                                          Text('Edit',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))
                                                        ]),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    delete(context);
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.red,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.4),
                                                          spreadRadius: 1,
                                                          blurRadius: 6,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                    ),
                                                    child: deleting
                                                        ? Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white),
                                                          )
                                                        : Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              ]),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      bought_by != null
                                          ? Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              elevation: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    child: Text(
                                                      data!.type != '1'
                                                          ? 'Bought By: '
                                                          : 'Won By: ',
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (builder) =>
                                                                  UserProfilePage(
                                                                      bought_by[
                                                                              'id']
                                                                          .toString())));
                                                    },
                                                    title:
                                                        Text(bought_by['name']),
                                                    subtitle: Text(
                                                        bought_by['email']),
                                                    trailing: Icon(
                                                        Icons.navigate_next),
                                                  ),
                                                ],
                                              ))
                                          : Container(),
                                    ],
                                  ),
                                )),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/nodata-found.png"),
                            fit: BoxFit.contain)),
                  )));
  }

  displayImagesDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              ),
              Expanded(
                  child: PageView.builder(
                      itemCount: images.length,
                      pageSnapping: true,
                      itemBuilder: (context, pagePosition) {
                        return CachedNetworkImage(
                          imageUrl: api_endpoint + images[pagePosition],
                          imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: imageProvider))),
                          placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage(
                                          "assets/images/image_loader.gif")))),
                          errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage(
                                          "assets/images/image_not_found.png")))),
                        );
                      }))
            ],
          ),
        ));
      },
    );
  }

  Widget postViewContainer(String? image) {
    if (image == null) {
      return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage('assets/images/post-default.png'),
                  fit: BoxFit.fitWidth)));
    }

    return CachedNetworkImage(
        imageUrl: image,
        imageBuilder: (context, imageProvider) => Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: imageProvider,
                  fit: BoxFit.fitWidth),
            ),
            child: images.length > 0
                ? Container(
                    alignment: Alignment.bottomLeft,
                    margin: EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.white,
                        ),
                        images.length > 1
                            ? Icon(Icons.circle_outlined, color: Colors.white)
                            : Icon(Icons.circle_outlined,
                                color: Colors.transparent),
                        images.length > 2
                            ? Icon(Icons.circle_outlined, color: Colors.white)
                            : Icon(Icons.circle_outlined,
                                color: Colors.transparent)
                      ],
                    ),
                  )
                : Container()),
        placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage('assets/images/post-default.png'),
                      fit: BoxFit.fitWidth)),
            ),
        errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage('assets/images/post-default.png'),
                      fit: BoxFit.fitWidth)),
            ));
  }
}
