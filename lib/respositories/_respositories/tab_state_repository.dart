import 'package:flutter/material.dart';

class TabStateRepository extends ChangeNotifier {
  int _customTabIndex = 0;
  int get customTabIndex => _customTabIndex;

  void updateCustomTabIndex(int index) {
    _customTabIndex = index;
    notifyListeners();
  }
}
