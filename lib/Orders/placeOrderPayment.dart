import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class PaymentPage extends StatefulWidget {
  final String addressId;
  final double totalAmount;

  PaymentPage({Key key, this.addressId, this.totalAmount,}) : super(key: key);
  @override
  _PaymentPageState createState() => _PaymentPageState();
}




class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.pink, Colors.lightGreenAccent ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0,0.0),
            stops: [0.0,1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(0.8),
                child: Image.asset("images/cash.png"),

              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                color: Colors.pinkAccent,
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.deepOrange,
                onPressed: ()=>addOrderDetails(),
                child: Text("Place Order", style: TextStyle(fontSize: 30.0),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future writeOrderDetails(Map<String,dynamic> data) async
   {
        await petadoptapp.firestore.collection(petadoptapp.collectionUser).document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID))
            .collection(petadoptapp.collectionOrders)
            .document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID) + data['orderTime']).setData(data);
  }

  Future writeOrderDetailsForAdmin(Map<String,dynamic> data) async
  {
    await petadoptapp.firestore
        .collection(petadoptapp.collectionOrders)
        .document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID) + data['orderTime']).setData(data);
  }

  addOrderDetails()
  {
    writeOrderDetails({
      petadoptapp.userName: petadoptapp.sharedPreferences.getString(petadoptapp.userName),
      petadoptapp.totalAmount:widget.totalAmount,
      "orderBy":petadoptapp.sharedPreferences.getString(petadoptapp.userUID),


      petadoptapp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      petadoptapp.isSuccess:true,
    });
    writeOrderDetailsForAdmin({

        petadoptapp.addressID: widget.addressId,
        petadoptapp.totalAmount:widget.totalAmount,
        "orderBy":petadoptapp.sharedPreferences.getString(petadoptapp.userUID),
        petadoptapp.productID:petadoptapp.sharedPreferences.getStringList(petadoptapp.userCartList),
        petadoptapp.paymentDetails: "Cash On Delivery",
        petadoptapp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
        petadoptapp.isSuccess:true,
    }).whenComplete(() => {
      emptyCartNow()
    });
        }

        emptyCartNow()
        {
          petadoptapp.sharedPreferences.setStringList(petadoptapp.userCartList, ["garbageValue"]);
          List tempList = petadoptapp.sharedPreferences.getStringList(petadoptapp.userCartList);
          Firestore.instance.collection("users").document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID)).updateData({

            petadoptapp.userCartList: tempList,
          }).then((value){
            petadoptapp.sharedPreferences.setStringList(petadoptapp.userCartList, tempList);
            Provider.of<CartItemCounter>(context,listen: false).displayResult();
          });
          Fluttertoast.showToast(msg: "Congratulation, your order has been placed successfully");
          Route route = MaterialPageRoute(builder: (c) => StoreHome());
          Navigator.pushReplacement(context, route);

        }
  }

