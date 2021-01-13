import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/auth.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Authentication/login.dart';
import 'package:e_shop/Authentication/welcomepage.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Address/addAddress.dart';
import 'package:e_shop/Models/chatroom.dart';
import 'package:e_shop/Models/profileeditpage.dart';
import 'package:e_shop/Store/Search.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Orders/myOrders.dart';
import 'package:e_shop/Store/nutritionHomePage.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Store/vethomepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: new BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)]),
        ),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              decoration: new BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xfffbb448), Color(0xfff7892b)]),
              ),
              child: Column(
                children: [
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(80.0)),
                    elevation: 8.0,
                    child: Container(
                      height: 100.0,
                      width: 100.0,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          petadoptapp.sharedPreferences
                              .getString(petadoptapp.userAvatarUrl),
                        ),
                      ),
                    ),
                  ),
                 
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(

                    child: Text(
                      petadoptapp.sharedPreferences
                          .getString(petadoptapp.userName),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontFamily: "Sigmatra"),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),


                ],
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Container(
              padding: EdgeInsets.only(top: 1.0),
              decoration: new BoxDecoration(),
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.home,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Home",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => StoreHome());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.reorder,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "My Post",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => UploadPage());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Favourite",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => CartPage());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_outlined,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Chat Room",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => ChatHome());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.security,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Vets",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => VetHome());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.fastfood,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Pet Nutrition",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Route route =
                            MaterialPageRoute(builder: (c) => foodHome());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {

                          Route route = MaterialPageRoute(builder: (_) => ProfilePage());
                          Navigator.pushReplacement(context, route);

                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Divider(
                      height: 10.0,
                      color: Colors.grey.shade300,
                      thickness: 3.0,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Colors.grey[290],
                      ),
                      title: Text(
                        "Log Out",
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        petadoptapp.auth.signOut().then((c) {
                          Route route =
                              MaterialPageRoute(builder: (_) => AuthScreen());
                          Navigator.pushReplacement(context, route);
                        });
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: 20,
                    child: ListTile(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
