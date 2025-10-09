import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/models/_models/browse_by_model.dart';
import 'package:karmayogi_mobile/ui/learn_hub/constants/learn_hub_constants.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/explore_by/widgets/browse_by_card.dart';
import 'package:karmayogi_mobile/ui/screens/index.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import '../../../../util/helper.dart';
import '../../../../util/telemetry_repository.dart';
import './../../../../util/faderoute.dart';
import './../../../../constants/index.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearnExploreBy extends StatefulWidget {
  @override
  _LearnExploreByState createState() => _LearnExploreByState();
}

class _LearnExploreByState extends State<LearnExploreBy> {
  bool isMdoChannelEnabled = false;
  String orgBookmarkId = "";

  @override
  void initState() {
    super.initState();
    _getItemConfigData();
  }

  void _getItemConfigData() async {
    final config = AppConfiguration.homeConfigData;
    final mdoChannel = config?['mdoChannelMobile'];

    if (mdoChannel != null) {
      final _orgBookmarkId = Helper.getid(mdoChannel);
      final enabled = Helper.isMdoChannelEnabled(mdoChannel);

      if (enabled && _orgBookmarkId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            isMdoChannelEnabled = true;
            orgBookmarkId = _orgBookmarkId;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BrowseBy> browseByList = BROWSEBY(context: context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0).r,
            child: Text(
              AppLocalizations.of(context)!.mBrowseLearnExploreAllCBP,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5.w,
                    letterSpacing: 0.12,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16).r,
            child: SvgPicture.asset(
              'assets/img/explore_w.svg',
              fit: BoxFit.fitWidth,
              width: 1.sw,
              alignment: Alignment.topCenter,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .r
                .copyWith(top: 24),
            child: AnimationLimiter(
              child: Column(
                children: _buildAnimatedBrowseByItems(browseByList),
              ),
            ),
          ),
          SizedBox(height: 200.w),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedBrowseByItems(List browseByList) {
    return List.generate(browseByList.length, (index) {
      final BrowseBy browseBy = browseByList[index];
      final isAllChannel = browseBy.url == AppUrl.browseByAllChannel;

      if (isAllChannel && !(isMdoChannelEnabled && orgBookmarkId.isNotEmpty)) {
        return SizedBox();
      }

      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: _buildBrowseByItem(browseBy),
          ),
        ),
      );
    });
  }

  Widget _buildBrowseByItem(BrowseBy browseBy) {
    return InkWell(
      onTap: () {
        if (browseBy.comingSoon) {
          Navigator.push(context, FadeRoute(page: ComingSoonScreen()));
        } else {
          _generateInteractTelemetryData(contentId: browseBy.telemetryId);
          if (browseBy.url == AppUrl.browseByAllChannel) {
            Navigator.pushNamed(context, browseBy.url,
                arguments: orgBookmarkId);
          } else {
            Navigator.pushNamed(context, browseBy.url);
          }
        }
      },
      child: BrowseByCard(
        browseBy: browseBy,
      ),
    );
  }

  Future<void> _generateInteractTelemetryData({
    String? contentId,
    String? subType,
  }) async {
    final telemetryRepository = TelemetryRepository();

    final eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.learnPageId,
      contentId: contentId ?? "",
      subType: subType ?? "",
      env: TelemetryEnv.learn,
    );

    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
