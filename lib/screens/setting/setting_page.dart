import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/config/user_data.dart';
import 'package:coralz/screens/auth/login_page.dart';
import 'package:coralz/screens/setting/account_management.dart';
import 'package:coralz/screens/setting/help.dart';
import 'package:coralz/screens/setting/privacy_and_policy_page.dart';
import 'package:coralz/screens/setting/term_and_condition_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final double _headerHeight = 220;

  bool isLoading = false;

  Future<void> _logout(BuildContext context) async {
    if(mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      String? token = await getBearerToken();
      await http.post(Uri.parse(api_endpoint+"api/v1/logout"), headers: {
        "Authorization": "Bearer "+token!
      });
      await removeBearerToken();
      await removeUserData();
    } catch (e) {

    } finally {
      if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(),), (route) => false);
    }

    if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Settings"),
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
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => AccountManagementPage()));
                      },
                      title: Text('Account Management'),
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
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => TermAndConditionPage()));

                      },
                      title: Text('Terms & Conditions'),
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
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => PrivacyAndPolicyPage()));
                      },
                      title: Text('Privacy Policy'),
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
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => HelpPage()));

                      },
                      title: Text('Help'),
                      trailing: Icon(Icons.navigate_next)),
                ),

                !isLoading
                ? FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.6,
                    child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _logout(context);
                          },
                          icon: Icon(Icons.logout),
                          label: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold),),
                          style: ElevatedButton.styleFrom(
                              primary: primaryColorRGB(1),
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              elevation: 6),
                        )),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: primaryColorRGB(1),
                    ),
                  ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
