import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String breed;
  String info;
  Timestamp publishedDate;
  String thumbnailUrl1;
  String thumbnailUrl2;
  String thumbnailUrl3;
  String category;
  String color;
  String weight;
  GeoPoint location;
  String phone;
  String uid;
  /*String status;*/
  String age;


  ItemModel(
      {this.breed,
        this.info,
        this.publishedDate,
        this.thumbnailUrl1,
        this.thumbnailUrl2,
        this.thumbnailUrl3,
        this.category,
        this.age,
        this.location,

        this.phone,
        this.weight,
        this.color,
        this.uid,


      });

  ItemModel.fromJson(Map<String, dynamic> json) {
    breed = json['breed'];
    info = json['info'];
    publishedDate = json['publishedDate'];
    thumbnailUrl1 = json['thumbnailUrl1'];
    thumbnailUrl2 = json['thumbnailUrl2'];
    thumbnailUrl3 = json['thumbnailUrl3'];
    category = json['category'];
    location = json['location'];
    age = json['age'];
    phone = json['phone'];
    weight = json['weight'];
    color = json['color'];
    uid = json['uid'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['breed'] = this.breed;
    data['info'] = this.info;
    data['publishedDate'] = this.publishedDate;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['thumbnailUrl1'] = this.thumbnailUrl1;
    data['thumbnailUrl2'] = this.thumbnailUrl2;
    data['thumbnailUrl3'] = this.thumbnailUrl3;
    data['category'] = this.category;
    data['location'] = this.location;
    data['age'] = this.age;
    data['weight'] = this.weight;
    data['color'] = this.color;
    data['uid'] = this.uid;


    return data;
  }
}

class PublishedDate {
  String date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
