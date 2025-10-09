import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/index.dart';

class PresetsTimeFilter extends StatefulWidget {
  @override
  _PresetsTimeFilterState createState() => _PresetsTimeFilterState();
}

class _PresetsTimeFilterState extends State<PresetsTimeFilter> {
  bool selectionStatus = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 1.sh,
        color: AppColors.appBarBackground,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Today',
                // style: GoogleFonts.lato(

                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            ListTile(
              title: Text(
                'This week',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              onTap: () => {
                setState(() {
                  selectionStatus = true;
                })
              },
              selected: selectionStatus,
              selectedTileColor: Color.fromRGBO(0, 116, 182, 0.2),
            ),
            ListTile(
              title: Text(
                'This month',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            ListTile(
              title: Text(
                'This year',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
