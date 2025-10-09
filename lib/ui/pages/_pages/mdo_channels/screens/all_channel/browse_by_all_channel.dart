import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/browse_by_all_provider_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/mdo_channel_data_model.dart';
import 'widgets/channel_list_item_widget.dart';
import '../mdo_channel_screen/mdo_channel_screen.dart';

class BrowseByAllChannel extends StatefulWidget {
  final int? index;
  final bool isFromHome;
  final String orgBookmarkId;

  BrowseByAllChannel(
      {Key? key, this.index, this.isFromHome = false, this.orgBookmarkId = ''})
      : super(key: key);

  @override
  _BrowseByAllChannelState createState() {
    return new _BrowseByAllChannelState();
  }
}

class _BrowseByAllChannelState extends State<BrowseByAllChannel>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final _textController = TextEditingController();

  List<MdoChannelDataModel> _channelCard = [];
  Future<List<MdoChannelDataModel>>? _channelResponseData;
  List<MdoChannelDataModel> _filteredChannelCard = [];
  bool _scrollStatus = true;
  bool _pageInitialized = false;

  String dropdownValue = EnglishLang.ascentAtoZ;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  _scrollListener() {
    if (isScroll != _scrollStatus) {
      setState(() {
        _scrollStatus = isScroll;
      });
    }
  }

  bool get isScroll {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _textController.addListener(_filterChannels);
    _channelResponseData = _getListOfChannels();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByAllMdoChannelPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByAllMdoChannelPageId,
        env: EnglishLang.learn,
        subType: TelemetrySubType.mdoChannel);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<List<MdoChannelDataModel>> _getListOfChannels() async {
    _channelCard = await Provider.of<LearnRepository>(context, listen: false)
        .getListOfMdoChannels(widget.orgBookmarkId);
    _channelCard.removeWhere((element) => element.channel == null);

    if (!_pageInitialized) {
      setState(() {
        _filteredChannelCard = _channelCard;
        _pageInitialized = true;
        _sortChannels(dropdownValue);
      });
    }
    return _channelCard;
  }

  _filterChannels() {
    String value = _textController.text;
    setState(() {
      _filteredChannelCard = _channelCard
          .where((channel) => channel.channel
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  void _sortChannels(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredChannelCard
            .sort((a, b) => a.channel!.trim().compareTo(b.channel!.trim()));
      } else
        _filteredChannelCard
            .sort((a, b) => b.channel!.trim().compareTo(a.channel!.trim()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _buildLayout());
  }

  AppBar _appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.greys60),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4).w,
              child: Text(
                AppLocalizations.of(context)!.mStaticExploreByAllChannels,
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12.w),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
            margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8).w,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: FutureBuilder(
                  future: _channelResponseData,
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_channelCard.length > 0) _toolBarView(),
                            _channelListView(),
                          ],
                        ),
                      );
                    } else {
                      return BrowseByAllProviderSkeleton();
                    }
                  }),
            )),
      ),
    );
  }

  Widget _toolBarView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).r,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 0.65.sw,
              height: 40.w,
              child: TextFormField(
                  controller: _textController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.lato(fontSize: 14.0.sp),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.appBarBackground,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24.sp,
                      color: AppColors.greys60,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8).w,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.w),
                      borderSide: BorderSide(
                        color: AppColors.appBarBackground,
                        width: 1.0.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.w),
                      borderSide: BorderSide(color: AppColors.appBarBackground),
                    ),
                    hintText:
                        AppLocalizations.of(context)!.mStaticSearchChannels,
                    hintStyle: GoogleFonts.lato(
                        color: AppColors.greys,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400),
                    counterStyle: TextStyle(
                      height: double.minPositive,
                    ),
                    counterText: '',
                  )),
            ),
            Container(
              width: 0.2.sw,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                border: Border.all(
                  color: AppColors.grey16,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.all(Radius.circular(100.w)),
              ),
              child: DropdownButton<String>(
                alignment: Alignment.center,
                value: dropdownValue,
                icon: Icon(
                  Icons.sort,
                  color: AppColors.greys60,
                  size: 24.sp,
                ),
                hint: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.mCommonSortBy,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
                style: TextStyle(
                  color: AppColors.greys87,
                ),
                underline: Container(
                  color: AppColors.greys87,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return dropdownItems.map<Widget>((String item) {
                    return Row(
                      children: [
                        Text(
                          item,
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    );
                  }).toList();
                },
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                  _sortChannels(dropdownValue);
                },
                items:
                    dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelListView() {
    return AnimationLimiter(
      child: Column(
        children: List.generate(
          _filteredChannelCard.length,
          (index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).w,
                    child: ChannelListItemWidget(
                      onTap: () {
                        _generateInteractTelemetryData(
                          contentId: TelemetryIdentifier.cardContent,
                          subType: TelemetrySubType.mdoChannel,
                          clickId: _filteredChannelCard[index].rootOrgId ?? '',
                          objectType: _filteredChannelCard[index].channel ?? '',
                        );
                        Navigator.push(
                          context,
                          FadeRoute(
                            page: MdoChannelScreen(
                              telemetryPageIdentifier: TelemetryPageIdentifier
                                  .browseByMdoChannelPageId,
                              channelName:
                                  _filteredChannelCard[index].channel ?? '',
                              orgId:
                                  _filteredChannelCard[index].rootOrgId ?? '',
                            ),
                          ),
                        );
                      },
                      cardData: _filteredChannelCard[index],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _generateInteractTelemetryData(
      {required String contentId,
      required String subType,
      String clickId = '',
      String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.channelPageUri,
        contentId: contentId,
        subType: subType,
        clickId: clickId,
        objectType: objectType,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
