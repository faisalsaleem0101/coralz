import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

displayMapDialog(var data, BuildContext context) async {
  await showDialog(context: context, builder: (_) => MapData(data));
}

class MapData extends StatelessWidget {
  var data;
  MapData(this.data);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        height: 300,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png',
                width: 100, fit: BoxFit.cover),
            SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${data['name'] ?? '-'}",
                  softWrap: true,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Email: ${data['email'] ?? '-'}",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Address: ${data['address'] ?? '-'}",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Web Address: ${data['web_address'] ?? '-'}",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Description: ${data['description'] ?? '-'}",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              widthFactor: 0.4,
              child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Ok'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 1),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
