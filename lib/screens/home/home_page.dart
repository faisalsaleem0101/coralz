// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:coralz/config/bottom_bar_icons_icons.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:coralz/screens/home/chat/chat_page.dart';
import 'package:coralz/screens/home/shop_page.dart';
import 'package:coralz/screens/home/swap/swap_view_page.dart';
import 'package:coralz/screens/home/user/user_profile_page.dart';
import 'package:coralz/screens/post/post_view_page.dart';
import 'package:coralz/screens/services/local_notifications_services.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final LocalNotificationService service;
  int counter = 0;

  final double _headerHeight = 220;
  int indexOfPage = 2;

  Widget WidgetPage(int indexOfPage) {
    if (indexOfPage == 0) {
      return CategoryPage('1', 'Aquariums', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 1) {
      return CategoryPage('2', 'Buy It Now', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 2) {
      return CategoryPage('3', 'Auctions', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 3) {
      return CategoryPage('4', 'Fish', key: Key(indexOfPage.toString()));
    } else if (indexOfPage == 4) {
      return ShopPage();
    }

    return Container(
      child: Text('under construction'),
    );
  }

  getPermission() async {
    await [
      Permission.storage,
      Permission.camera,
    ].request();
  }

  StreamSubscription? _sub;

  Future<void> initUniLinks(BuildContext context) async {
    String? initUrl = await getInitialLink();
    if (initUrl != null) {
      Uri uri = Uri.parse(initUrl);
      if (uri.queryParameters['user'] != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) =>
                    UserProfilePage(uri.queryParameters['user'].toString())));
      } else if (uri.queryParameters['post'] != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                PostViewPage(uri.queryParameters['post'].toString())));
      } else if (uri.queryParameters['swap'] != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                SwapPostViewPage(uri.queryParameters['swap'].toString())));
      }
    }

    _sub = linkStream.listen((link) {
      print('listner started');
      if (link != null) {
        Uri uri = Uri.parse(link);
        if (uri.queryParameters['user'] != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) =>
                      UserProfilePage(uri.queryParameters['user'].toString())));
        } else if (uri.queryParameters['post'] != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  PostViewPage(uri.queryParameters['post'].toString())));
        } else if (uri.queryParameters['swap'] != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SwapPostViewPage(uri.queryParameters['swap'].toString())));
        }
      }
    }, onError: (err) {});
  }

  void registerNotification() async {

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleNavigation(jsonEncode(initialMessage.data));
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleNavigation(jsonEncode(event.data));
    });

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (message.notification != null) {
          counter++;
          await service.showNotification(
              id: counter,
              title: message.notification!.title!,
              body: message.notification!.body!,
              payload: jsonEncode(message.data));
          // // For displaying the notification as an overlay
          // showSimpleNotification(Text(message.notification!.title!),
          //     subtitle: Text(message.notification!.body!),
          //     autoDismiss: true,
          //     background: Colors.white,
          //     foreground: Colors.black,
          //     slideDismissDirection: DismissDirection.horizontal);
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPermission();
    initUniLinks(context);
  }

  @override
  void initState() {
    if (!kIsWeb) {
      registerNotification();
    }
    service = LocalNotificationService(context);
    service.initialize();
    listenToNotifications();
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return (
  //     ProfilePage()
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // return PostViewPage();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Expanded(child: WidgetPage(indexOfPage))
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColorRGB(1),
        color: bottomBarColor(),

        items: [
          TabItem(
              icon: Icon(
                BottomBarIcons.aquariums,
                color: indexOfPage == 0 ? primaryColorRGB(1) : bottomBarColor(),
              ),
              title: 'Aquariums'),
          TabItem(
              icon: Icon(BottomBarIcons.buy_it_now,
                  color:
                      indexOfPage == 1 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Buy It Now'),
          TabItem(
              icon: Icon(BottomBarIcons.auction,
                  color:
                      indexOfPage == 2 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Auctions'),
          TabItem(
              icon: Icon(BottomBarIcons.fish,
                  color:
                      indexOfPage == 3 ? primaryColorRGB(1) : bottomBarColor()),
              title: 'Fish'),
          TabItem(
            icon: Icon(BottomBarIcons.shop,
                color:
                    indexOfPage == 4 ? primaryColorRGB(1) : bottomBarColor()),
            title: 'Shop',
          ),
        ],
        initialActiveIndex: 2, //optional, default as 0
        onTap: (int i) {
          setState(() {
            indexOfPage = i;
          });
        },
      ),
    );
  }

  void listenToNotifications() =>
      service.onNotificationClick.stream.listen((event) {
        if (event != null) {
          handleNavigation(event);
        }
      });
  void handleNavigation(String? event) {
    if (event != null) {
      var notification = jsonDecode(event);
      if (notification['key'] != null) {
        if (notification['key'].toString() == "5") {
          if (notification['user_id'] != null &&
              notification['sender_user_id'] != null &&
              notification['sender_user_name'] != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ChatPage(
                    notification['user_id'].toString(),
                    notification['sender_user_id'].toString(),
                    notification['sender_user_name'].toString())));
          }
        } else if (notification['key'].toString() == "1") {
          if (notification['post_id'] != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    PostViewPage(notification['post_id'].toString())));
          }
        } else if (notification['key'].toString() == "2") {
          if (notification['from_user_id'] != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    UserProfilePage(notification['from_user_id'].toString())));
          }
        }
      }
    }
  }
}

Future<void> messageHandler() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const NotificationDetails platformChannelSpecifics = NotificationDetails();
    await flutterLocalNotificationsPlugin.show(0, event.notification!.title,
        event.notification!.body, platformChannelSpecifics);
    print(event.notification!.body);
    // try {
    //   showNotification(event);
    // } catch (e) {
    // }
  });
}

Future<void> showNotification(RemoteMessage payload) async {
  var android = AndroidInitializationSettings('logo_rs');
  var initiallizationSettingsIOS = DarwinInitializationSettings();
  var initialSetting =
      InitializationSettings(android: android, iOS: initiallizationSettingsIOS);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initialSetting);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_notification_channel_id', 'Notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: "logo_rs",
      playSound: true,
      sound: RawResourceAndroidNotificationSound("notification"));
  const iOSDetails = DarwinNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails();

  await flutterLocalNotificationsPlugin.show(0, payload.notification!.title,
      payload.notification!.body, platformChannelSpecifics);
}
