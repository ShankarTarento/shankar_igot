import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';
import '../../../../constants/index.dart';
import '../utils/utils.dart';

class SMTCarouselNotificationView extends StatefulWidget {
  final SMTAppInboxMessage inbox;
  const SMTCarouselNotificationView({Key? key, required this.inbox})
      : super(key: key);

  @override
  State<SMTCarouselNotificationView> createState() =>
      _SMTCarouselNotificationViewState();
}

class _SMTCarouselNotificationViewState
    extends State<SMTCarouselNotificationView> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController =
        PageController(initialPage: 0, viewportFraction: 1, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              height: 175.w,
              child: PageView.builder(
                  itemCount: widget.inbox.carousel.length,
                  controller: _pageController,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () async {
                        Future.delayed(
                            const Duration(milliseconds: 500), () async {});
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                child: Image.network(
                                  widget.inbox.carousel[index].imgUrl,
                                  width: double.infinity,
                                  height: 120.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                bottom: 8,
                                child: InkWell(
                                  onTap: () {
                                    _pageController.jumpToPage(index - 1);
                                  },
                                  child: Container(
                                    color:
                                        AppColors.appBarBackground.withValues(alpha: 0.6),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0).r,
                                      child: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        size: 26.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 8,
                                child: InkWell(
                                  onTap: () {
                                    if (index !=
                                        widget.inbox.carousel.length - 1)
                                      _pageController.jumpToPage(index + 1);
                                  },
                                  child: Container(
                                    color:
                                        AppColors.appBarBackground.withValues(alpha: 0.6),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0).r,
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 26.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.w,
                          ),
                          Text(
                            '${widget.inbox.carousel[index].imgTitle.toString()}',
                            style: TextStyle(
                              color: AppColors.greys,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                          Text(
                            '${widget.inbox.carousel[index].imgMsg.toString()}',
                            style: TextStyle(
                              color: AppColor.greyColorText,
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ]),
        ],
      ),
    );
  }
}
