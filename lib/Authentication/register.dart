import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/login.dart';
import 'package:e_shop/Widgets/bezierContainer.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Widgets/secondaryContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{

  String name = "";
  String email = "";
  String password = "123456";
  File _imageFile;
  String userImageUrl1 = "";
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isLoggedIn = false;
  final TextEditingController _nametextEditingController = TextEditingController();
  final TextEditingController _emailtextEditingController = TextEditingController();
  final TextEditingController _passwordtextEditingController = TextEditingController();
  final TextEditingController _cpasswordtextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Route route = MaterialPageRoute(builder: (c) => Login());
        Navigator.pushReplacement(context, route);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

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
      onTap: (){
        uploadAndSaveImage();
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
            'Register Now',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
    );
  }

  Widget _GooglesubmitButton() {

      return Container(
        padding: EdgeInsets.symmetric(vertical: 15),
          width: MediaQuery.of(context).size.width,
          child: OutlineButton(

        splashColor: Colors.grey,
        onPressed: () {
          _login();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),

        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("images/google.png"), height: 35.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Register with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      );

  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),

        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            RaisedButton(
              onPressed: (){
                Route route = MaterialPageRoute(builder: (_) => Login());
                Navigator.pushReplacement(context, route);
              },
              color: Colors.white,
              child: Text(
                'Login',
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



  Widget _emailPasswordWidget() {
    double _screenwidth = MediaQuery.of(context).size.width, _screenWidth = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        InkWell(
          onTap: _selectAndPickImage,
          child: CircleAvatar(
            radius: _screenwidth * 0.15,
            backgroundColor: Colors.white,
            backgroundImage: _imageFile == null ? null : FileImage(_imageFile),
            child: _imageFile == null
                ? Icon(Icons.add_photo_alternate, size: _screenwidth*0.15, color: Colors.grey,)
                : null,
          ),
        ),
        CustomTextField(
          controller: _nametextEditingController,
          data: Icons.person,
          hintText: "Name",
          isObsecure: false,
        ),
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
        CustomTextField(
          controller: _cpasswordtextEditingController,
          data: Icons.keyboard,
          hintText: "Confirm Password",
          isObsecure: true,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    double _screenwidth = MediaQuery.of(context).size.width, _screenWidth = MediaQuery.of(context).size.height;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(child: Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(

              child: secondContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[


                    SizedBox(
                      height: 20,
                    ),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    SizedBox(height: 2,),
                    _GooglesubmitButton(),


                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    ),); /*SingleChildScrollView(

      child: Container(

        child: Column(
          mainAxisSize: MainAxisSize.max,

          children: [
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenwidth * 0.15,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile == null ? null : FileImage(_imageFile),
                child: _imageFile == null
                  ? Icon(Icons.add_photo_alternate, size: _screenwidth*0.15, color: Colors.grey,)
                : null,
              ),
            ),
            SizedBox(height: 8.0,),
            Form(
              key: _formKey,

              child: Column(
                 children: [
                   CustomTextField(
                     controller: _nametextEditingController,
                     data: Icons.person,
                     hintText: "Name",
                     isObsecure: false,
                   ),

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
                   CustomTextField(
                     controller: _cpasswordtextEditingController,
                     data: Icons.keyboard,
                     hintText: "Confirm Password",
                     isObsecure: true,
                   ),
                 ],
              ),
            ),
            RaisedButton(
              onPressed: () { } ,
              color: Colors.pink,
              child: Text("Sign up", style: TextStyle(color: Colors.white ),),
            ),
            SizedBox(
              height: 30.0,

            ),
            Container(
             height: 4.0,
              width: _screenwidth * 0.8,
              color: Colors.pink,

            ),

            SizedBox(
              height: 15.0,
            ),
          ],

        ),
      ),
    );*/
  }
  Future<void> _selectAndPickImage() async
  {
    File imageAvatar = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = imageAvatar;
    });

  }

  Future<void> uploadAndSaveImage() async
  {
    if(_imageFile == null)
      {
        showDialog(
          context: context,
          builder: (c)
            {
              return ErrorAlertDialog(message: "Please Select Image",);
            }

        );
      }

    else
      {
        _passwordtextEditingController.text == _cpasswordtextEditingController.text
            ? _emailtextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty && _cpasswordtextEditingController.text.isNotEmpty && _nametextEditingController.text.isNotEmpty

            ? uploadToStorage()

            : displayDialog("Please fill up the registration form")

            : displayDialog("Password do not match");
      }
  }

  displayDialog(String msg)
  {
    showDialog(
      context: context,
      builder: (c)
    {
      return ErrorAlertDialog(message: msg,);
    }
    );
  }

  uploadToStorage() async
  {
    showDialog(
      context:context,
      builder: (c)
      {
        return LoadingAlertDialog(message: "Registering, Please wait.....",);
      },
    );
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((urlImage){
      userImageUrl = urlImage;

      _registerUser();
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async
  {
    FirebaseUser firebaseUser;
    await _auth.createUserWithEmailAndPassword
      (
      email: _emailtextEditingController.text.trim(),
      password: _passwordtextEditingController.text.trim(),

    ).then((auth){
      firebaseUser = auth.user;
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
        saveUserInfoToFireStore(firebaseUser).then((value){
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder: (c) => StoreHome());
          Navigator.pushReplacement(context, route);
        });
      }
  }
  
  Future saveUserInfoToFireStore(FirebaseUser fuser) async
  {
    Firestore.instance.collection("users").document(fuser.uid).setData({
      "uid": fuser.uid,
      "email": fuser.email,
      "name": _nametextEditingController.text.trim(),
      "url": userImageUrl,
      petadoptapp.userCartList: ["garbageValue"],
    });
    await petadoptapp.sharedPreferences.setString("uid", fuser.uid);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userEmail, fuser.email);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userName, _nametextEditingController.text);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userAvatarUrl, userImageUrl);
    await petadoptapp.sharedPreferences.setStringList(petadoptapp.userCartList, ["garbageValue"]);
  }

  _login() async{
    try{
      await _googleSignIn.signIn();
      email = _googleSignIn.currentUser.email;
      userImageUrl1 = _googleSignIn.currentUser.photoUrl;
      name = _googleSignIn.currentUser.displayName;
      _nametextEditingController.text = name;
      _emailtextEditingController.text = email;
       _imageFile = await urlToFile(userImageUrl1)  ;


      setState(() {
        _isLoggedIn = true;

      });

    } catch (err){
      print(err);
    }
  }

  uploadToStorage1() async
  {
    showDialog(
      context:context,
      builder: (c)
      {
        return LoadingAlertDialog(message: "Registering, Please wait.....",);
      },
    );
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);




    _registerUser1();

  }

  _logout(){
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  FirebaseAuth _auth1 = FirebaseAuth.instance;

  void _registerUser1() async
  {
    FirebaseUser firebaseUser;
    await _auth1.createUserWithEmailAndPassword
      (
      email: email,
      password: password,

    ).then((auth){
      firebaseUser = auth.user;
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
      saveUserInfoToFireStore1(firebaseUser).then((value){
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => Login());
        Navigator.pushReplacement(context, route);
      });
    }



  }

  Future saveUserInfoToFireStore1(FirebaseUser fuser) async
  {
    Firestore.instance.collection("users").document(fuser.uid).setData({
      "uid": fuser.uid,
      "email": fuser.email,
      "name": name,
      "url": userImageUrl1,
      petadoptapp.userCartList: ["garbageValue"],
    });
    await petadoptapp.sharedPreferences.setString("uid", fuser.uid);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userEmail, fuser.email);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userName, name);
    await petadoptapp.sharedPreferences.setString(petadoptapp.userAvatarUrl, userImageUrl1);
    await petadoptapp.sharedPreferences.setStringList(petadoptapp.userCartList, ["garbageValue"]);
  }

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(imageUrl);
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }



}

