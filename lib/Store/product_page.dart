import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/conversation_screen.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Store/storehome.dart';

import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Models/item.dart';
import 'package:flutter/material.dart';

import 'package:e_shop/Config/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:url_launcher/url_launcher.dart';

bool favorite = true;
String loc = "fetching";
String distance = "";
bool iffav = false;
String poster="Loading...";
String posterurl = "https://media2.govtech.com/images/940*712/SHUTTERSTOCK_LOADING_SYMBOL_BROADBAND_INTERNET_SPEED.jpg";
String pemail;


class ProductPage extends StatefulWidget {
  final ItemModel itemModel;
  final String page;
  ProductPage({this.itemModel, this.page});

  @override
  PetDetail createState() => PetDetail();
}

class PetDetail extends State<ProductPage> {
  initState() {
    super.initState();
    loactionHandler(widget.itemModel.location.longitude,
        widget.itemModel.location.latitude);
    distancefinder(widget.itemModel.location.longitude,
        widget.itemModel.location.latitude);
    if (petadoptapp.sharedPreferences.getStringList("userCart").contains(widget.itemModel.publishedDate.millisecondsSinceEpoch.toString() + widget.itemModel.uid)) {
      iffav = true;

    }
    else{iffav = false;}


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: (){
      if(widget.page=="home")
      {
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      }
      else if (widget.page=="upload")
      {
        Route route = MaterialPageRoute(builder: (c) => UploadPage());
        Navigator.pushReplacement(context, route);
      }
      else if (widget.page=="fav")
      {
        Route route = MaterialPageRoute(builder: (c) => CartPage());
        Navigator.pushReplacement(context, route);
      }
    } , child: Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if(widget.page=="home")
            {
              Route route = MaterialPageRoute(builder: (c) => StoreHome());
              Navigator.pushReplacement(context, route);
            }
            else if (widget.page=="upload")
            {
              Route route = MaterialPageRoute(builder: (c) => UploadPage());
              Navigator.pushReplacement(context, route);
            }
            else if (widget.page=="fav")
            {
              Route route = MaterialPageRoute(builder: (c) => CartPage());
              Navigator.pushReplacement(context, route);
            }

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
                  tag: widget.itemModel.thumbnailUrl1,
                  child: Container(
                    child: (widget.itemModel.thumbnailUrl1 != null &&
                        widget.itemModel.thumbnailUrl2 != null &&
                        widget.itemModel.thumbnailUrl3 != null)
                        ? Carousel(
                      images: [
                        NetworkImage(widget.itemModel.thumbnailUrl1),
                        NetworkImage(widget.itemModel.thumbnailUrl2),
                        NetworkImage(widget.itemModel.thumbnailUrl3)
                      ], autoplayDuration:const Duration (seconds: 8),
                    )
                        : (widget.itemModel.thumbnailUrl1 != null &&
                        widget.itemModel.thumbnailUrl2 != null)
                        ? Carousel(
                      images: [
                        NetworkImage(widget.itemModel.thumbnailUrl1),
                        NetworkImage(widget.itemModel.thumbnailUrl2),
                      ],autoplayDuration:const Duration (seconds: 8),
                    )
                        : (widget.itemModel.thumbnailUrl1 != null &&
                        widget.itemModel.thumbnailUrl3 != null)
                        ? Carousel(
                      images: [
                        NetworkImage(
                            widget.itemModel.thumbnailUrl1),
                        NetworkImage(
                            widget.itemModel.thumbnailUrl3),
                      ], autoplayDuration:const Duration (seconds: 8),
                    )
                        : Carousel(
                      images: [
                        NetworkImage(
                            widget.itemModel.thumbnailUrl1),
                      ], autoplayDuration:const Duration (seconds: 8),
                    ),
                  ),
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
                              widget.itemModel.breed,
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
                                width: 220,
                                child: Text(
                                  loc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              )

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
                              openMap(widget.itemModel.location.latitude,
                                  widget.itemModel.location.longitude);
                            }),

                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iffav==true ? Colors.red[400] : Colors.white,
                        ),
                        child:iffav == true
                            ? IconButton(
                            icon: Icon(Icons.favorite,  color: iffav ? Colors.white : Colors.grey[300],),
                            onPressed: () {favdelitem(widget.itemModel);})
                            : IconButton(
                            icon: Icon(Icons.favorite_border_outlined, color: iffav ? Colors.white : Colors.grey[300],
                            ),
                            onPressed: () {favitem(widget.itemModel);}),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      buildPetFeature(
                          widget.itemModel.age.toString() + " Years", "Age"),
                      buildPetFeature(widget.itemModel.color, "Color"),
                      buildPetFeature(
                          widget.itemModel.weight + " Kg", "Weight"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Pet Story",
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
                    widget.itemModel.info,
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
                              Text(
                                poster,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),

                            ],

                          ),

                        ],
                      ),

                      InkWell(child:Container(
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
                          onTap: () {createchatroom(widget.itemModel);}),
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
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
    double i = lat;
    double j = lon;
    final coordinates = new Coordinates(i, j);

    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    setState(() {
      loc = first.addressLine;
    });
  }

  Future distancefinder(double lon, double lat) async {
    DocumentSnapshot variable = await petadoptapp.firestore.collection("users").document(widget.itemModel.uid).get();
    poster=variable.data['name'];
    posterurl=variable.data['url'];
    pemail=variable.data['email'];

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

  Future favitem(ItemModel tempModel) async {
    if (petadoptapp.sharedPreferences.getStringList("userCart").contains(
        tempModel.publishedDate.millisecondsSinceEpoch.toString() +
            tempModel.uid)) {
      Fluttertoast.showToast(msg: "Already Favorited");
    } else {
      List tempCartList = new List();

      tempCartList =
          petadoptapp.sharedPreferences.getStringList(petadoptapp.userCartList);

      tempCartList.add(tempModel.publishedDate.millisecondsSinceEpoch.toString() +
          tempModel.uid);

      petadoptapp.firestore
          .collection("users")
          .document(petadoptapp.sharedPreferences.getString("uid"))
          .updateData({
        "userCart": tempCartList,
      }).then((v) {
        Fluttertoast.showToast(msg: "Post Favorited Successfully");
        setState(() {
          petadoptapp.sharedPreferences
              .setStringList(petadoptapp.userCartList, tempCartList);
          iffav=true;
        });

      });
    }
  }

  Future favdelitem(ItemModel tempModel) async {

    List tempCartList = new List();

    tempCartList = petadoptapp.sharedPreferences.getStringList(petadoptapp.userCartList);

    tempCartList.remove(tempModel.publishedDate.millisecondsSinceEpoch.toString() +
        tempModel.uid);

    petadoptapp.firestore
        .collection("users")
        .document(petadoptapp.sharedPreferences.getString("uid"))
        .updateData({
      "userCart": tempCartList,
    }).then((v) {
      Fluttertoast.showToast(msg: "Post Unfavorited");
      setState(() {
        petadoptapp.sharedPreferences
            .setStringList(petadoptapp.userCartList, tempCartList);
        iffav= false;
      });

    });
  }

  Future createchatroom(ItemModel tempModel) async {

    String chatroomid;

    String uid1= petadoptapp.sharedPreferences.getString(petadoptapp.userUID).toString();


    String uid2= tempModel.uid;
    if(uid1!=uid2)
    {
      if(uid1.compareTo(uid2) == 1)
      {
        chatroomid= uid1+uid2;
      }
      else if (uid1.compareTo(uid2) == -1)
      {
        chatroomid= uid2+uid1;
      }



      Map<String, dynamic> chatRoomMap= {
        "users1" : uid1,
        "users2" : uid2,
        "chatroomid" : chatroomid,
      };

      final itemsRef = Firestore.instance.collection("chatroom");
      await itemsRef
          .document(chatroomid)
          .setData(
          chatRoomMap
      );
      Navigator.push (context ,MaterialPageRoute(
          builder: (context) => ConversationScreen(chatroomid: chatroomid,userid: uid1,poster : uid2 , phone : widget.itemModel.phone, posteremail: pemail, posterurl:posterurl)
      ));
    }
    else{
      Fluttertoast.showToast(msg: "Cant Message Yourself");
    }



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
