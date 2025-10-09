import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double customSize = 0;
  double get fontSize => customSize;

  bool _largeButtonEnabled = false;
  bool get largeButtonEnabled => _largeButtonEnabled;

  bool _smallButtonEnabled = false;
  bool get smallButtonEnabled => _smallButtonEnabled;

  bool _mediumButtonEnabled = true;
  bool get mediumButtonEnabled => _mediumButtonEnabled;

  void smallFontSize() {
    customSize = 0;
    _smallButtonEnabled = true;
    _mediumButtonEnabled = false;
    _largeButtonEnabled = false;
    notifyListeners();
  }

  void mediumFontSize() {
    customSize = 3;
    _smallButtonEnabled = false;
    _mediumButtonEnabled = true;
    _largeButtonEnabled = false;
    notifyListeners();
  }

  void largeFontSize() {
    customSize = 6;
    _smallButtonEnabled = false;
    _mediumButtonEnabled = false;
    _largeButtonEnabled = true;
    notifyListeners();
  }

  void settoDefaultSize() {
    customSize = 0;
    notifyListeners();
  }
}
