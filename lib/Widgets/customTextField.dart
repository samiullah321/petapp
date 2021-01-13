import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget
{
  final TextEditingController controller;
  final IconData data;
  final String hintText;
  bool isObsecure = true;
  InputDecoration inputDecoration;
  TextStyle textStyle;

  CustomTextField(
      {Key key, this.controller, this.data, this.hintText,this.isObsecure,this.inputDecoration, this.textStyle}
      ) : super(key: key);



  @override
  Widget build(BuildContext context)
  {
    return Container
    (
      decoration: BoxDecoration(

        borderRadius: BorderRadius.all(Radius.circular(10.0)),

      ),

      margin: EdgeInsets.all(4.0),
      child: TextFormField(
        controller:controller,
        obscureText: isObsecure,
        cursorColor: Theme.of(context).primaryColor,
        decoration: inputDecoration,
        style: textStyle,
      ),
    );
  }
}
