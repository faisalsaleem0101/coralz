import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';

class PostViewPage extends StatefulWidget {
  const PostViewPage({Key? key}) : super(key: key);

  @override
  State<PostViewPage> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 310,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/Equipment.jpg'),
                fit: BoxFit.cover,
              )),
            ),
            SafeArea(
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Marine',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(0, 280, 0, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          child: ListTile(
                              title: Text(
                                'Marine',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('End Time 7 August 2019 01:00 PM'),
                              trailing: Text(
                                "£" + "60.00",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          child: ListTile(
                              title: Text(
                                'Boy Now Price',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                "£" + "0",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          child: ListTile(
                              title: Text(
                                'Quantity Available',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                "1",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Offer/Buy It Now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 6,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: '£',
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, bottom: 11, top: 11, right: 15),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Submit'),
                            style: ElevatedButton.styleFrom(
                                primary: secondaryColorRGB(1),
                                padding: EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                elevation: 6),
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 6,
                              shadowColor: Colors.grey.shade500,
                              child: TextFormField(
                                maxLines: 15,
                                minLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
