import 'dart:convert';
import 'dart:io';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/show_image_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Img;
import 'package:http_parser/http_parser.dart';

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

class Message {
  int type;
  String id;
  String body;
  String attachment;
  bool sent = true;
  bool fail = false;
  String date;
  File? file;
  Message(this.type, this.id, this.body, this.attachment, this.sent, this.fail,
      this.date,
      {this.file});
}

class ChatPage extends StatefulWidget {
  final String user_id;
  final String id;
  final String name;
  const ChatPage(this.user_id, this.id, this.name, {Key? key})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState(this.user_id, id, name);
}

class _ChatPageState extends State<ChatPage> {
  final _controller = ScrollController();
  final double _headerHeight = 220;
  bool isLoading = true;
  bool firstPage = true;

  late Socket socket;

  final TextEditingController _message = TextEditingController();

  late final String user_id;
  late final String id;
  late final String name;
  String? url;

  void makeConnection() {
    try {
      print(chat_endpoint);
      socket = io(chat_endpoint, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();

      // Handle socket events
      socket.on('connect', (_) {
        print('connect: ${socket.id}');
      });
      socket.on('msg', handleMessageReceive);
      // socket.on('typing', handleTyping);
      // socket.on('message', handleMessage);
      // socket.on('disconnect', (_) => print('disconnect'));
      // socket.on('fromServer', (_) => print(_));

    } catch (e) {
      print(e);
    }
  }

  _ChatPageState(this.user_id, this.id, this.name) {
    url = "${api_endpoint}api/v1/messages?other_user_id=$id";
    makeConnection();
  }

  @override
  void initState() {
    super.initState();
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

  List<Message> messages = [];
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
          url = response['messages']['next_page_url'];
          var user_id = response['user_id'];
          if (mounted) {
            setState(() {
              response['messages']['data'].forEach((k) {
                messages.add(Message(
                    user_id == k['from_id'] ? 1 : 0,
                    k['id'].toString(),
                    k['body'] == null ? '' : k['body'],
                    k['attachment'] == null ? '' : k['attachment'],
                    true,
                    false,
                    formatDate(k['created_at'])));
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

    if (mounted && firstPage == false) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleMessageReceive(var msg) {
    var msg_json = jsonDecode(msg);
    print(msg_json);
    try {
      if (msg_json['message']['from_id'].toString() == id.toString() &&
          msg_json['message']['to_id'].toString() == user_id) {
        if (mounted) {
          setState(() {
            messages.insert(
                0,
                Message(
                    0,
                    msg_json['message']['id'].toString(),
                    msg_json['message']['body'] == null
                        ? ''
                        : msg_json['message']['body'],
                    msg_json['message']['attachment'] == null
                        ? ''
                        : msg_json['message']['attachment'],
                    true,
                    false,
                    formatDate(msg_json['message']['created_at'])));
          });
        }
      }
    } catch (e) {
      print('Chat event ${e.toString()}');
    }
  }

  Future<void> _sendTextMessage(BuildContext context) async {
    if (_message.text.isEmpty) {
      return;
    }

    var user_message = _message.text;
    _message.text = '';
    String u_id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (mounted) {
        setState(() {
          messages.insert(
              0,
              Message(1, u_id, user_message, '', false, false,
                  formatDate(DateTime.now().toString())));
        });
      }

      String? token = await getBearerToken();
      var result = await http.post(Uri.parse(api_endpoint + "api/v1/message"),
          body: {'to_id': id, 'body': user_message},
          headers: {"Authorization": "Bearer " + token!});

      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          Message message;
          for (var i = 0; i < messages.length; i++) {
            if (messages[i].id == u_id) {
              message = messages[i];
              message.sent = true;
              setState(() {});
              break;
            }
          }

          if (socket != null) {
            socket.emit('msg', jsonEncode(response));
          }

          // set sent true

          return; // termintate furthor code
        } else {}
      }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      Message message;
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].id == u_id) {
          message = messages[i];
          setState(() {
            message.fail = true;
          });
          break;
        }
      }
    }

    // Set sent false
  }

  Future<void> _sendMediaMessage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    if (image == null) {
      return;
    }

    String u_id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (mounted) {
        setState(() {
          messages.insert(
              0,
              Message(1, u_id, '', '', false, false,
                  formatDate(DateTime.now().toString()),
                  file: File(image.path)));
        });
      }

      String? token = await getBearerToken();

      var request = http.MultipartRequest(
          "POST", Uri.parse(api_endpoint + "api/v1/message"));
      request.headers['Authorization'] = "Bearer " + token!;

      // resized Image
      Img.Image? image_temp =
          Img.decodeImage(File(image.path).readAsBytesSync());
      if (image_temp == null) {
        return;
      }
      Img.Image resized_img = Img.copyResize(image_temp, width: 300);
      // End

      request.files.add(http.MultipartFile.fromBytes(
          'attachment', Img.encodeJpg(resized_img),
          filename: 'resized_image.jpg',
          contentType: MediaType.parse('image/jpeg')));

      request.fields['to_id'] = id;

      var response = await request.send();
      var responseData = await response.stream.toBytes();

      if (response.statusCode == 200) {
        var result = String.fromCharCodes(responseData);
        var response = jsonDecode(result);
        if (response['status']) {
          print(response);
          Message message;
          for (var i = 0; i < messages.length; i++) {
            if (messages[i].id == u_id) {
              message = messages[i];

              setState(() {
                message.sent = true;
              });
              break;
            }
          }

          if (socket != null) {
            socket.emit('msg', jsonEncode(response));
          }

          // set sent true

          return; // termintate furthor code
        } else {}
      }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      Message message;
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].id == u_id) {
          message = messages[i];
          setState(() {
            message.fail = true;
          });
          break;
        }
      }
    }

    // Set sent false
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
            child: SimpleHeaderWidget(_headerHeight, true, Icons.person, name),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColorRGB(1),
                    ),
                  )
                : ListView.builder(
                    controller: _controller,
                    reverse: true,
                    padding: EdgeInsets.zero,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageTile(messages[index]);
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
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
                            controller: _message,
                            decoration: InputDecoration(
                                hintText: 'Enter your message',
                                border: InputBorder.none),
                          )),
                          IconButton(
                              onPressed: () {
                                print('Test');
                                _sendTextMessage(context);
                              },
                              icon: Icon(Icons.send)),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _sendMediaMessage(context);
                    },
                    icon: Icon(Icons.add_a_photo)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  Message message;
  MessageTile(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.type == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 6),
            child: Align(
              alignment: (Alignment.topRight),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20)),
                    color: (message.fail ? Colors.red : Colors.blue),
                  ),
                  padding: EdgeInsets.all(message.body.isEmpty ? 8 : 16),
                  child: message.file == null
                      ? message.body.isEmpty
                          ? image(
                              api_endpoint + message.attachment, context, null)
                          : Text(
                              message.body,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            )
                      : image('', context, message.file)),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                message.sent
                    ? Icon(
                        Icons.done,
                        size: 16,
                      )
                    : message.fail
                        ? Icon(
                            Icons.error,
                            size: 16,
                          )
                        : Icon(
                            Icons.watch_later,
                            size: 16,
                          ),
                SizedBox(
                  width: 10,
                ),
                Text(message.date),
              ],
            ),
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 6),
          child: Align(
            alignment: (Alignment.topLeft),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: (Colors.grey.shade300),
                ),
                padding: EdgeInsets.all(message.body.length == 0 ? 8 : 16),
                child: message.body.length == 0
                    ? image(api_endpoint + message.attachment, context, null)
                    : Text(
                        message.body == null ? '' : message.body,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      )),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 0, bottom: 10),
          child: Row(
            children: [
              Text(message.date),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        )
      ],
    );
  }
}

Widget image(String url, BuildContext context, File? file) {
  if (file != null) {
    return GestureDetector(
      onTap: () {
        displayDialog('', context, file);
      },
      child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                  fit: BoxFit.cover, image: Image.file(file).image))),
    );
  }
  return GestureDetector(
    onTap: () {
      displayDialog(url, context, null);
    },
    child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image:
                    DecorationImage(fit: BoxFit.cover, image: imageProvider))),
        placeholder: (context, url) => Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/image_loader.gif")))),
        errorWidget: (context, url, error) => Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/image_not_found.png"))))),
  );
}
