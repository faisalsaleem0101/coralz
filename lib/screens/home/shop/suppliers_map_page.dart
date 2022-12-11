// ignore_for_file: prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/screens/home/shop/map_data.dart';
import 'package:coralz/screens/home/shop/suppliers_form_page.dart';
import 'package:coralz/screens/home/show_image_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:coralz/config/app.dart';
import 'package:coralz/screens/home/chat/shimmer_loading.dart';
import 'package:coralz/screens/theme/simple_header_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SuppliersMapPage extends StatefulWidget {
  const SuppliersMapPage({Key? key}) : super(key: key);

  @override
  State<SuppliersMapPage> createState() => _SuppliersMapPageState();
}

// class Supplier {
//   String id;
//   String name;
//   String phone;
//   String? webAddress;
//   String address;
//   double latitude;
//   double longitude;
//   String? description;
//   int type;
//   Supplier(this.id, this.name, this.phone, this.webAddress, this.address, this.latitude, this.longitude, this.description);
// }

class _SuppliersMapPageState extends State<SuppliersMapPage> {
  final double _headerHeight = 220;
  bool isLoading = true;
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.509865,  -0.118092),
    zoom: 4.2,
  );
  final List<Marker> _markers = <Marker>[];

  List data = [];

  BitmapDescriptor checkType(String type) {
    if(type == '1') {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    } else if(type == '2') {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

    } else if(type == '3') {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      var result = await http.get(Uri.parse(api_endpoint + "api/v1/suppliers"));
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        print(response);
        if (response['status']) {
          if (mounted) {
            setState(() {
              data = response["data"];
              response["data"].forEach((element) {
                print(double.parse(element['latitude']));
                _markers.add(Marker(
                  icon: checkType(element['type'].toString()),
                    markerId: MarkerId(element['id'].toString()),
                    position: LatLng(double.parse(element['latitude']),
                        double.parse(element['longitude'])), onTap: (){
                        displayMapDialog(element, context);
                        }));
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
  void initState() {
    super.initState();
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
            child: SimpleHeaderWidget(
                _headerHeight, true, Icons.person, "Suppliers Map"),
          ),
          Expanded(
              child: isLoading
                  ? ShimmerLoading()
                  : data.length == 0
                      ? Center(
                          child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/nodata-found.png"),
                                  fit: BoxFit.contain)),
                        ))
                      : Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: _kGooglePlex,
                                markers: Set<Marker>.of(_markers),
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                              ),
                            ),
                            Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: 180,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      ListTile(
                                        horizontalTitleGap: 0,
                                        visualDensity: VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        leading: Icon(
                                          Icons.circle_outlined,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          'Home User',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ListTile(
                                        horizontalTitleGap: 0,
                                        visualDensity: VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        leading: Icon(
                                          Icons.circle_outlined,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          'Online Shops',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ListTile(
                                        horizontalTitleGap: 0,
                                        visualDensity: VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        leading: Icon(
                                          Icons.circle_outlined,
                                          color: Colors.green,
                                        ),
                                        title: Text(
                                          'Local Shops',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ListTile(
                                        horizontalTitleGap: 0,
                                        visualDensity: VisualDensity(
                                            horizontal: -4, vertical: -4),
                                        leading: Icon(
                                          Icons.circle_outlined,
                                          color: Colors.orange,
                                        ),
                                        title: Text(
                                          'Wholesale',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        ))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (builder) => SupplierFormPage()));
        },
        label: Text('Click Here to fill your form'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// class SuppliersMapPage extends StatefulWidget {
//   const SuppliersMapPage({Key? key}) : super(key: key);

//   @override
//   State<SuppliersMapPage> createState() => _SuppliersMapPageState();
// }

// class _SuppliersMapPageState extends State<SuppliersMapPage> {
//   Completer<GoogleMapController> _controller = Completer();

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   static final CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: GoogleMap(
//           mapType: MapType.normal,
//           initialCameraPosition: _kGooglePlex,
//           onMapCreated: (GoogleMapController controller) {
//             _controller.complete(controller);
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(context, MaterialPageRoute(builder: (builder) => SupplierFormPage()));
//         },
//         label: Text('Click Here to fill your form'),
//         icon: Icon(Icons.directions_boat),
//       ),
//     );
//   }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }

// final double _headerHeight = 220;
// int indexOfPage = 2;

// @override
// void didChangeDependencies() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (mounted)
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         elevation: 0,
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.transparent,
//         content: AwesomeSnackbarContent(
//           title: 'Error!',
//           message: 'Something went wrong!',
//           contentType: ContentType.failure,
//         ),
//       ));
//   });
//   super.didChangeDependencies();
// }

// @override
// Widget build(BuildContext context) {
//   // return PostViewPage();
//   return Scaffold(
//     body: Column(
//       children: [
//         Container(
//           height: _headerHeight,
//           child: AppBarWidget(_headerHeight, true, Icons.person),
//         ),
//         Expanded(child:Container())
//       ],
//     ),
//   );
// }
// }
