import 'dart:convert';

import 'package:flutter/material.dart';

import '../index.dart';

TocPlayerModel tocPlayerModelFromJson(String str) =>
    TocPlayerModel.fromJson(json.decode(str));

class TocPlayerModel {
  Course? enrolledCourse;
  List? navigationItems;
  bool? isCuratedProgram;
  String? batchId;
  String courseId;
  String? lastAccessContentId;
  bool? isFeatured;
  final VoidCallback? onPopCallback;
  List<Course> enrollmentList;

  TocPlayerModel(
      {this.enrolledCourse,
      this.navigationItems,
      this.isCuratedProgram,
      this.batchId,
      required this.courseId,
      this.lastAccessContentId,
      this.isFeatured,
      this.onPopCallback,
      required this.enrollmentList});

  factory TocPlayerModel.fromJson(Map<String, dynamic> json) => TocPlayerModel(
      enrolledCourse: json['enrolledCourse'],
      navigationItems:
          json['navigationItems'] != null ? json['navigationItems'] : [],
      isCuratedProgram:
          json['isCuratedProgram'] != null ? json['isCuratedProgram'] : false,
      batchId: json['batchId'],
      lastAccessContentId: json['lastAccessContentId'],
      isFeatured: json['isFeatured'] != null ? json['isFeatured'] : false,
      courseId: json['courseId'],
      onPopCallback: json['onPopCallback'],
      enrollmentList: json['enrollmentList'] ?? []);
}
