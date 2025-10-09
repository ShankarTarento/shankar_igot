import 'package:flutter/material.dart';
class FilterName extends StatelessWidget {
  final filterName;

  FilterName(this.filterName);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        filterName,
      
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
