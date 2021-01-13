import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
final formkey = GlobalKey<FormState>();
final scaffoldkey = GlobalKey<ScaffoldState>();
final cName = TextEditingController();
final cPhoneNumber = TextEditingController();
final cFlateNumber = TextEditingController();
final cCity = TextEditingController();
final cState = TextEditingController();
final cPinCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: ()
          {
             if(formkey.currentState.validate())
               {
                 final model = AddressModel(
                   name: cName.text.trim(),
                   state: cState.text.trim(),
                   pincode: cPinCode.text,
                  phoneNumber: cPhoneNumber.text,
                   flatNumber: cFlateNumber.text,
                   city: cCity.text.trim(),



                 ).toJson();
                 //add to firestore
                 petadoptapp.firestore.collection(petadoptapp.collectionUser)
                 .document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID))
                 .collection(petadoptapp.subCollectionAddress)
                 .document(DateTime.now().millisecondsSinceEpoch.toString())
                 .setData(model)
                     .then((value) {
                    final snack = SnackBar(content:Text("New Address Added Sucessfully.", style: TextStyle(color: Colors.black),));
                    FocusScope.of(context).requestFocus(FocusNode());
                    formkey.currentState.reset();
                 });
               }
          },
          label: Text("Done"),
          backgroundColor: Colors.pink,
          icon: Icon(Icons.check),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Add New Address",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
              Form(
                key: formkey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Name",
                      controller: cName,

                    ),
                    MyTextField(

                      hint: "Phone Number",
                      controller: cPhoneNumber,

                    ),

                    MyTextField(

                      hint: "Flat Number",
                      controller: cFlateNumber,

                    ),

                    MyTextField(

                      hint: "City",
                      controller: cCity,

                    ),

                    MyTextField(

                      hint: "State",
                      controller: cState,
                    ),

                    MyTextField(

                      hint: "PIN",
                      controller: cPinCode,
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {

  final String hint;
  final TextEditingController controller;

  MyTextField({
    Key key,
    this.hint,
    this.controller,
}): super (key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
   padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val.isEmpty ? "Field can not be empty!" : null,
      ),
    );
  }
}
