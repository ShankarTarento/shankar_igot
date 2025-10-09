import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/common_components/models/information_card_model.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class InformationCard extends StatefulWidget {
  final InformationCardModel informationCardModel;

  const InformationCard({super.key, required this.informationCardModel});

  @override
  State<InformationCard> createState() => _InformationCardState();
}

class _InformationCardState extends State<InformationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16).r,
      width: 1.sw,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: widget.informationCardModel.backgroundColor != null &&
                int.tryParse(widget.informationCardModel.backgroundColor!) !=
                    null
            ? Color(int.parse(widget.informationCardModel.backgroundColor!))
            : AppColors.darkBlue,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Column(
        children: [
          Row(
            children: [
              widget.informationCardModel.imageUrl != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0).r,
                      child: ImageWidget(
                        imageUrl: ApiUrl.baseUrl +
                            widget.informationCardModel.imageUrl!,
                        height: 40.sp,
                        width: 40.sp,
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                width: widget.informationCardModel.imageUrl != null
                    ? 0.65.sw
                    : 0.8.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.informationCardModel.title != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0).r,
                            child: Text(
                              widget.informationCardModel.title!
                                  .getText(context),
                              style: GoogleFonts.lato(
                                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          )
                        : SizedBox(),
                    widget.informationCardModel.content != null
                        ? Text(
                            widget.informationCardModel.content!
                                .getText(context),
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ],
          ),
          widget.informationCardModel.btnTitle != null &&
                  widget.informationCardModel.surveyUrl != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8).w,
                      height: 40.w,
                      child: ElevatedButton(
                        onPressed: () {
                          String url = widget.informationCardModel.surveyUrl!;
                          if (!url.startsWith('http')) {
                            url = ApiUrl.baseUrl + url;
                          }
                          Helper.doLaunchUrl(
                              url: widget.informationCardModel.surveyUrl!);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30).r,
                            side: BorderSide(color: AppColors.darkBlue),
                          ),
                        ),
                        child: Text(
                          widget.informationCardModel.btnTitle!
                              .getText(context),
                          style: GoogleFonts.lato(
                            color: AppColors.appBarBackground,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }
}
