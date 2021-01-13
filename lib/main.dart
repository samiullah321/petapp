import  'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Authentication/login.dart';
import 'package:e_shop/Authentication/register.dart';
import 'package:e_shop/Authentication/welcomepage.dart';
import 'package:e_shop/Counters/ItemQuantity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:lottie/lottie.dart' as lot;

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/auth.dart';
import 'Authentication/authenication.dart';
import 'package:e_shop/Config/config.dart';

import 'Config/palette.dart';
import 'Counters/cartitemcounter.dart';
import 'Counters/changeAddresss.dart';
import 'Counters/totalMoney.dart';
import 'Store/storehome.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  petadoptapp.auth = FirebaseAuth.instance;
  petadoptapp.sharedPreferences = await SharedPreferences.getInstance();
  petadoptapp.firestore = Firestore.instance;


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LitAuthInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pet Adoption',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.muliTextTheme(),
          accentColor: Palette.darkOrange,
          appBarTheme: const AppBarTheme(
            brightness: Brightness.dark,
            color: Palette.darkBlue,
          ),
        ),

        // home: const LitAuthState(
        //   authenticated: Home(),
        //   unauthenticated: Unauthenticated(),
        // ),
        home: SplashScreen(),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (c) => CartItemCounter()),
//         ChangeNotifierProvider(create: (c) => ItemQuantity()),
//         ChangeNotifierProvider(create: (c) => AddressChanger()),
//         ChangeNotifierProvider(create: (c) => TotalAmount()),
//       ],
//       child: MaterialApp(
//           title: 'e-Shop',
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             primaryColor: Colors.black,
//           ),
//           home: SplashScreen()),
//     );
//   }
// }
//
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displaySplash();
  }

  displaySplash() {
    Timer(Duration(seconds: 2), () async {
      if (await petadoptapp.auth.currentUser() != null) {
        Route route = MaterialPageRoute(builder: (_) => StoreHome());
        Navigator.pushReplacement(context, route);
      } else {
        Route route = MaterialPageRoute(builder: (_) => AuthScreen());
        Navigator.pushReplacement(context, route);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: new BoxDecoration(color: Colors.white70),
        margin: const EdgeInsets.only(top: 70.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              lot.Lottie.asset("assets/lottie/dog.json"),
              Text(
                "World's larges Online shop",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }


}

