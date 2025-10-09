import 'package:flutter/material.dart';

class PhotoRenderStatusModel {
  final MemoryImage? image;
  final bool changePhoto;
  final bool deletePhoto;
  String format;
  String? fileName;

  PhotoRenderStatusModel(
      {this.image,
      this.changePhoto = false,
      this.deletePhoto = false,
      this.format = 'png',
      this.fileName});

  Map<String, dynamic> toJson() => {
        'changePhoto': changePhoto,
        'deletePhoto': deletePhoto,
        'image': image,
        'format': format,
        'fileName': fileName
      };

  factory PhotoRenderStatusModel.fromJson(Map<String, dynamic> json) {
    return PhotoRenderStatusModel(
        changePhoto: json['changePhoto'] ?? false,
        deletePhoto: json['deletePhoto'] ?? false,
        image: json['image'],
        format: json['format'],
        fileName: json['fileName']);
  }
}
