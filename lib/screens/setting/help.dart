import 'package:coralz/screens/profile/edit_profile_page.dart';
import 'package:coralz/screens/setting/contact_page.dart';
import 'package:coralz/screens/setting/faq_page.dart';
import 'package:coralz/screens/setting/profile_password_update.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final double _headerHeight = 220;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Help"),
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 6,
                  child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => FaqPage()));
                      },
                      title: Text('FAQ'),
                      trailing: Icon(Icons.navigate_next)),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 6,
                  child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => ContactPage()));
                      },
                      title: Text('Contact The Coralz Team'),
                      trailing: Icon(Icons.navigate_next)),
                ),

                
              ],
            ),
          ))
        ],
      ),
    );
  }
}
