// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Category {
  String? id;
  String? name;
  String? image;
}

class BuyItNowPage extends StatefulWidget {
  const BuyItNowPage({Key? key}) : super(key: key);

  @override
  State<BuyItNowPage> createState() => _AquariumsPageState();
}

class _AquariumsPageState extends State<BuyItNowPage> {

  

  bool isLoading = false;
  List data = <Category>[];

  Future<void> _loadData(BuildContext context) async {
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
    
    try {
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse(api_endpoint+"api/v1/categories/2"), headers: {
        "Authorization": "Bearer "+token!
      });
      if(result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if(response['status']) {
          
          // responsedata.forEach((k, v) => list.add(Customer(k, v)));
          if(mounted){
            setState(() {
              data = response["data"];
            });
          }
          
        } else {
          if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message:
                    'Something went wrong!',
                contentType: ContentType.failure,
              ),
            )
          );
        }

      } else {
        if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message:
                  'Something went wrong!',
              contentType: ContentType.failure,
            ),
          )
        );
      }

    } catch (e) {
      if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message:
                'Something went wrong!',
            contentType: ContentType.failure,
          ),
        )
      );
    }

    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
    
      
  }

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Buy It Now',
              style: TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: isLoading ? ShimmerLoading() : PageData(data)
            )
          ],
        ),
      );
  }
}


Widget PageData(List data) {
  return 
    GridView.builder(
      padding: EdgeInsets.all(15),
      itemCount: data.length,  
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(  
          crossAxisCount: 2,  
          crossAxisSpacing: 15,  
          mainAxisSpacing: 15  
      ),  
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.fromLTRB(10,10,10,30),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(api_endpoint+data[index]["image"]),
              fit: BoxFit.cover,
            )
          ),
          child: Text(data[index]["name"],style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),),
        );
      },  
    );
}