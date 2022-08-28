import 'package:coralz/config/app.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';


class SocketPage extends StatefulWidget {
  const SocketPage({Key? key}) : super(key: key);

  @override
  State<SocketPage> createState() => _SocketPageState();
}

class _SocketPageState extends State<SocketPage> {
  late Socket socket;

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
        socket.emit('msg', 'Im from flutter');
      });
      // socket.on('location', handleLocationListen);
      // socket.on('typing', handleTyping);
      // socket.on('message', handleMessage);
      // socket.on('disconnect', (_) => print('disconnect'));
      // socket.on('fromServer', (_) => print(_));

    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => makeConnection());
    super.didChangeDependencies();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ok'),),
    );
  }
}