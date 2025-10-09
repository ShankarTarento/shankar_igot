import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_hub_v2.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_custom_app_bar.dart';
import '../../widgets/index.dart';

class EventsHub extends StatelessWidget {
  const EventsHub({Key? key}) : super(key: key);
  static const route = AppUrl.eventsHub;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      appBar: HubsCustomAppBar(
        title: AppLocalizations.of(context)!.mStaticEvents,
        titlePrefixIcon: SvgPicture.asset(
          'assets/img/events.svg',
          width: 24.0.w,
          height: 24.0.w,
          colorFilter:
          ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
        ),
      ),
      body: EventsHubV2(),
      bottomSheet: BottomBar(),
    ).withChatbotButton();
  }
}
