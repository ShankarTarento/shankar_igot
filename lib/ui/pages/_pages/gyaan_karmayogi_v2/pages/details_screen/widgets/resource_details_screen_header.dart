import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/constants.dart';
import 'package:igot_ui_components/utils/helper.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class ResourceDetailsScreenHeaderV2 extends StatefulWidget {
  final ResourceDetails resourceDetails;

  const ResourceDetailsScreenHeaderV2({
    super.key,
    required this.resourceDetails,
  });

  @override
  State<ResourceDetailsScreenHeaderV2> createState() =>
      _ResourceDetailsScreenHeaderV2State();
}

class _ResourceDetailsScreenHeaderV2State
    extends State<ResourceDetailsScreenHeaderV2> {
  @override
  void initState() {
    initialiseData();
    super.initState();
  }

  void initialiseData() {
    try {
      htmlContent =
          html_parser.parse(widget.resourceDetails.instructions).body?.text ??
              '';
      var links = html_parser
          .parse(widget.resourceDetails.instructions)
          .querySelector('a');
      url = links == null ? null : links.attributes['href'];
    } catch (e) {
      debugPrint("Error in ResourceDetailsScreenHeaderV2: $e");
    }
  }

  String? url;

  String? htmlContent;
  final int defaultLength = 120;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).r,
      width: 1.sw,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.customBlue, AppColors.darkBlue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8.w,
          ),
          Text(
            widget.resourceDetails.name ?? '',
            style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: ModuleColors.white),
          ),
          SizedBox(
            height: 8.w,
          ),
          htmlContent != null && widget.resourceDetails.instructions != null
              ? InkWell(
                  onTap: () async {
                    if (htmlContent!.length > defaultLength) {
                      debugPrint("length greater than default length");
                      if (url != null && await canLaunchUrl(Uri.parse(url!))) {
                        await launchUrl(Uri.parse(url!));
                      }
                    }
                  },
                  child: HtmlWidget(
                    (htmlContent!.length > defaultLength)
                        ? '${htmlContent!.substring(0, defaultLength)}...'
                        : widget.resourceDetails.instructions ?? '',
                    textStyle: (htmlContent!.length > defaultLength)
                        ? GoogleFonts.lato(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: ModuleColors.white,
                          )
                        : null,
                  ),
                )
              : const SizedBox(),
          SizedBox(
            height: 16.w,
          ),
          widget.resourceDetails.lastPublishedOn != null
              ? Text(
                  "${AppLocalizations.of(context)!.mPublishedOn} ${ModuleHelper.getDateTimeInFormat(dateTime: widget.resourceDetails.lastPublishedOn!, desiredDateFormat: ModuleConstants.dateFormat2)}",
                  style: GoogleFonts.lato(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: ModuleColors.white),
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 16.w,
          ),
          Wrap(
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,
            runSpacing: 20,
            spacing: 16,
            children: [
              titleSubtitle(
                  context: context,
                  title: AppLocalizations.of(context)!.mStaticCategory,
                  subtitle: widget.resourceDetails.resourceCategory ?? "-"),
              titleSubtitle(
                  context: context,
                  title: AppLocalizations.of(context)!.mStaticResourceType,
                  subtitle: resourceType() ?? "-")
            ],
          )
        ],
      ),
    );
  }

  String? resourceType() {
    if (widget.resourceDetails.mimeType == EMimeTypes.youtubeLink ||
        widget.resourceDetails.mimeType == EMimeTypes.externalLink) {
      return "Youtube";
    } else if (widget.resourceDetails.mimeType == EMimeTypes.mp4) {
      return "Video";
    } else if (widget.resourceDetails.mimeType == EMimeTypes.mp3) {
      return "Audio";
    } else if (widget.resourceDetails.mimeType == EMimeTypes.pdf) {
      return "PDF";
    } else {
      return null;
    }
  }

  Widget titleSubtitle(
      {required BuildContext context,
      required String title,
      required String subtitle}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: ModuleColors.white),
          ),
          SizedBox(
            height: 4.w,
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: ModuleColors.white),
          )
        ],
      ),
    );
  }
}
