import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import './../../../constants/index.dart';

class HomeHubItem extends StatefulWidget {
  final int id;
  final String title;
  final Object icon;
  final Object iconColor;
  final String url;
  final bool displayNotification;
  final String svgIcon;

  HomeHubItem(this.id, this.title, this.icon, this.iconColor, this.url,
      this.displayNotification, this.svgIcon);

  @override
  _HomeHubItemState createState() => _HomeHubItemState();
}

class _HomeHubItemState extends State<HomeHubItem> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildItems() {
    List<Widget> stackElements = [];
    stackElements.add(Container(
      // height: 70,
      // margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.only(top: 14),
      alignment: Alignment.center,
      child: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            SvgPicture.asset(
              widget.svgIcon,
              width: 24.0.w,
              height: 24.0.w,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4).r,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      letterSpacing: 0.25.r,
                    ),
              ),
            ),
          ],
        ),
      ]),
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          border: Border.all(color: AppColors.grey08),
          borderRadius: BorderRadius.circular(5).r,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey08,
              blurRadius: 6.0.r,
              spreadRadius: 0.r,
              offset: Offset(
                0, // Move to right 10  horizontally
                3, // Move to bottom 10 Vertically
              ),
            ),
          ]),
    ));
    if (widget.displayNotification) {
      stackElements.add(Positioned(
        // draw a red marble
        top: -1,
        right: -1,
        child: new Icon(Icons.brightness_1,
            size: 12.0.sp, color: AppColors.negativeLight),
      ));
    }
    return stackElements;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        // onTap: () => selectCategory(context),
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5).r,
        child: Stack(children: _buildItems()));
  }
}
