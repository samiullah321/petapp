
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/Config/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
TextEditingController _nameEditingController = TextEditingController();
TextEditingController _cpassEditingController = TextEditingController();
TextEditingController _npassEditingController = TextEditingController();
TextEditingController _emailEditingController = TextEditingController();
bool showPassword = false;

File imagefile;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}



class _ProfilePageState extends State<ProfilePage> {
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Are you sure you want to exit?"),
          //content: Text("Are you sure you want to exit?"),
          actions: [
            CupertinoDialogAction(
                child: Text("Yes"),
                onPressed: () =>
                {
                  Navigator.pop(context, false),
                  clearform(),
                }),
            CupertinoDialogAction(
                child: Text("No"),
                onPressed: () => Navigator.pop(context, false)),
          ],
        ));
  }
  @override

  Widget build(BuildContext context) {
      return WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(

              elevation: 0.0,
              flexibleSpace: Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xfffbb448), Color(0xfff7892b)]),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _onBackPressed();

                },
              ),
              centerTitle: true,

            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  painter: HeaderCurvedContainer(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _profileText(),
                    _circleAvatar(),
                    _textFormFieldCalling()
                  ],
                ),
              ],
            ),
          ));

    }

  Widget _profileText() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 35.0,
          letterSpacing: 1.5,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _circleAvatar() {
    return  Center(
      child: Stack(
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 4,
                    color: Theme.of(context).scaffoldBackgroundColor),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 10))
                ],
                shape: BoxShape.circle,
                image: imagefile != null ? DecorationImage(
                  image: FileImage(imagefile),
                  fit: BoxFit.cover,
                ):DecorationImage(
                    fit: BoxFit.cover,
                    image:  NetworkImage(
                        petadoptapp.sharedPreferences.getString(petadoptapp.userAvatarUrl),
                    )
                )),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 4,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  color: Colors.green,
                ),
                child: IconButton(
                  onPressed: () => { _getImage()},
                  icon: Icon(Icons.edit),
                  color: Colors.white,
                  iconSize: 18,
                ),
              )),
        ],
      ),
    );
  }

  Widget _textFormFieldCalling() {
    return Container(
      height: 390,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildTextField("Full Name", petadoptapp.sharedPreferences.getString(petadoptapp.userName), false,_nameEditingController),
          buildTextField("Email", petadoptapp.sharedPreferences.getString(petadoptapp.userEmail), false,_emailEditingController),
          buildTextField("Current Password", "********", true,_cpassEditingController),
          buildTextField("New Password", "", true,_npassEditingController),

          Container(
            height: 55,
            width: double.infinity,

            child: RaisedButton(
              color: Colors.orange,
              child: Center(
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                  ),
                ),
              ),
              onPressed: () {
                update();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField, TextEditingController textcontroller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: textcontroller,
        obscureText: isPasswordTextField ? showPassword : false,
        style:  TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
              icon: Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
              ),
            )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,

            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: Colors.black,
            )),
      ),
    );
  }

  Future update() async {
    String pass;
    String image;
    String name;
    String email;
    if((_cpassEditingController.text.isNotEmpty && _npassEditingController.text.isNotEmpty)||imagefile != null||_nameEditingController.text.isNotEmpty||(_cpassEditingController.text.isNotEmpty && _emailEditingController.text.isNotEmpty))
      {
        showDialog(
          context:context,
          builder: (c)
          {
            return LoadingAlertDialog(message: "Updating,Please wait....",);
          },);
      }

    if(_cpassEditingController.text.isNotEmpty || _npassEditingController.text.isNotEmpty)
      {
        print("here");
        if(_cpassEditingController.text.isNotEmpty && _npassEditingController.text.isNotEmpty)
          {
            FirebaseAuth _auth = FirebaseAuth.instance;
            FirebaseUser firebaseUser;
            await _auth.signInWithEmailAndPassword(
              email:  petadoptapp.sharedPreferences.getString(petadoptapp.userEmail),
              password: _cpassEditingController.text.toString(),
            ).then((authUser)
            {
              firebaseUser = authUser.user;
            }).catchError((error){

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

              firebaseUser.updatePassword(_npassEditingController.text.toString());
              pass="Password";
            }
          }
        else
          {
            Fluttertoast.showToast(msg: "Both Current and New Email Or New Password is required");
          }

      }

    if(_cpassEditingController.text.isNotEmpty || _emailEditingController.text.isNotEmpty)
    {
      print(petadoptapp.sharedPreferences.getString(petadoptapp.userEmail));
      print(_cpassEditingController.text);
      print(_emailEditingController.text);
      if(_cpassEditingController.text.isNotEmpty && _emailEditingController.text.isNotEmpty)
      {
        FirebaseAuth _auth = FirebaseAuth.instance;
        FirebaseUser firebaseUser;
        await _auth.signInWithEmailAndPassword(
          email:  petadoptapp.sharedPreferences.getString(petadoptapp.userEmail),
          password: _cpassEditingController.text.toString(),
        ).then((authUser)
        {
          firebaseUser = authUser.user;
        }).catchError((error){

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
          print(firebaseUser);
          await firebaseUser.updateEmail(_emailEditingController.text.toString());
          final itemsRef = Firestore.instance.collection("users");
          await itemsRef.document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID).toString())
              .updateData({
            "email" : _emailEditingController.text.toString(),
          });


          setState(() {
            petadoptapp.sharedPreferences.setString(petadoptapp.userEmail, _emailEditingController.text.toString());
          });
          email = "Email";
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Both Current Password and New Email Or New Password is required");
      }

    }

    if(imagefile != null)
      {

          String downloadurl = await uploadToStorage();
          final itemsRef = Firestore.instance.collection("users");
          itemsRef.document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID).toString())
              .updateData({
           "url" : downloadurl,
          });
          petadoptapp.sharedPreferences.setString(petadoptapp.userAvatarUrl, downloadurl);
          image="Image";
      }

    if(_nameEditingController.text.isNotEmpty)
    {


      final itemsRef = Firestore.instance.collection("users");
      itemsRef.document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID).toString())
          .updateData({
        "name" : _nameEditingController.text.toString(),
      });


      setState(() {
        petadoptapp.sharedPreferences.setString(petadoptapp.userName, _nameEditingController.text.toString());
      });
      name="Name";
    }
    if(name != null || image != null|| pass != null || email != null)
      {
        if (pass == null)
          {
            pass="";
          }
        if (image == null)
        {
          image="";
        }
        if (name == null)
        {
          name="";
        }
        if (email == null)
        {
          email="";
        }
        Fluttertoast.showToast(msg: "Updated $name $email $pass $image Successfully ");
        clearform();

      }





  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imagefile = image;
    });
  }
  Future<String> uploadToStorage() async
  {
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imagefile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    String downloadurl = await taskSnapshot.ref.getDownloadURL();
    return downloadurl;

  }

  void clearform()
  {

    Route route =  MaterialPageRoute(builder: (c) => StoreHome());

    Navigator.pushReplacement(context, route);
    setState(() {
      _nameEditingController.clear();
      _cpassEditingController.clear();
      _npassEditingController.clear();
      _emailEditingController.clear();
      imagefile=null;
    });



  }

  }



class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.orangeAccent;
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 250.0, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


