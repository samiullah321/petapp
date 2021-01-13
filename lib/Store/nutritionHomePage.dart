import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';

import 'package:e_shop/Models/nutrition.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/nutrition_page.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Store/vet_page.dart';
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
const kPrimaryColor = Color(0xFF27608D);
const kTextColor = Color(0xFF746F67);
const kText2Color = Colors.black45;
String distance = "fetching";
double tlat;
double tlong;


const kTitleStyle = TextStyle(
  fontSize: 16.0,
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



class foodHome extends StatefulWidget {
  @override
  _foodHomeState createState() => _foodHomeState();
}

class _foodHomeState extends State<foodHome> {
  startSearching()
  {


    setState(() {
      print(1);
    });


  }
  TextEditingController _searchtextEditingController = TextEditingController();
  nutritionModel model;

  Future<QuerySnapshot> docList;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return WillPopScope(onWillPop: _onBackPressed, child:SafeArea(

      child:SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 150,
            bottom: PreferredSize(child: searchWidget(), preferredSize: Size(56.0,56.0),),
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
          body: CustomScrollView(

            slivers: [
              SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),

              StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("nutrition")

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
                        nutritionModel model = nutritionModel.fromJson(
                            dataSnaphot.data.documents[index].data);





                        return foodsourceInfo(model, context);
                      },
                      itemCount: dataSnaphot.data.documents.length,
                    );
                  }),



            ],
          ),

        ),
      ),),

    );

  }

  Widget searchWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 40.0 ,
      height: 60.0,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width- 40.0 ,
        height: 60.0,
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
                  controller: _searchtextEditingController,
                  onChanged: (value) {
                    startSearching();
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
  Widget foodsourceInfo(nutritionModel model, BuildContext context,
      {Color background, removeCartFunction}) {

    if(model.price.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) || model.brand.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) || model.name.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) )
    {
      return InkWell(
        onTap: () {
          Route route =
          MaterialPageRoute(
              builder: (c) => foodPage(vetmodel: model));
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
                              model.name,
                              overflow: TextOverflow.ellipsis,
                              style: kTitleStyle,

                            ),
                          ],
                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child:
                              Icon(Icons.money,
                                color: Colors.green[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Price: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text("Rs." + model.price , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child:
                              Icon(Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Category: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.category , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child:
                              Icon(Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 3,),
                            Text("Pet Age: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.age + "Years" , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber[50],
                              ),
                              child:
                              Icon(Icons.local_shipping_outlined,
                                color: Colors.amber[400],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5.0),

                            Text("Shipped By: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.ShippedBy , style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(height: 5.0),
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
                    model.ImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    }
    else if(_searchtextEditingController.text.isEmpty){
      return InkWell(
        onTap: () {
          Route route =
          MaterialPageRoute(
              builder: (c) => foodPage(vetmodel: model));
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
                              model.name,
                              overflow: TextOverflow.ellipsis,
                              style: kTitleStyle,

                            ),
                          ],
                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child:
                              Icon(Icons.money,
                                color: Colors.green[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Price: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text("Rs." + model.price , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child:
                              Icon(Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Category: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.category , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 4,),
                        Row(
                          children:[
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child:
                              Icon(Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 3,),
                            Text("Pet Age: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.age + "Years" , style: kSubtitle2Style),
                          ],

                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber[50],
                              ),
                              child:
                              Icon(Icons.local_shipping_outlined,
                                color: Colors.amber[400],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5.0),

                            Text("Shipped By: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.ShippedBy , style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(height: 5.0),
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
                    model.ImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    else
      return Container(
        child: SizedBox(
          height: 1,
        ),
      );
  }







  Widget searchsourceInfo(nutritionModel model, String dis, bool iffav, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      onTap: () {
        Route route =
        MaterialPageRoute(builder: (c) => foodPage(vetmodel: model));
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
                            model.name,
                            overflow: TextOverflow.ellipsis,
                            style: kTitleStyle,
                          ),

                        ],
                      ),
                      Text(model.price, style: kSubtitleStyle),
                      Text("${model.category} years old", style: kSubtitle2Style),
                      Row(
                        children: [

                          SizedBox(width: 5.0),

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
                  model.ImageUrl,
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




