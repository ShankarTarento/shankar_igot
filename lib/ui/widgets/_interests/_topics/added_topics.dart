import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/_constants/color_constants.dart';

class AddedTopics extends StatefulWidget {
  final addedTopics;
  final removeFromAddedTopic;
  const AddedTopics({Key? key, this.addedTopics, this.removeFromAddedTopic})
      : super(key: key);

  @override
  State<AddedTopics> createState() => _AddedTopicsState();
}

class _AddedTopicsState extends State<AddedTopics> {
  List<Widget> _getSelectedTopics(List<dynamic> data) {
    List<Widget> selectedTopics = [];

    for (int i = 0; i < data.length; i++) {
      selectedTopics.add(InkWell(
        onTap: () {
          widget.removeFromAddedTopic(data[i]);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryThree,
            border: Border.all(color: AppColors.primaryThree),
            borderRadius: BorderRadius.all(Radius.circular(18)).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8).r,
            child: Text(
              data[i],
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    wordSpacing: 1.0.r,
                    fontSize: 12.sp,
                  ),
            ),
          ),
        ),
      ));
    }
    return selectedTopics;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8).r,
      child: ExpansionTile(
        expandedAlignment: Alignment.topLeft,
        collapsedBackgroundColor: AppColors.appBarBackground,
        backgroundColor: AppColors.appBarBackground,
        childrenPadding: EdgeInsets.only(bottom: 16, left: 16, right: 16).r,
        onExpansionChanged: (value) async {},
        tilePadding: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
        title: Text(
          'Added by you',
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                height: 1.5.w,
                letterSpacing: 0.25.r,
              ),
        ),
        children: [
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getSelectedTopics(widget.addedTopics))
        ],
      ),
    );
  }
}
