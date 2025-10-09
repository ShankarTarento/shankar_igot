import 'package:flutter/material.dart';

class ProfileTopSectionModel {
  MemoryImage? image;
  String profileImageUrl;
  String firstName;
  String surname;
  String state;
  String district;

  ProfileTopSectionModel(
      {this.image,
      this.profileImageUrl = '',
      this.firstName = '',
      this.surname = '',
      this.state = '',
      this.district = ''});

  Map<String, dynamic> toJson() => {
        'profileImageUrl': profileImageUrl,
        'firstName': firstName,
        'surname': surname,
        'state': state,
        'district': district
      };

  factory ProfileTopSectionModel.fromJson(Map<String, dynamic> json) {
    return ProfileTopSectionModel(
      profileImageUrl: json['profileImageUrl'] ?? '',
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
    );
  }
}
