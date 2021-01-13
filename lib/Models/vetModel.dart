import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class vetModel {
  String name;
  String timings;
  String thumbnailUrl;
  String vetId;
  String workingDays;
  String email;
  GeoPoint location;
  String hospital;
  String phone;
  String description;



  vetModel(
      {this.name,
        this.timings,
        this.vetId,
        this.thumbnailUrl,
        this.workingDays,
        this.email,
        this.location,
        this.description,
        this.phone,
        this.hospital,



      });

  vetModel.fromJson(Map<String, dynamic> json) {
    description = json['Description'];
    thumbnailUrl = json['Thumbnailurl'];
    timings = json['Timings'];
    vetId = json['VetId'];
    workingDays = json['WorkingDays'];
    email = json['email'];
    hospital = json['hospital'];
    location = json['location'];
    name = json['name'];
    phone = json['phone'];



  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Description'] = this.description;
    data['name'] = this.name;
    data['Timings'] = this.timings;
    data['email'] = this.email;
    data['hospital'] = this.hospital;
    data['WorkingDays'] = this.workingDays;

    data['location'] = this.location;
    data['name'] = this.name;

    data['phone'] = this.phone;
    data['VetId'] = this.vetId;


    return data;
  }
}



