import 'dart:math';

import 'package:flutter/material.dart';

import 'customClipper.dart';

class secondContainer extends StatelessWidget {
  const secondContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.rotate(
          angle: -pi / 3.5,
          child: ClipPath(

            child: Container(
              height: MediaQuery.of(context).size.height *.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(

              ),
            ),
          ),
        )
    );
  }
}