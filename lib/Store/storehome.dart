import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';

import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Config/config.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import '../Widgets/searchBox.dart';
import '../Models/item.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

double width;
int numberPost = 0;
const kPrimaryColor = Color(0xFF27608D);
const kTextColor = Color(0xFF746F67);
const kText2Color = Colors.black45;
String distance = "fetching";
double tlat;
double tlong;

const kTitleStyle = TextStyle(
  fontSize: 20.0,
  color: kTextColor,
  fontWeight: FontWeight.bold,
);

const kSubtitleStyle = TextStyle(
  fontSize: 16.0,
  color: kTextColor,
);

const kSubtitle2Style = TextStyle(
  fontSize: 13.0,
  color: kText2Color,
);
SearchBoxDelegate item;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  startSearching() {
    setState(() {
      print(1);
    });
  }

  TextEditingController _searchtextEditingController = TextEditingController();
  ItemModel model;

  Future<QuerySnapshot> docList;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          bottom: PreferredSize(
            child: searchWidget(model),
            preferredSize: Size(56.0, 56.0),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
              ),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => CartPage());
                Navigator.pushReplacement(context, route);
              },
            ),
          ],
          flexibleSpace: Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            ),
          ),
          title: Image.asset(
            "images/1.png",
            width: 250,
          ),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Active Listing" + " (" + numberPost.toString() + ")",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                      pinned: true, delegate: SearchBoxDelegate()),
                  StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection("ads")
                          .limit(15)
                          .orderBy("publishedDate", descending: true)
                          .snapshots(),
                      builder: (context, dataSnaphot) {
                        return !dataSnaphot.hasData
                            ? SliverToBoxAdapter(
                          child: Center(
                            child: circularProgress(),
                          ),
                        )
                            : SliverStaggeredGrid.countBuilder(
                          crossAxisCount: 1,
                          staggeredTileBuilder: (c) =>
                              StaggeredTile.fit(1),
                          itemBuilder: (context, index) {
                            ItemModel model = ItemModel.fromJson(
                                dataSnaphot.data.documents[index].data);
                            bool iffav = false;
                            if (petadoptapp.sharedPreferences
                                .getStringList("userCart")
                                .contains(model.publishedDate
                                .millisecondsSinceEpoch
                                .toString() +
                                model.uid)) {
                              iffav = true;
                            }
                            ;

                            distancefinder(model.location.longitude,
                                model.location.latitude);
                            numberPost =
                                dataSnaphot.data.documents.length;

                            return sourceInfo(
                                model, distance, iffav, context);
                          },
                          itemCount: dataSnaphot.data.documents.length,
                        );
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget searchWidget(ItemModel model) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 40.0,
      height: 60.0,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 40.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.search,
                color: Colors.blueGrey,
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _searchtextEditingController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration:
                  InputDecoration.collapsed(hintText: "Search here..."),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Are you sure you want to exit?"),
          //content: Text("Are you sure you want to exit?"),
          actions: [
            CupertinoDialogAction(
                child: Text("Yes"),
                onPressed: () => Navigator.pop(context, true)),
            CupertinoDialogAction(
                child: Text("No"),
                onPressed: () => Navigator.pop(context, false)),
          ],
        ));
  }

  Future distancefinder(double lon, double lat) async {
    if (tlat == null || tlong == null) {
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
      tlat = _locationData.latitude;
      tlong = _locationData.longitude;
    }

    double distanceInMeters = Geolocator.distanceBetween(tlat, tlong, lat, lon);
    distanceInMeters = distanceInMeters / 1000;
    setState(() {
      distance = distanceInMeters.toStringAsFixed(1);
    });
  }

  Widget sourceInfo(
      ItemModel model, String dis, bool iffav, BuildContext context,
      {Color background, removeCartFunction}) {
    if (model.category
        .toLowerCase()
        .contains(_searchtextEditingController.text.toLowerCase()) ||
        model.breed
            .toLowerCase()
            .contains(_searchtextEditingController.text.toLowerCase()) ||
        model.color
            .toLowerCase()
            .contains(_searchtextEditingController.text.toLowerCase())) {
      return InkWell(
        onTap: () {
          Route route = MaterialPageRoute(
              builder: (c) => ProductPage(itemModel: model, page: "home"));
          Navigator.pushReplacement(context, route);
        },
        splashColor: Colors.orange,
        child: Container(
          width: double.infinity,
          height: 265.0,
          // color: Colors.red[100],
          margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Stack(
            children: [
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                bottom: 15,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(165, 10, 0, 7),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 125,
                              child: Text(
                                model.breed,
                                overflow: TextOverflow.ellipsis,
                                style: kTitleStyle,
                              ),
                            ),

                            iffav == true
                                ? IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.pinkAccent,
                                ),
                                onPressed: () {
                                  favdelitem(model);
                                })
                                : IconButton(
                                icon: Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.pinkAccent,
                                ),
                                onPressed: () {
                                  favitem(model);
                                }),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child: Icon(
                                Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Category: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.category, style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Age: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.age.toString() + "Years",
                                style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.green[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Location: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(dis + " Km", style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 0,
                right: 200,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl1,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_searchtextEditingController.text.isEmpty) {
      return InkWell(
        onTap: () {
          Route route = MaterialPageRoute(
              builder: (c) => ProductPage(itemModel: model, page: "home"));
          Navigator.pushReplacement(context, route);
        },
        splashColor: Colors.orange,
        child: Container(
          width: double.infinity,
          height: 265.0,
          // color: Colors.red[100],
          margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Stack(
            children: [
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                bottom: 15,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(165, 10, 0, 7),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              model.breed,
                              overflow: TextOverflow.ellipsis,
                              style: kTitleStyle,
                            ),
                            iffav == true
                                ? IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.pinkAccent,
                                ),
                                onPressed: () {
                                  favdelitem(model);
                                })
                                : IconButton(
                                icon: Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.pinkAccent,
                                ),
                                onPressed: () {
                                  favitem(model);
                                }),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child: Icon(
                                Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Category: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.category, style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Age: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.age.toString() + "Years",
                                style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.green[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Location: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(dis + " Km", style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 200,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl1,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else
      return Container(
        child: SizedBox(
          height: 1,
        ),
      );
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

      tempCartList.add(
          tempModel.publishedDate.millisecondsSinceEpoch.toString() +
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
        });
      });
    }
  }

  Future favdelitem(ItemModel tempModel) async {
    List tempCartList = new List();

    tempCartList =
        petadoptapp.sharedPreferences.getStringList(petadoptapp.userCartList);

    tempCartList.remove(
        tempModel.publishedDate.millisecondsSinceEpoch.toString() +
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
      });
    });
  }

  Widget searchsourceInfo(
      ItemModel model, String dis, bool iffav, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      onTap: () {
        Route route = MaterialPageRoute(
            builder: (c) => ProductPage(itemModel: model, page: "home"));
        Navigator.pushReplacement(context, route);
      },
      splashColor: Colors.orange,
      child: Container(
        width: double.infinity,
        height: 210.0,
        // color: Colors.red[100],
        margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Stack(
          children: [
            Positioned(
              top: 35,
              left: 0,
              right: 0,
              bottom: 15,
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Container(
                  margin: EdgeInsets.fromLTRB(165, 10, 0, 7),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.breed,
                            overflow: TextOverflow.ellipsis,
                            style: kTitleStyle,
                          ),
                          iffav == true
                              ? IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.pinkAccent,
                              ),
                              onPressed: () {
                                favdelitem(model);
                              })
                              : IconButton(
                              icon: Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.pinkAccent,
                              ),
                              onPressed: () {
                                favitem(model);
                              }),
                        ],
                      ),
                      Text(model.category, style: kSubtitleStyle),
                      Text("${model.age} years old", style: kSubtitle2Style),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: kPrimaryColor,
                            size: 15,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            "Distance: ${dis} km",
                            style: kSubtitle2Style,
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 200,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.network(
                  model.thumbnailUrl1,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
