import 'package:flutter/widgets.dart';

class InformationCardModel {
  final int scenarioNumber;
  final IconData icon;
  final String information;
  final Color iconColor;

  const InformationCardModel(
      {required this.scenarioNumber,required this.icon,required this.information,required this.iconColor});
}
