import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/posts_view_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart';

class PostCommentPage extends StatefulWidget {
  final String id;
  const PostCommentPage(this.id, {Key? key}) : super(key: key);

  @override
  State<PostCommentPage> createState() => _PostCommentPageState();
}

class Comment {
  String id;
  String comment;
  String? avatar;
  String name;
  String createdAt;
  bool sent = true;
  Comment(this.id, this.comment, this.avatar, this.name, this.createdAt, this.sent);
}
class User {
  String? avatar;
  String name;
  User(this.avatar, this.name);
}

class _PostCommentPageState extends State<PostCommentPage> {
  late Socket socket;

  final _controller = ScrollController();
  TextEditingController comment = TextEditingController();

  Future<void> onRefresh() async {}

  List data = [];
  bool isLoading = true;
  bool firstPage = true;
  String? url;
  User? user; 

  void makeConnection() {
    try {
      socket = io(chat_endpoint, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();

      // Handle socket events
      socket.on('connect', (_) {
        print('connect: ${socket.id}');
      });
      socket.on('comment', handleMessageReceive);
    } catch (e) {
      print(e);
    }
  }

  void handleMessageReceive(var comment) {
    var json_data = jsonDecode(comment);
    print(json_data);
    try {
      if (json_data['comment']['post_id'].toString() == widget.id) {
        if (mounted) {
          setState(() {
          comments.insert(0,Comment(json_data['comment']['id'].toString(), json_data['comment']['comment'], json_data['user']['avatar'], json_data['user']['name'], formatDate(json_data['comment']['created_at']), false));
          });
        }
      }
    } catch (e) {
      print('Chat event ${e.toString()}');
    }
  }

  Future<void> _sendTextMessage(BuildContext context) async {
    if (comment.text.isEmpty) {
      return;
    }

    var user_message = comment.text;
    comment.text = '';
    String u_id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (mounted) {
        setState(() {
          comments.insert(0,Comment(u_id, user_message, user?.avatar, user!.name, formatDate(DateTime.now().toString()), false));
        });
      }

      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint + "api/v1/comment"),
          body: {'post_id': widget.id, 'comment': user_message},
          headers: {"Authorization": "Bearer " + token!});

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          Comment message;
          for (var i = 0; i < comments.length; i++) {
            if (comments[i].id == u_id) {
              message = comments[i];
              message.sent = true;
              setState(() {});
              break;
            }
          }

          if (socket != null) {
            socket.emit('comment', jsonEncode(response));
          }

          // set sent true

          return; // termintate furthor code
        } else {}
      }
    } catch (e) {
      print(e);
    }
  }

String formatDate(var dateTime) {
  var dateToCheck = DateTime.parse(dateTime);
  dateToCheck = dateToCheck.toLocal();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final aDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
  if (aDate == today) {
    return DateFormat("h:mm a").format(dateToCheck);
  } else if (aDate == yesterday) {
    return "Yesterday";
  } else {
    return "${dateToCheck.day}/${dateToCheck.month}/${dateToCheck.year}";
  }

  return "";
}
  List<Comment> comments = [];
  Future<void> _loadData(BuildContext context) async {
    if (url == null) {
      return;
    }

    if (mounted && firstPage) {
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
          if (firstPage) {
            firstPage = false;
          }
          if(user == null) {
            user = User(response['user']['avatar'] ,response['user']['name']);
          }
          url = response['comments']['next_page_url'];
          // var user_id = response['user_id'];
          if (mounted) {
            setState(() {
              response['comments']['data'].forEach((k) {
                comments.add(Comment(
                    k['id'].toString(),
                    k['comment'].toString(),
                    k['avatar'],
                    k['name'].toString(),
                    formatDate(k['created_at'].toString()), true));
              });
              print(comments.length);
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

    if (mounted && firstPage == false) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    url = "${api_endpoint}api/v1/comments/${widget.id}";
    makeConnection();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          double pos = _controller.position.pixels;
          _loadData(context);
          _controller.position.setPixels(pos);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              elevation: 0,
              toolbarHeight: 70,
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.black,
              )),
          body: Column(
            children: [
              Expanded(
                child: isLoading && comments.length == 0
                    ? Center(
                        child: CircularProgressIndicator(
                          color: primaryColorRGB(1),
                        ),
                      )
                    : comments.length == 0
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
                            child: ListView.builder(
                              controller: _controller,
                              reverse: true,
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: imageHead(
                                      comments[index].avatar != null
                                          ? api_endpoint + comments[index].avatar!
                                          : null),
                                  title: Text(comments[index].name), 
                                  subtitle: Text(comments[index].comment),   
                                  trailing: comments[index].sent ? Text(comments[index].createdAt) : Icon(Icons.watch_later),                              
                                );
                              },
                            ),
                            onRefresh: onRefresh),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  child: TextFormField(
                                    controller: comment,
                                decoration: InputDecoration(
                                    hintText: 'Enter your comments',
                                    border: InputBorder.none),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {
                      if(!isLoading) {
                        _sendTextMessage(context);
                      }
                    }, icon: Icon(Icons.send)),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

Widget imageHead(String? url) {
  if (url == null) {
    return CircleAvatar(
      backgroundImage: AssetImage('assets/images/default-profile-picture.jpg'),
    );
  }

  return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
            backgroundImage: imageProvider,
          ),
      placeholder: (context, url) => CircleAvatar(
            backgroundImage: AssetImage('assets/images/image_loader.gif'),
          ),
      errorWidget: (context, url, error) => CircleAvatar(
            backgroundImage:
                AssetImage('assets/images/default-profile-picture.jpg'),
          ));
}
