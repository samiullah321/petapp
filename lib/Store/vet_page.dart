import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/conversation_screen.dart';

import 'package:e_shop/Models/vetModel.dart';

import 'package:e_shop/Store/vethomepage.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'package:geocoder/geocoder.dart';

import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';



String loc = "fetching";
String distance = "";

String poster="Loading...";
String posterurl="https://d1csarkz8obe9u.cloudfront.net/posterpreviews/hospital-logo-design-template-ad2e9db3845f2a6f1720ffada27c7eec_screen.jpg?ts=1570783104";
String pemail;


class VetPage extends StatefulWidget {
  final vetModel model;

  VetPage({this.model});

  @override
  VetDetail createState() => VetDetail();
}

class VetDetail extends State<VetPage> {
  initState() {
    super.initState();
    setState(() {
      loactionHandler(widget.model.location.longitude,
          widget.model.location.latitude);
      // print ("here");
      distancefinder(widget.model.location.longitude,
          widget.model.location.latitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () {
      Route route = MaterialPageRoute(builder: (c) => VetHome());
      Navigator.pushReplacement(context, route);
    }, child: Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(builder: (c) => VetHome());
            Navigator.pushReplacement(context, route);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey[800],
          ),
        ),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: widget.model.thumbnailUrl,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(widget.model
                          .thumbnailUrl),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  ),
                  //
                ),
                //
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              widget.model.name,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "(" + distance + " km)",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              Container(
                                child: Text(

                                  loc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                                width: 290,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.shade50,
                        ),
                        child: IconButton(
                            icon: Icon(Icons.location_on_rounded,
                                color: Colors.amber.shade400),
                            onPressed: () {
                              openMap(widget.model.location.latitude,
                                  widget.model.location.longitude);
                            }),

                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, right: 8, left: 8),
                  child: Row(
                    children: [
                      buildPetFeature(
                          widget.model.hospital.toString() + "", "Hospital"),
                      buildPetFeature(widget.model.timings, "Timings"),
                      buildPetFeature(
                          widget.model.workingDays + "", "Work Days"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Description",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.model.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding:
                  EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Material(
                            borderRadius:
                            BorderRadius.all(Radius.circular(80.0)),
                            elevation: 8.0,
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  posterurl,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Posted by",

                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(
                                height: 4,
                              ),
                              Container(width: 180,child: Text(
                                widget.model.hospital,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),),

                            ],
                          ),
                        ],
                      ),
                      InkWell(child: Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue[300].withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ],
                          color: Colors.blue[300],
                        ),
                        child: Text(
                          "Contact Me",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                          onTap: () {
                            showModal();
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  buildPetFeature(String value, String feature) {
    return Expanded(
      child: Container(
        height: 70,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[200],
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Container(
            child:Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),)

            ),
            SizedBox(
              height: 4,
            ),
            Text(
              feature,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future loactionHandler(double lon, double lat) async {
    // double i = lat;
    // double j = lon;
    // final coordinates = new Coordinates(i, j);
    //print("$lat $lon" );
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        new Coordinates(lat, lon));
    var first = addresses.first;
    //print("${first.featureName} : ${first.addressLine}");
    //var first = addresses.first;
    setState(() {
      loc = addresses.first.addressLine;
    });
  }

  void call(String number, String email, String text) {
    if (text == "Phone") {
      launch("tel:$number");
    }
    if (text == "Message") {
      launch("sms:$number");
    }
    if (text == "Email") {
      launch("mailto:$email");
    }
  }

  Future distancefinder(double lon, double lat) async {
    // DocumentSnapshot variable = await petadoptapp.firestore.collection("users").document(widget.itemModel.uid).get();
    // poster=variable.data['name'];
    // posterurl=variable.data['url'];
    // pemail=variable.data['email'];

    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    // print(_locationData.latitude);
    // print(_locationData.longitude);
    // print(lat);
    // print(lon);
    double distanceInMeters = Geolocator.distanceBetween(
        _locationData.latitude, _locationData.longitude, lat, lon);
    distanceInMeters = distanceInMeters / 1000;
    setState(() {
      distance = distanceInMeters.toStringAsFixed(1);
    });
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          List<SendMenuItems> menuItems = [

            SendMenuItems(
              text: "Phone", icons: Icons.phone, color: Colors.amber,),
            SendMenuItems(text: "Message",
                icons: Icons.message_rounded,
                color: Colors.blue),
            SendMenuItems(text: "Email",
                icons: Icons.email_rounded,
                color: Colors.orange),
          ];
          return Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 2.8,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 16,),
                  Center(
                    child: Container(
                      height: 4,
                      width: 50,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(height: 10,),
                  ListView.builder(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          call(widget.model.phone, widget.model.email,
                              menuItems[index].text);
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: menuItems[index].color.shade50,
                              ),
                              height: 50,
                              width: 50,
                              child: IconButton(
                                icon: Icon(menuItems[index].icons),
                                color: menuItems[index].color.shade400,
                                iconSize: 20,
                                onPressed: () =>
                                {
                                  call(widget.model.phone, widget.model.email,
                                      menuItems[index].text),
                                },),
                            ),
                            title: Text(menuItems[index].text),
                          ),
                        ),);
                    },
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      Fluttertoast.showToast(msg: "Could not Open Map");
    }
  }


}

class SendMenuItems{
  String text;
  IconData icons;
  MaterialColor color;
  SendMenuItems({@required this.text,@required this.icons,@required this.color ,});
}
