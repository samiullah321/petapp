import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class nutritionModel {
  String name;
  String weight;
  String price;
  String ImageUrl;
  String category;

  String brand;
  String ShippedBy;
  String age;
  String description;



  nutritionModel(
      {this.name,
      this.weight,
      this.price,
      this.ImageUrl,
      this.category,

      this.brand,
      this.ShippedBy,
      this.age,
      this.description,


      });

  nutritionModel.fromJson(Map<String, dynamic> json) {
    description = json['Description'];
    ImageUrl = json['Thumbnailurl'];
    weight = json['Weight'];
    price = json['Price'];
    category = json['Category'];
    age = json['Age'];
    brand = json['Brand'];
    ShippedBy = json['ShippedBy'];
    name = json['name'];




  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Description'] = this.description;
    data['Thumbnailurl'] = this.ImageUrl;
    data['Weight'] = this.weight;
    data['Price'] = this.price;
    data['Category'] = this.category;
    data['Age'] = this.age;

    data['Brand'] = this.brand;
    data['name'] = this.name;




    return data;
  }
}



