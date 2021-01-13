import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Authentication/register.dart';
import 'package:e_shop/Widgets/bezierContainer.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';


class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _LoginState createState() => _LoginState();
}





class _LoginState extends State<Login>
{

  bool _isLoggedIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final TextEditingController _emailtextEditingController = TextEditingController();
  final TextEditingController _passwordtextEditingController = TextEditingController();
  @override

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        _emailtextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty
            ? loginUser()
            : showDialog(
            context: context,
            builder: (c)
            {
              return ErrorAlertDialog(message: "Please Enter Email and Password",);
            }
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );

    Container(

      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)])),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );/*RaisedButton(
      onPressed: (){
        _emailtextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty
            ? loginUser()
            : showDialog(
            context: context,
            builder: (c)
            {
              return ErrorAlertDialog(message: "Please Enter Email and Password",);
            }
        );
      },
      color: Colors.white,

      child: Text("Login", style: TextStyle(color: Colors.pink ),),*/
    /**/

  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }



  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Register()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 5,
            ),
            RaisedButton(
              onPressed: (){
                Route route = MaterialPageRoute(builder: (_) => Register());
                Navigator.pushReplacement(context, route);
              },
              color: Colors.white,
              child: Text(
                'Register',
                style: TextStyle(
                    color: Color(0xfff79c4f),
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return

      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'B',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10),
            ),
            children: [
              TextSpan(
                text: 'U',
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
              TextSpan(
                text: 'DDY',
                style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
              ),
            ]),
      );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        CustomTextField(
          controller: _emailtextEditingController,
          data: Icons.email,
          hintText: "Email",
          isObsecure: false,
        ),
        CustomTextField(
          controller: _passwordtextEditingController,
          data: Icons.keyboard,
          hintText: "Password",
          isObsecure: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: -height * .15,
                      right: -MediaQuery.of(context).size.width * .4,
                      child: BezierContainer()),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 100,),


                        _title(),
                        SizedBox(height: 20),
                        _emailPasswordWidget(),
                        SizedBox(height: 20),
                        _submitButton(),
                        SizedBox(height: 30,),
                        _divider(),
                        SizedBox(height: 10,),


                        SizedBox(height: height * .055),
                        _createAccountLabel(),
                      ],
                    ),

                  ),

                ],
              ),
            ),
          ),

        )
    );
  }

  /*Widget build(BuildContext context) {*/
  /* double _screenwidth = MediaQuery.of(context).size.width, _screenWidth = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              *//*child: Image.asset(
                "images/login.png",
                height: 240.0,
                width: 240.0,
              ),*//*
            ),

            Form(
              key: _formKey,

              child: Column(
                children: [


                  CustomTextField(
                    controller: _emailtextEditingController,
                    data: Icons.email,
                    hintText: "Email",
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
                _emailtextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty
                    ? loginUser()
                    : showDialog(
                  context: context,
                  builder: (c)
                    {
                      return ErrorAlertDialog(message: "Please Enter Email and Password",);
                    }
                );
              } ,
              color: Colors.white,
              child: Text("Login", style: TextStyle(color: Colors.pink ),),
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
              height: 15.0,
            ),
            FlatButton.icon(
              onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminSignInPage())),
              icon:(Icon(Icons.nature_people,color: Colors.pink,)) ,
              label: Text(
                "I am Admin",
                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }*/
  FirebaseAuth _auth = FirebaseAuth.instance;
  void loginUser() async
  {
    showDialog(
        context:context,
        builder: (c)
        {
          return LoadingAlertDialog(message: "Authenticating,Please wait....",);
        }
    );

    FirebaseUser firebaseUser;
    await _auth.signInWithEmailAndPassword(
      email: _emailtextEditingController.text.trim(),
      password: _passwordtextEditingController.text.trim(),
    ).then((authUser)
    {
      firebaseUser = authUser.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorAlertDialog(message: error.message.toString(),);

          }
      );
    });
    if(firebaseUser != null)
    {
      readData(firebaseUser).then((s){
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }

  }

  Future readData(FirebaseUser fuser) async
  {
    Firestore.instance.collection("users").document(fuser.uid).get().then((dataSnapshot)
    async {
      await petadoptapp.sharedPreferences.setString("uid", dataSnapshot.data[petadoptapp.userUID]);
      await petadoptapp.sharedPreferences.setString(petadoptapp.userEmail, dataSnapshot.data[petadoptapp.userEmail]);
      await petadoptapp.sharedPreferences.setString(petadoptapp.userName, dataSnapshot.data[petadoptapp.userName]);
      await petadoptapp.sharedPreferences.setString(petadoptapp.userAvatarUrl, dataSnapshot.data[petadoptapp.userAvatarUrl]);
      List<String> cartList = dataSnapshot.data[petadoptapp.userCartList].cast<String>();
      await petadoptapp.sharedPreferences.setStringList(petadoptapp.userCartList,cartList);
    });
  }

  _checkLoginGoogle(bool loginState)
  {

  }










}
