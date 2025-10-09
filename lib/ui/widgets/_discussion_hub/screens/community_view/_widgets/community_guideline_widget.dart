import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';

class CommunityGuidelineWidget extends StatefulWidget {
  final String guidelines;
  final Function? onSubmitCallback;
  final bool displayOnly;

  const CommunityGuidelineWidget(
      {Key? key,
      required this.guidelines, this.onSubmitCallback, this.displayOnly = false})
      : super(key: key);

  @override
  State<CommunityGuidelineWidget> createState() => CommunityGuidelineWidgetState();
}

class CommunityGuidelineWidgetState extends State<CommunityGuidelineWidget> {
  ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _acceptGuidelines() async {
    _isLoading.value = true;
    if (widget.onSubmitCallback != null) {
      widget.onSubmitCallback!();
    }
    _isLoading.value = false;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: (widget.displayOnly) ? 0.22.sh : 0.16.sh , bottom: (widget.displayOnly) ? 0.22.sh : 0.16.sh, left: 8, right: 8).w,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16).r,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12).r,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey16),
                  borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
                  color: AppColors.appBarBackground
              ),
              child: _buildLayout()
            ),
          ),
          _appbarView(),
        ],
      ),
    );
  }

  Widget _appbarView() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8).r,
      child: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
            },
            child: Container(
              alignment: Alignment.center,
              height: 24.w,
              width: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey08,
              ),
              child: Icon(
                Icons.close,
                color: Color.fromRGBO(128, 140, 152, 1),
                size: 10.sp,
              ),
            ),
          )),
    );
  }

  Widget _buildLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          buildLayout(),
          if (!widget.displayOnly)
            Positioned(
              bottom: 0, // Adjust position
              left: 0,
              right: 0,
              child: bottomView(),  // Your bottom view
            ),
        ],
      ),
    );
  }

  Widget buildLayout() {
    return Container(
      height: 1.sh,
      margin: EdgeInsets.only(bottom: 16).r,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground
      ),
      child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16.w),
                  Center(
                    child: Icon(
                      Icons.flag_outlined,
                      color: AppColors.redBgShade,
                      size: 56.w,
                    ),
                  ),
                  SizedBox(height: 16.w),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.mDiscussionCommunityGuidelines,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!widget.displayOnly) ...[
                    SizedBox(height: 16.w),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.mDiscussionCommunityAgreeToFollowing,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: AppColors.darkBlue
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.w),
                  HtmlWidget(
                    widget.guidelines,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                  )

                ],
              ))),
    );
  }

  Widget bottomView() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 16).r,
      color: AppColors.appBarBackground,
      alignment: Alignment.center,
      child: ElevatedButton(
          onPressed: () async {
            await _acceptGuidelines();
          },
          child: ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (BuildContext context, bool isLoading, Widget? child) {
                return Container(
                  width: 148.w,
                  alignment: Alignment.center,
                  child: isLoading
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8).w,
                    child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: Center(
                          child: PageLoader(
                            strokeWidth: 2,
                            isLightTheme: false,
                          ),
                        )
                    ),
                  ) : Text(
                    AppLocalizations.of(context)!.mDiscussionCommunityAgree,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63).r,
            ),
          )),
    );
  }
}
