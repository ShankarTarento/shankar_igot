import 'package:flutter/material.dart';

class Lang extends StatelessWidget {
  const Lang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Align(
        alignment: Alignment.topLeft,
        child: Text("Lang"),
      ),
    );
  }
}
