import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';

import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Models/vetModel.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Store/storehome.dart';
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
int numberPost=0;
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



class VetHome extends StatefulWidget {
  @override
  _VetHomeState createState() => _VetHomeState();
}

class _VetHomeState extends State<VetHome> {








  TextEditingController _searchtextEditingController = TextEditingController();
  vetModel model;

  Future<QuerySnapshot> docList;
  @override
  Widget build(BuildContext context) {
    setState(() {
      numberPost=numberPost;
    });
    width = MediaQuery.of(context).size.width;
    return WillPopScope(onWillPop: _onBackPressed,


        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 150,
            bottom: PreferredSize(child: searchWidget(model), preferredSize: Size(56.0,56.0),),
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
              SizedBox(height: 20,),
              Align(
                alignment: Alignment.topLeft,

                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    Text("Vet Available" + " (" + numberPost.toString() + ")",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.grey.shade700,),),
                  ],
                ),
              ),


              SizedBox(height: 10,),

              Expanded(
                  child: CustomScrollView(

                    slivers: [
                      SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),

                      StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection("vet")

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
                                vetModel model = vetModel.fromJson(
                                    dataSnaphot.data.documents[index].data);




                                distancefinder(model.location.longitude,
                                    model.location.latitude);
                                numberPost= dataSnaphot.data.documents.length;
                                return vetsourceInfo(model, distance, context);
                              },
                              itemCount: dataSnaphot.data.documents.length,
                            );
                          }),



                    ],
                  ),
              ),
            ],
          ),

        ),


    );

  }

  Widget searchWidget(vetModel model) {
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
    Route route = MaterialPageRoute(builder: (c) => StoreHome());
    Navigator.pushReplacement(context, route);

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
  Widget vetsourceInfo(vetModel model, String dis, BuildContext context,
      {Color background, removeCartFunction}) {


    if(model.hospital.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) || model.name.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()))
    {

      return InkWell(
        onTap: () {
          Route route =
          MaterialPageRoute(
              builder: (c) => VetPage(model: model));
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
                            Container(width: 170,
                              child: Text(
                                  model.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kTitleStyle),
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
                                color: Colors.amber.shade50,
                              ),
                              child:
                              Icon(Icons.phone,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),

                              Text("Phone: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,
                             ),
                            ),
                            Container(width: 90,
                              child:

                  Text(model.phone  ,maxLines: 1,
                                overflow: TextOverflow.ellipsis, style: kSubtitle2Style),),
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
                                color: Colors.red[200],
                              ),
                              child:
                              Icon(Icons.local_hospital,
                                color: Colors.white,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Hospital: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),

                            Container(width: 80,
                              child:

                              Text(model.hospital  ,maxLines: 1,
                                  overflow: TextOverflow.ellipsis, style: kSubtitle2Style),),
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
                            SizedBox(width: 5,),
                            Text("Days: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.workingDays , style: kSubtitle2Style),
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
                              Icon(Icons.access_time,
                                color: Colors.green[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Timings: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.timings , style: kSubtitle2Style),
                          ],

                        ),





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
                top: 25,
                left: 0,
                right: 200,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl,
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
              builder: (c) => VetPage(model: model));
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
                            Container(width: 170,
                              child: Text(
                                  model.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kTitleStyle),
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
                                color: Colors.amber.shade50,
                              ),
                              child:
                              Icon(Icons.phone,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Phone: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Container(width: 90,
                              child:

                              Text(model.phone  ,maxLines: 1,
                                  overflow: TextOverflow.ellipsis, style: kSubtitle2Style),),
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
                                color: Colors.red[200],
                              ),
                              child:
                              Icon(Icons.local_hospital,
                                color: Colors.white,
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Hospital: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Container(width: 80,
                              child:

                              Text(model.hospital  ,maxLines: 1,
                                  overflow: TextOverflow.ellipsis, style: kSubtitle2Style),),
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
                            SizedBox(width: 5,),
                            Text("Days: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.workingDays , style: kSubtitle2Style),
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
                              Icon(Icons.access_time,
                                color: Colors.green[900],
                                size: 16,
                              ),


                            ),
                            SizedBox(width: 5,),
                            Text("Timings: ", style: TextStyle(fontWeight: FontWeight.w600, color: kText2Color,),
                            ),
                            Text(model.timings , style: kSubtitle2Style),
                          ],

                        ),





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
                top: 25,
                left: 0,
                right: 200,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl,
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







  Widget searchsourceInfo(vetModel model, String dis, bool iffav, BuildContext context,
      {Color background, removeCartFunction}) {
    return InkWell(
      onTap: () {
        Route route =
        MaterialPageRoute(builder: (c) => VetPage(model: model));
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
                      Text(model.phone, style: kSubtitleStyle),
                      Text("${model.email} years old", style: kSubtitle2Style),
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
                  model.thumbnailUrl,
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




