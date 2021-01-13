import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0,0.0),
              stops: [0.0,1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: Text("Pet Shop",
          style: TextStyle(fontSize: 55.0,color: Colors.white, fontFamily: "Signatra"),),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordtextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    double _screenwidth = MediaQuery.of(context).size.width, _screenWidth = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/admin.png",
                height: 240.0,
                width: 240.0,
              ),
            ),

            Form(
              key: _formKey,

              child: Column(
                children: [


                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "ID",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordtextEditingController,
                    data: Icons.keyboard,
                    hintText: "Password",
                    isObsecure: true,
                  ),

                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                    context: context,
                    builder: (c)
                    {
                      return ErrorAlertDialog(message: "Please Enter Email and Password",);
                    }
                );
              } ,
              color: Colors.pink,
              child: Text("Login", style: TextStyle(color: Colors.white ),),
            ),
            SizedBox(
              height: 50.0,

            ),
            Container(
              height: 4.0,
              width: _screenwidth * 0.8,
              color: Colors.pink,

            ),

            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AuthenticScreen())),
              icon:(Icon(Icons.nature_people,color: Colors.pink,)) ,
              label: Text(
                "I not an Admin",
                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }

  loginAdmin()
  {
     Firestore.instance.collection("admins").getDocuments().then((snapshot){
       snapshot.documents.forEach((result) {
         if(result.data["id"] != _adminIDTextEditingController.text.trim())
         {
                Scaffold.of(context).showSnackBar(SnackBar(content:Text("Your id is not correct"), ));
         }

        else if(result.data["password"] != _passwordtextEditingController.text.trim())
           {
             Scaffold.of(context).showSnackBar(SnackBar(content:Text("Your password is not correct"), ));
           }

        else
          {
            Scaffold.of(context).showSnackBar(SnackBar(content:Text("Welcome Dear Admin" + result.data["name"]), ));
            setState(() {
              _adminIDTextEditingController.text = "";
              _passwordtextEditingController.text = "";
              Route route = MaterialPageRoute(builder: (c) => UploadPage());
              Navigator.pushReplacement(context, route);
            });
          }
       });
     });
  }
}
