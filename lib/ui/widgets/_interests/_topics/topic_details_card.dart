import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../models/_models/course_topics_model.dart';
import '../../../../services/_services/profile_service.dart';

class TopicDetailsCard extends StatefulWidget {
  final CourseTopics topic;
  final getTopicSelectedStatus;
  final saveProfile;
  final List<dynamic> selectedTopics;

  const TopicDetailsCard(
      {Key? key,
      required this.topic,
      required this.selectedTopics,
      this.getTopicSelectedStatus,
      this.saveProfile})
      : super(key: key);

  @override
  State<TopicDetailsCard> createState() => _TopicDetailsCardState();
}

class _TopicDetailsCardState extends State<TopicDetailsCard> {
  final ProfileService profileService = ProfileService();
  bool _isExpanded = false;

  int _getSelectedTopicsLength(List<dynamic> data) {
    var selected = [];

    for (var topic in data) {
      for (var selectedTopic in widget.selectedTopics) {
        if (topic['identifier'] == selectedTopic['identifier']) {
          selected.add(topic);
        }
      }
    }

    return selected.length;
  }

  List<Widget> _getSelectedTopics(List<dynamic> data) {
    List<Widget> selectedTopics = [];
    var selected = [];

    for (var topic in data) {
      for (var selectedTopic in widget.selectedTopics) {
        if (topic['identifier'] == selectedTopic['identifier']) {
          selected.add(topic);
        }
      }
    }

    for (int i = 0; i < selected.length; i++) {
      selectedTopics.add(InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryThree,
            border: Border.all(color: AppColors.primaryThree),
            borderRadius: BorderRadius.all(Radius.circular(18)).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8).r,
            child: Text(
              selected[i]['name'],
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    letterSpacing: 0.25.r,
                    fontSize: 12.sp,
                  ),
            ),
          ),
        ),
      ));
    }
    return selectedTopics;
  }

  List<Widget> _getSubTopics(List<dynamic> data) {
    List<Widget> subTopics = [];
    List<dynamic> temp = data;
    for (int i = 0; i < temp.length; i++) {
      if ((widget.selectedTopics.where(
              (element) => element['identifier'] == temp[i]['identifier']))
          .isNotEmpty) {
        temp[i]['isSelected'] = true;
      } else if (((widget.selectedTopics.where(
              (element) => element['identifier'] == temp[i]['identifier']))
          .isEmpty)) {
        temp[i]['isSelected'] = false;
      }
      subTopics.add(InkWell(
        onTap: () {
          setState(() {
            temp[i]['isSelected'] = !temp[i]['isSelected'];
            Map selected = {
              'identifier': temp[i]['identifier'],
              'name': temp[i]['name'],
              'children': temp[i]['children'],
            };
            if (temp[i]['isSelected']) {
              widget.selectedTopics.add(selected);
              widget.saveProfile();
            } else {
              if (widget.selectedTopics
                  .where((element) =>
                      element['identifier'] == selected['identifier'])
                  .isNotEmpty) {
                widget.selectedTopics.removeWhere((element) =>
                    element['identifier'] == selected['identifier']);
                widget.saveProfile();
              }
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: temp[i]['isSelected']
                ? AppColors.primaryThree
                : AppColors.grey04,
            border: Border.all(
                color: temp[i]['isSelected']
                    ? AppColors.primaryThree
                    : AppColors.grey08),
            borderRadius: BorderRadius.all(Radius.circular(18)).r,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8).r,
            child: Text(
              temp[i]['name'],
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: temp[i]['isSelected']
                        ? AppColors.appBarBackground
                        : AppColors.greys87,
                  ),
            ),
          ),
        ),
      ));
    }
    return subTopics;
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
        onExpansionChanged: (value) async {
          setState(() {
            _isExpanded = value;
          });
        },
        tilePadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        title: Text(
          widget.topic.name ?? "",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                letterSpacing: 0.25.r,
                height: 1.5.w,
              ),
        ),
        subtitle: (widget.topic.raw['children'] != null &&
                widget.topic.raw['children'].length > 0)
            ? (!_isExpanded
                ? (_getSelectedTopicsLength(widget.topic.raw['children']) > 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color: AppColors.grey16,
                              height: 32.w,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16).r,
                              child: Text(
                                "Selected topics",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      letterSpacing: 0.25.r,
                                      height: 1.33.w,
                                    ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _getSelectedTopics(
                                  widget.topic.raw['children']),
                            )
                          ],
                        ),
                      )
                    : null)
                : null)
            : null,
        children: [
          (widget.topic.raw['children'] != null &&
                  widget.topic.raw['children'].length > 0)
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getSubTopics(widget.topic.raw['children']))
              : Center()
        ],
      ),
    );
  }
}
