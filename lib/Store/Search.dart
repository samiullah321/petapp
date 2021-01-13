
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';

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

import 'package:e_shop/Admin/adminOrderCard.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/customAppBar.dart';
import 'cart.dart';
import 'dart:io';

class SearchService {
}

double width;
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

class SearchProduct extends StatefulWidget {

  @override
  _SearchProductState createState() => new _SearchProductState();
}



class _SearchProductState extends State<SearchProduct> {
  Future<QuerySnapshot> docList;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(child: searchWidget(), preferredSize: Size(56.0,56.0),),
          toolbarHeight: 120,
          flexibleSpace: Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,

              children: [
                IconButton(
                  alignment: Alignment.topRight,
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
            ),

          ),



          title: Image.asset(
            "images/1.png",
            width: 250,

          ),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        body: FutureBuilder<QuerySnapshot>(
          future: docList,
          builder: (context, snap){
            return snap.hasData ? ListView.builder(
              itemCount: snap.data.documents.length,
              itemBuilder: (context,index){
               ItemModel model = ItemModel.fromJson(snap.data.documents[index].data);
               return searchsourceInfo(model, distance, iffav, context);
              },
            ) :
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
                    staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      ItemModel model = ItemModel.fromJson(dataSnaphot.data.documents[index].data);
                      bool iffav = false;
                      if (petadoptapp.sharedPreferences.getStringList("userCart").contains(model.publishedDate.millisecondsSinceEpoch.toString() + model.uid)) {
                        iffav = true;
                      };



                      distancefinder(model.location.longitude, model.location.latitude);
                      return searchsourceInfo(model, distance, iffav, context);
                    },
                    itemCount: dataSnaphot.data.documents.length,
                  );
                });
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(context: context, builder: (context)=>CupertinoAlertDialog(
      title: Text("Are you sure you want to exit?"),
      //content: Text("Are you sure you want to exit?"),
      actions: [
        CupertinoDialogAction(child: Text("Yes"),onPressed: ()=>Navigator.pop(context,true)),
        CupertinoDialogAction(child: Text("No"),onPressed: ()=>Navigator.pop(context,false)),
      ],

    ) );

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

  Widget searchsourceInfo(ItemModel model, String dis, bool iffav, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      onTap: () {
        Route route =
        MaterialPageRoute(builder: (c) => ProductPage(itemModel: model, page: "home"));
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
                              icon: Icon(Icons.favorite, color: Colors.pinkAccent,),
                              onPressed: () {favdelitem(model);})
                              : IconButton(
                              icon: Icon(Icons.favorite_border_outlined, color: Colors.pinkAccent,
                              ),
                              onPressed: () {favitem(model);}),
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

  Widget searchWidget() {
    return Container(
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 40.0 ,
      height: 40.0,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width- 40.0 ,
        height: 20.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),

        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.search, color: Colors.blueGrey,),

            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: TextField(
                  onChanged: (value) {
                    startSearching(value);
                  },
                  decoration: InputDecoration.collapsed(
                      hintText: "Search here..."
                  ),


                ),
              ),
            ),
          ],
        ),
      ),


    );
  }


  Future startSearching(String query) async
  {

    docList = Firestore.instance.collection("ads").where("category", isEqualTo: query).getDocuments();


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
        });

      });
    }

//
//
// await petadoptapp.firestore
//     .collection("users")
//     .document(tempModel.uid)
//     .collection("fav")
//     .document(tempModel.publishedDate.millisecondsSinceEpoch.toString() +
//     tempModel.uid)
//     .setData({
//   "info": tempModel.info,
//   "color":  tempModel.color,
//   "age":  tempModel.age,
//   "breed":  tempModel.breed,
//   "category":  tempModel.category,
//   "location":  tempModel.location,
//   "phone":  tempModel.phone,
//   "uid": tempModel.uid,
//   "weight":  tempModel.weight,
//   "publishedDate":  tempModel.publishedDate,
//   "thumbnailUrl1":  tempModel.thumbnailUrl1,
//   "thumbnailUrl2":  tempModel.thumbnailUrl2,
//   "thumbnailUrl3":  tempModel.thumbnailUrl3,
// }).then((v) {
//   Fluttertoast.showToast(msg: "Post Favorited Successfully");
//
// } );
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
      });

    });
  }

}