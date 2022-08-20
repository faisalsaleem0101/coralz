// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';


class AquariumsPage extends StatefulWidget {
  const AquariumsPage({Key? key}) : super(key: key);

  @override
  State<AquariumsPage> createState() => _AquariumsPageState();
}

class _AquariumsPageState extends State<AquariumsPage> {

  bool isLoading = false;
  List data = [];

  Future<void> _loadData(BuildContext context) async {
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
    
    try {
      String? token = await getBearerToken();
      var result = await http.get(Uri.parse(api_endpoint+"api/v1/categories/1"), headers: {
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
    return 
      Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Aquariums',
              style: TextStyle(
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: PostForm()
            )
          ],
        ),
      );
  }
  

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
  //       height: double.infinity,
  //       width: double.infinity,
  //       child: Column(
  //         children: [
  //           Text(
  //             'Aquariums',
  //             style: TextStyle(
  //               fontSize: 26,
  //               color: Colors.black,
  //               fontWeight: FontWeight.bold,
  //               decoration: TextDecoration.underline
  //             ),
  //           ),
  //           SizedBox(height: 20,),
  //           Expanded(
  //             child: isLoading ? ShimmerLoading() : PageData(data)
  //           )
  //         ],
  //       ),
  //     );
  // }
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


class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  @override
  Widget build(BuildContext context) {
    return 
      SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Title",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 6,),
                    Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Colors.grey.shade500,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Text...',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description 2",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 6,),
                    Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Colors.grey.shade500,
                      child: TextFormField(
                        maxLines: 5,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Text...',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 6,),
                    Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Colors.grey.shade500,
                      child: TextFormField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.currency_pound),
                          hintText: 'Type...',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Location",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 6,),
                    Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Colors.grey.shade500,
                      child: TextFormField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.location_searching),
                          hintText: 'Select',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      );
  }
}