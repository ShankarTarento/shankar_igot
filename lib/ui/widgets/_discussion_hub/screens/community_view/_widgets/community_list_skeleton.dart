import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';

class CommunityListSkeleton extends StatefulWidget {
  final int itemCount;
  final double verticalMargin;
  final double horizontalMargin;
  CommunityListSkeleton({Key? key, this.itemCount = 1, this.verticalMargin = 0, this.horizontalMargin = 0}) : super(key: key);

  _CommentViewSkeletonState createState() => _CommentViewSkeletonState();

}

class _CommentViewSkeletonState extends State<CommunityListSkeleton>
    with TickerProviderStateMixin, SkeletonAnimation {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.verticalMargin, horizontal: widget.horizontalMargin),
      child: AnimatedBuilder(
          animation: animationValue,
          builder: (context, child) {
            return _buildCommunityListView();
          }
      ),
    );
  }

  Widget _buildCommunityListView() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16).r,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: (widget.itemCount / 2).ceil(),
        itemBuilder: (context, index) {
          int firstItemIndex = index * 2;
          int secondItemIndex = firstItemIndex + 1;
          bool isLastRowWithOneItem = secondItemIndex >= widget.itemCount;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
            child: Row(
              mainAxisAlignment: isLastRowWithOneItem
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                  child: CommunityCardWidgetSkeleton(color: animationValue.value!),
                ),
                if (secondItemIndex < widget.itemCount)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                    child: CommunityCardWidgetSkeleton(color: animationValue.value!),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
