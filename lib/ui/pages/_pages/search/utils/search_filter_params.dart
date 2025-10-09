import 'package:flutter/material.dart';

import 'search_helper.dart';

class SearchCategoryData {
  final String id;
  final String tabNameEn;
  final String tabNameHi;
  final int tabIndex;
  final IconData? tabIcon;

  SearchCategoryData(
      {required this.id,
      required this.tabNameEn,
      required this.tabNameHi,
      required this.tabIndex,
      this.tabIcon});

  static List<SearchCategoryData> filterParams({List pills = const []}) {
    List<SearchCategoryData> categories = [];
    pills.sort((a, b) => a['priority'].compareTo(b['priority']));
    int count = 0;
    pills.forEach((item) {
      // Updating priority to handle multiple item with same priority
      item['priority'] = count++;
      final handler = handlers[item['id']];

      if (handler != null) {
        handler(item, categories); // Calls the function and adds to targetList
      }
    });
    return categories;
  }

  static Map<String, Function(Map<String, dynamic>, List<SearchCategoryData>)>
      handlers = {
    SearchCategories.content: (pill, categories) => categories
        .add(getCategoryObject(pill, icon: Icons.video_collection_rounded)),
    SearchCategories.events: (pill, categories) =>
        categories.add(getCategoryObject(pill, icon: Icons.event)),
    SearchCategories.people: (pill, categories) =>
        categories.add(getCategoryObject(pill, icon: Icons.people)),
    SearchCategories.externalContent: (pill, categories) =>
        categories.add(getCategoryObject(pill, icon: Icons.menu_book)),
    SearchCategories.communities: (pill, categories) => categories
        .add(getCategoryObject(pill, icon: Icons.diversity_3_rounded)),
    SearchCategories.resources: (pill, categories) =>
        categories.add(getCategoryObject(pill, icon: Icons.menu_book)),
    SearchCategories.all: (pill, categories) =>
        categories.add(getCategoryObject(pill))
  };

  static SearchCategoryData getCategoryObject(Map<String, dynamic> pill,
      {IconData? icon}) {
    return SearchCategoryData(
      id: pill['id'],
      tabNameEn: pill['label'],
      tabNameHi: pill['hiLabel'],
      tabIndex: pill['priority'],
      tabIcon: icon,
    );
  }
}
