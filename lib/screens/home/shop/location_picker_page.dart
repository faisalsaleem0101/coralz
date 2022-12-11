// ignore_for_file: prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/category_page.dart';
import 'package:coralz/screens/home/shop/Place.dart';
import 'package:coralz/screens/home/shop/address_search.dart';
import 'package:coralz/screens/home/shop/suppliers_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:async';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({Key? key}) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  Completer<GoogleMapController> _controller = Completer();

  var kGoogleApiKey = "AIzaSyC6bomnVOjQGeTC2PB4Y63LcW_QOl2K-nM";

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(51.509865,  -0.118092),
    zoom: 4.2,
  );

  // Position? pos;
  Place? selectedPlace;

  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(51.509865, -0.118092))
  ];

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      selectedPlace = Place(pos.latitude, pos.longitude);
    });
    _markers.add(Marker(
      draggable: true,
      onDragEnd: (value) {
        setState(() {
          if(selectedPlace != null) {
            selectedPlace!.latitude = value.latitude;
            selectedPlace!.longitude = value.longitude;
          }
        });
      },
        markerId: MarkerId('2'),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
          title: 'Current Location'
        )));
    CameraPosition cameraPosition = CameraPosition(
      zoom: 20.4,
      target: LatLng(pos.latitude, pos.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  changeLocation(Position pos) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
        title: Text(
          'Pick you location',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          
          IconButton(
              onPressed: () async {
                const kGoogleApiKey = "AIzaSyA5URFbJlN9qFZMgzVhWOlnlgMzlJ7nsS8";

                Place? place = await showSearch(context: context, delegate: AddressSearch()) as Place;
                if(place != null) {
                  setState(() {
                          selectedPlace = place;
                        });
                        _markers.add(Marker(
                          draggable: true,
                          onDragEnd: (value) {
                            setState(() {
                              if(selectedPlace != null) {
                                selectedPlace!.latitude = value.latitude;
                                selectedPlace!.longitude = value.longitude;
                              }
                            });
                          },
                            markerId: MarkerId('2'),
                            position: LatLng(place.latitude, place.longitude),
                            infoWindow: InfoWindow(
                              title: 'Current Location'
                            )));
                        CameraPosition cameraPosition = CameraPosition(
                          zoom: 20.4,
                          target: LatLng(place.latitude, place.longitude),
                        );

                        final GoogleMapController controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
                        setState(() {});
                }
                print(place.longitude);
                

              }, icon: Icon(Icons.search, color: Colors.black)),
          IconButton(
              onPressed: () {
                if(selectedPlace == null) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, selectedPlace);
                }
              }, icon: Icon(Icons.done, color: Colors.black))
        ],
      ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          markers: Set<Marker>.of(_markers),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
          _determinePosition();
          // Navigator.push(context, MaterialPageRoute(builder: (builder) => SupplierFormPage()));
        },
      ),
    );
  }
}
