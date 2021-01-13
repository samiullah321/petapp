

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:e_shop/Config/config.dart';
import 'package:path_provider/path_provider.dart';
import 'decoration_functions.dart';
import 'sign_in_up_bar.dart';
import 'title.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
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
class Register extends StatefulWidget {
  Register({Key key, this.onSignInPressed}) : super(key: key);

  final VoidCallback onSignInPressed;

  @override
  _RegisterState createState() => _RegisterState();
}
class _RegisterState extends State<Register> {




  @override
  Widget build(BuildContext context) {
    double _screenwidth = MediaQuery.of(context).size.width, _screenWidth = MediaQuery.of(context).size.height;
    final isSubmitting = context.isSubmitting();
    return SignInForm(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: LoginTitle(
                  title: 'Create\nAccount',
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: ListView(
                children: [

                  InkWell(
                     onTap: ()=> _selectAndPickImage(),
                    child: CircleAvatar(

                      radius: _screenwidth * 0.17,
                      backgroundColor: Colors.white,
                      backgroundImage: _imageFile == null ? null : FileImage(_imageFile),
                      child: _imageFile == null
                          ? Icon(Icons.add_photo_alternate, size: _screenwidth*0.17, color: Colors.grey,)
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child:  CustomTextField(
                      controller: _nametextEditingController,
                      data: Icons.email,
                      hintText: "Name",
                      isObsecure: false,
                      inputDecoration: registerInputDecoration(hintText: "Name"),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child:  CustomTextField(
                      controller: _emailtextEditingController,
                      data: Icons.email,
                      hintText: "Email",
                      isObsecure: false,
                      inputDecoration: registerInputDecoration(hintText: "Email"),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child:   CustomTextField(
                      controller: _passwordtextEditingController,
                      data: Icons.keyboard,
                      hintText: "Password",
                      isObsecure: true,
                      inputDecoration: registerInputDecoration(hintText: 'Password'),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: CustomTextField(
                      controller: _cpasswordtextEditingController,
                      data: Icons.keyboard,
                      hintText: "Confirm Password",
                      isObsecure: true,
                      inputDecoration: registerInputDecoration(hintText: 'Confirm Password'),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),

                    ),
                  ),

                  SignUpBar(
                    label: 'Sign up',
                    isLoading: isSubmitting,
                    onPressed: () {
                      uploadAndSaveImage(context);
                    },
                    onPressed2: () {

                      _login();
                    },
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () {
                        widget.onSignInPressed?.call();
                      },
                      child: const Text(
                        'Sign in',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
  Future<void> _selectAndPickImage() async
  {
    File imageAvatar = await ImagePicker.pickImage(source: ImageSource.gallery);


      setState(() {
        _imageFile = imageAvatar;
      });


  }

  Future<void> uploadAndSaveImage(BuildContext context) async
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

          ? uploadToStorage(context)

          : displayDialog("Please fill up the registration form",context)

          : displayDialog("Password do not match",context);
    }
  }

  displayDialog(String msg,BuildContext context)
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return ErrorAlertDialog(message: msg,);
        }
    );
  }

  uploadToStorage(BuildContext context) async
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

      _registerUser(context);
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser(BuildContext context) async
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
      print("1");
      await _googleSignIn.signIn();
      print("2");
      email = _googleSignIn.currentUser.email;
      print("3");
      userImageUrl1 = _googleSignIn.currentUser.photoUrl;
      print("4");
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
    _logout();
  }

  _logout(){
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
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




