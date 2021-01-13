import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Store/Search.dart';


class SearchBoxDelegate extends SliverPersistentHeaderDelegate {



  Future<QuerySnapshot> docList;
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent
      ) =>
      InkWell(

        child: Container(
               padding: EdgeInsets.all(0),


        ),


        );


  @override
  double get maxExtent => 0;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;



  Future startSearching(String query) async
  {

    docList = Firestore.instance.collection("ads").where("category", isEqualTo: query).getDocuments();


  }
}


