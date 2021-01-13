import 'dart:core';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/conversation_screen.dart';
import 'package:e_shop/Admin/uploadItems.dart';

import 'package:e_shop/Models/chatroommodel.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
// List <String> posterdd = new List(15);
// String a =posterdd[0];

class Poster {
  String posteruid ;
  String postername  ;
  String posterurl  ;
  String pemail  ;
  String message ;
  String posternumber = "Loading...";
  Timestamp timenow = Timestamp.fromDate(DateTime.now() );


  Poster(   this.postername,
      this.posterurl ,
      this.pemail,
      this.message ,
      this.posternumber,

      this.timenow  ,


      );


}


List<Poster> posteruser = <Poster>[
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
  Poster("Loading..." , "Loading...","Loading...","Loading...","Loading...",Timestamp.fromDate(DateTime.now() )),
] ;






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



class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {


  TextEditingController _searchtextEditingController = TextEditingController();
  ChatModel model;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return WillPopScope(onWillPop: _onBackPressed,
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
          body: Container(


            child:




            CustomScrollView(

              slivers: [
                SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),

                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("chatroom")
                        .limit(15)

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
                          ChatModel model = ChatModel.fromJson(dataSnaphot.data.documents[index].data);



                          // print(index);
                          // print(model.users1);
                          // print(model.users2);


                          return sourceInfo(model,  context, index);
                        },
                        itemCount: dataSnaphot.data.documents.length,
                      );
                    }),



              ],


            ),

          ),
        ),






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
                    setState(() {

                    });
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



  Widget sourceInfo  (ChatModel model,  BuildContext context, int index,
      {Color background, removeCartFunction}) {

    datagetter(model, index);
    //
    // print(index);
    //
    // print(posteruser[index].postername);
    // print(posteruser[index].posterurl);
    // print(posteruser[index].pemail);
    if((model.users1.contains(petadoptapp.sharedPreferences.getString(petadoptapp.userUID)) || model.users2.contains(petadoptapp.sharedPreferences.getString(petadoptapp.userUID))) && posteruser[index].message != "Loading..." )
    {
      if(posteruser[index].postername.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()))
      {return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)
          => ConversationScreen(chatroomid: model.chatroomid,userid: petadoptapp.sharedPreferences.getString(petadoptapp.userUID),poster : posteruser[index].posteruid , phone : posteruser[index].posternumber, posteremail: posteruser[index].pemail, posterurl:posteruser[index].posterurl),
          ));
        },
        child: Container(
          padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(posteruser[index].posterurl),
                      maxRadius: 30,
                    ),
                    SizedBox(width: 16,),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(posteruser[index].postername),
                            SizedBox(height: 6,),
                            Text(posteruser[index].message,style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(DateFormat.MMMEd().add_jm().format(posteruser[index].timenow.toDate()),style: TextStyle(fontSize: 12,color: Colors.black54),),
            ],
          ),
        ),
      );}
      else if(_searchtextEditingController.text.isEmpty)
      {return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)
          => ConversationScreen(chatroomid: model.chatroomid,userid: petadoptapp.sharedPreferences.getString(petadoptapp.userUID),poster : posteruser[index].posteruid , phone : posteruser[index].posternumber, posteremail: posteruser[index].pemail, posterurl:posteruser[index].posterurl),
          ));
        },
        child: Container(
          padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(posteruser[index].posterurl),
                      maxRadius: 30,
                    ),
                    SizedBox(width: 16,),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(posteruser[index].postername),
                            SizedBox(height: 6,),
                            Text(posteruser[index].message,style: TextStyle(fontSize: 14,color: Colors.grey.shade500),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(DateFormat.MMMEd().add_jm().format(posteruser[index].timenow.toDate()),style: TextStyle(fontSize: 12,color: Colors.black54),),
            ],
          ),
        ),
      );}
      else if(!posteruser[index].postername.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) && _searchtextEditingController.text.isNotEmpty )
      {return Container(child: SizedBox(height: 10,),);}


    }
    else {
      return Container(child: SizedBox(height: 10,),);

    }

  }

  Future datagetter(ChatModel model, int index) async{
    if(model.users1.contains(petadoptapp.sharedPreferences.getString(petadoptapp.userUID)))
    {
      posteruser[index].posteruid=model.users2;
    }
    if(model.users2.contains(petadoptapp.sharedPreferences.getString(petadoptapp.userUID)))
    {
      posteruser[index].posteruid=model.users1;
    }


    DocumentSnapshot variable = await petadoptapp.firestore.collection("users").document(posteruser[index].posteruid).get();
    posteruser[index].postername=variable.data['name'];
    posteruser[index].posterurl=variable.data['url'];
    posteruser[index].pemail=variable.data['email'];


    QuerySnapshot variable2 = await Firestore.instance.collection("chatroom").document(model.chatroomid).collection("chats").limit(1)
        .orderBy("time", descending: true).getDocuments();
    posteruser[index].message = variable2.documents[0].data["message"];
    posteruser[index].timenow =  variable2.documents[0].data["time"];
    QuerySnapshot variable3 = await Firestore.instance.collection("users").document(posteruser[index].posteruid).collection("post").limit(1).getDocuments();
    if(variable3.documents.isNotEmpty)
    {posteruser[index].posternumber=variable3.documents[0].data["phone"];
    }
    else{
      posteruser[index].posternumber=null;
    }





    setState(() {


    });



  }









}






