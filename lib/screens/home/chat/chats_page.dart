import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/chat/chat_page.dart';
import 'package:coralz/screens/home/chat/shimmer_loading.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatHead {
  late String id;
  String? avatar;
  late String name;
  late String date;
  late String lastMessage;
  ChatHead(this.id, this.avatar, this.name, this.date, this.lastMessage);
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late String user_id;

  String formatDate(var dateTime) {
    var dateToCheck = DateTime.parse(dateTime);
    dateToCheck = dateToCheck.toLocal();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return DateFormat("h:mm a").format(dateToCheck);
      // return "${dateToCheck.hour}:${dateToCheck.minute}:${dateToCheck.second}";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else {
      return "${dateToCheck.day}/${dateToCheck.month}/${dateToCheck.year}";
    }

    return "";
  }

  final double _headerHeight = 220;
  bool isLoading = true;
  List<ChatHead> chatHeads = [];

  Future<void> _loadData(BuildContext context) async {
    chatHeads = [];
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse(api_endpoint + "api/v1/chats"),
          headers: {"Authorization": "Bearer " + token!});
      print(result.statusCode);
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);

        print(response['chats']);
        if (response['status']) {
          
          if (mounted) {
            user_id = response['user_id'].toString();
            setState(() {
              response['chats'].forEach((k) {
                var m = "Say Hi!";
                var date = "";
                if (k['last_message'] != null) {
                  m = k['last_message']['attachment'] == null
                      ? k['last_message']['body'].toString()
                      : 'Image';
                  date = formatDate(k['last_message']['created_at']);
                }
                chatHeads.add(ChatHead(
                    k['id'].toString(), k['avatar'], k['name'], date, m));
              });
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
            child:
                SimpleHeaderWidget(_headerHeight, true, Icons.person, "Chats"),
          ),
          Expanded(
              child: isLoading
                  ? ShimmerLoading()
                  : RefreshIndicator(
                      onRefresh: () => _loadData(context),
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: chatHeads.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Card(
                              elevation: 4,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => ChatPage(
                                            user_id,
                                              chatHeads[index].id,
                                              chatHeads[index].name)));
                                },
                                leading: imageHead(chatHeads[index].avatar != null ? api_endpoint + chatHeads[index].avatar! : null),
                                title: Text(chatHeads[index].name),
                                subtitle: Text(chatHeads[index].lastMessage),
                                trailing: Text(chatHeads[index].date),
                              ),
                            ),
                          );
                        },
                      ),
                    ))
        ],
      ),
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
