import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/chat/chat_page.dart';
import 'package:coralz/screens/home/swap/swap_edit_page.dart';
import 'package:coralz/screens/post/mark_as_sold.dart';
import 'package:coralz/screens/post/post_comments_page.dart';
import 'package:coralz/screens/post/post_edit_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Post {
  String id;
  String user_id;
  String title;
  String description;
  String offered;
  String wanted;
  String? image;
  String post_user_id;
  String user_name;
  String? user_avatar;
  double user_rating = 0;
  String? paymentLink;

  Post(
      this.id,
      this.user_id,
      this.title,
      this.description,
      this.offered,
      this.wanted,
      this.image,
      this.post_user_id,
      this.user_name,
      this.user_avatar,
      this.user_rating,
      this.paymentLink,
      );
}

class Offer {
  String name;
  String email;
  double amount;
  Offer(this.name, this.email, this.amount);
}

class SwapPostViewPage extends StatefulWidget {
  final String id;
  const SwapPostViewPage(this.id, {Key? key}) : super(key: key);

  @override
  State<SwapPostViewPage> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<SwapPostViewPage> {
  bool isLoading = true;
  Post? data;
  List<Offer> offers = [];
  List<String> images = [];
  late String user_id;

  int like_state = 1; // 1-like, 2-wait
  bool deleting = false;
  bool markingAsSold = false;
  bool offerSubmitting = false;

  final TextEditingController amount = TextEditingController();
  String? amountError;

  

  Future<void> delete(BuildContext context) async {
    if (mounted) {
      setState(() {
        deleting = true;
      });
    }
    try {
      String? token = await getBearerToken();
      var result = await http.post(
          Uri.parse("${api_endpoint}api/v1/swap/${widget.id}"),
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
          Uri.parse(api_endpoint + "api/v1/swap/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
            user_id = response['user_id'].toString();

            setState(() {
              data = Post(
                  response['data']['id'].toString(),
                  response['data']['user_id'].toString(),
                  response['data']['title'].toString(),
                  response['data']['description'] ?? '-',
                  response['data']['offered'].toString(),
                  response['data']['wanted'].toString(),
                  response['data']['image'],
                  response['data']['user']['id'].toString(),
                  response['data']['user']['name'].toString(),
                  response['data']['user']['avatar'],
                  response['data']['user_rating'] != null
                      ? double.parse(response['data']['user_rating'].toString())
                      : double.parse('0'),
                  response['data']['user']['payment_link']);
              
              if(response['data']['image'] != null) {
                images.add(response['data']['image'].toString());
              }
            });
          }
        }
      }
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
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Password Updated!',
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
            : Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.share,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {},
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
                                            'Title',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            "${data!.title}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ))),
                                          Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 6,
                                      child: ListTile(
                                          title: Text(
                                            'Wanted',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            "${data!.wanted}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ))),
                                          Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 6,
                                      child: ListTile(
                                          title: Text(
                                            'Offered',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            "${data!.offered}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ))),
                                  
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
                                                  BorderRadius.circular(10)),
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
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  
                                  Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 6,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Text(data!.user_name),
                                            subtitle: RatingBarIndicator(
                                              itemCount: 5,
                                              itemSize: 20,
                                              rating: data!.user_rating,
                                              itemBuilder: (context, index) {
                                                return Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.fromLTRB(
                                                  70, 0, 70, 0),
                                              child: OutlinedButton.icon(
                                                icon: Icon(
                                                  Icons.chat,
                                                  color: Colors.black,
                                                ),
                                                label: Text(
                                                  "Chat",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (builder) =>
                                                              ChatPage(
                                                                data!.user_id,
                                                                data!
                                                                    .post_user_id,
                                                                data!.user_name,
                                                              )));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.all(15),
                                                  side: BorderSide(
                                                      width: 2.0,
                                                      color: Colors.black),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
                                                  ),
                                                ),
                                              )),
                                          
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  user_id == data!.user_id
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
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            SwapEditPage(
                                                                data!.id)));
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                              color:
                                                                  Colors.white))
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
                                                      BorderRadius.circular(20),
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
                                                              color:
                                                                  Colors.white,
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
                                      : Container()
                                ],
                              ),
                            )),
                          ))
                        ],
                      ),
                    ),
                  ),
                ],
              ));
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
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: imageProvider,
                      fit: BoxFit.fitWidth)),
            ),
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
