import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/models/_models/user_feed_model.dart';
import 'package:karmayogi_mobile/services/_services/feed_service.dart';

class NpsRepository extends ChangeNotifier {
  final FeedService npsService = FeedService();
  String _errorMessage = '';
  Response? _data;
  int maxRetryCount = 2;

  Future<List<UserFeed>> getFormFeed(userId) async {
    List<UserFeed> userFeed = [];
    try {
      final response = await npsService.getFormFeed(userId);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic>? feed = contents['result']['response']['userFeed'];
      if (feed != null) {
        userFeed = feed
            .map(
              (dynamic item) => UserFeed.fromJson(item),
            )
            .toList();
      }
    } else {
      _errorMessage = _data!.statusCode.toString();
      // throw _errorMessage;
    }
    userFeed.removeWhere((element) => element.category == 'Notification');
    return userFeed;
  }

  // ignore: missing_return
  Future<Map<String, dynamic>> getFormById(formId) async {
    try {
      final response = await npsService.getFormById(formId);
      _data = response;
    } catch (_) {
      throw _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      Map<String, dynamic> formFields = contents['responseData'];
      return formFields;
    } else {
      // throw 'Unable to get batch list';
      _errorMessage = _data!.statusCode.toString();
      print(_errorMessage);
      throw _errorMessage;
    }
  }

  Future<dynamic> submitForm(formField, review, rating, formId) async {
    try {
      final response =
          await npsService.submitForm(formField, review, rating, formId);
      _data = response;
    } catch (_) {
      return "_";
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['statusInfo']['statusMessage'];
    } else if (maxRetryCount > 0) {
      maxRetryCount--;
      await submitForm(formField, review, rating, formId);
    } else {
      return 'success';
    }
  }

  Future<dynamic> deleteNPSFeed(userId, feedId) async {
    try {
      final response = await npsService.deleteNPSFeed(userId, feedId);
      _data = response;
    } catch (_) {
      return "_";
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['result']['response'];
    } else {
      return 'success';
    }
  }
}
