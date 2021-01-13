import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/conversation_screen.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Models/nutrition.dart';
import 'package:e_shop/Models/nutrition.dart';
import 'package:e_shop/Store/nutritionHomePage.dart';
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

bool favorite = true;
String loc = "fetching";
String distance = "";
bool iffav = false;
String poster="Loading...";
String posterurl="https://media2.govtech.com/images/940*712/SHUTTERSTOCK_LOADING_SYMBOL_BROADBAND_INTERNET_SPEED.jpg";
String defPoster2="https://www.freevector.com/uploads/vector/preview/10122/FreeVector-Whiskas.jpg";
String pemail;


class foodPage extends StatefulWidget {

   nutritionModel vetmodel;

  foodPage({this.vetmodel});

  @override
  foodDetail createState() => foodDetail();
}

class foodDetail extends State<foodPage> {
  initState() {

    super.initState();




  }

  @override
  Widget build(BuildContext context) {



    return WillPopScope(onWillPop: (){

      Route route = MaterialPageRoute(builder: (c) => CartPage());
      Navigator.pushReplacement(context, route);

    } ,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {


              Route route = MaterialPageRoute(builder: (c) => foodHome());
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
                    tag: widget.vetmodel.ImageUrl,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(widget.vetmodel.ImageUrl),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                    ),
                    //
                  ),
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
                                widget.vetmodel.name,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(
                                width: 8,

                              ),

                            ]),
                            SizedBox(height: 5,),
                            Row(
                              children: [

                                SizedBox(
                                  width: 4,

                                ),
                                Text(
                                  widget.vetmodel.brand,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),



                              ],
                            ),

                            SizedBox(height: 5,),
                            Row(
                              children: [ Icon(
                                Icons.local_shipping_sharp,
                                color: Colors.grey[600],
                                size: 18,
                              ),

                                SizedBox(
                                  width: 4,

                                ),

                                Text(
                                  widget.vetmodel.ShippedBy,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [ Icon(
                                Icons.category,
                                color: Colors.grey[600],
                                size: 20,
                              ),

                                SizedBox(
                                  width: 4,

                                ),

                                Text(
                                  widget.vetmodel.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                          ],

                        ),

                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8,right: 8,left: 8),
                    child: Row(
                      children: [
                        buildPetFeature(
                            widget.vetmodel.price.toString() + "/=", "Price"),
                        buildPetFeature(widget.vetmodel.weight, "Weight"),
                        buildPetFeature(
                            widget.vetmodel.age + "years", "Age"),
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
                      widget.vetmodel.description,
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
                                    defPoster2,
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
                                  widget.vetmodel.brand,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

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






}
