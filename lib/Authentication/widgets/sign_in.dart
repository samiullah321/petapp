

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:e_shop/Authentication/widgets/decoration_functions.dart';
import 'package:e_shop/Authentication/widgets/sign_in_up_bar.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/palette.dart';
import 'title.dart';

class SignIn extends StatelessWidget {
  SignIn({
    Key key,
    @required this.onRegisterClicked,
  }) : super(key: key);


  final VoidCallback onRegisterClicked;
  final TextEditingController _emailtextEditingController = TextEditingController();
  final TextEditingController _passwordtextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.isSubmitting();
    return SignInForm(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: LoginTitle(
                  title: 'Welcome\nBack',
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomTextField(
                      controller: _emailtextEditingController,
                      data: Icons.email,
                      hintText: "Email",
                      isObsecure: false,
                      inputDecoration: signInInputDecoration(hintText: "Email"),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child:  CustomTextField(
                      controller: _passwordtextEditingController,
                      data: Icons.keyboard,
                      hintText: "Password",
                      isObsecure: true,
                      inputDecoration: signInInputDecoration(hintText: 'Password'),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),

                    ),
                    // PasswordTextFormField(
                    //   decoration: signInInputDecoration(hintText: 'Password'),
                    // ),
                  ),
                  SignInBar(
                    label: 'Sign in',
                    isLoading: isSubmitting,
                    onPressed: () {

                      _emailtextEditingController.text.isNotEmpty && _passwordtextEditingController.text.isNotEmpty
                          ? loginUser(context)
                          : showDialog(
                          context: context,
                          builder: (c)
                          {
                            return ErrorAlertDialog(message: "Please Enter Email and Password",);
                          }
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () {
                        onRegisterClicked?.call();
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Palette.darkBlue,
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

  FirebaseAuth _auth = FirebaseAuth.instance;
  void loginUser(BuildContext context) async
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
    Firestore.instance.collection("users").document(fuser.uid).get().then((
        dataSnapshot) async {
      await petadoptapp.sharedPreferences.setString(
          "uid", dataSnapshot.data[petadoptapp.userUID]);
      await petadoptapp.sharedPreferences.setString(
          petadoptapp.userEmail, dataSnapshot.data[petadoptapp.userEmail]);
      await petadoptapp.sharedPreferences.setString(
          petadoptapp.userName, dataSnapshot.data[petadoptapp.userName]);
      await petadoptapp.sharedPreferences.setString(petadoptapp.userAvatarUrl,
          dataSnapshot.data[petadoptapp.userAvatarUrl]);
      List<String> cartList = dataSnapshot.data[petadoptapp.userCartList].cast<
          String>();
      await petadoptapp.sharedPreferences.setStringList(
          petadoptapp.userCartList, cartList);
    });
  }
  }