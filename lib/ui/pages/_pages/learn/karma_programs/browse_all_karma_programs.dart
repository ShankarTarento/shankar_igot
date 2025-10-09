import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/home_screen_components/karma_program_strip/repository/karmaprogram_repository.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/playlist_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/no_result_found.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/browse_by_all_provider_skeleton.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/_constants/app_routes.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../util/telemetry_repository.dart';

// ignore: must_be_immutable
class BrowseAllKarmaPrograms extends StatefulWidget {
  List<PlayList>? karmaPrograms;

  static const route = AppUrl.browseAllKarmaProgramsPage;

  BrowseAllKarmaPrograms({Key? key, this.karmaPrograms}) : super(key: key);

  @override
  _BrowseAllKarmaProgramsState createState() {
    return new _BrowseAllKarmaProgramsState();
  }
}

class _BrowseAllKarmaProgramsState extends State<BrowseAllKarmaPrograms>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final _textController = TextEditingController();

  List<PlayList> _karmaPrograms = [];
  late Future<List<PlayList>> _karmaProgramsResponseData;
  List<PlayList> _filteredKarmaPrograms = [];
  bool _scrollStatus = true;
  bool _pageInitilized = false;

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
    _textController.addListener(_filterKarmaPrograms);
    _karmaProgramsResponseData = _getListOfkarmaPrograms();
    _generateImpressionTelemetryData();
  }

  Future<List<PlayList>> _getListOfkarmaPrograms() async {
    _karmaPrograms = widget.karmaPrograms ??
        await KarmaprogramRepository.getKarmaProgram(
          apiUrl: "/api/playList/v2/search",
          request: {
            "filterCriteriaMap": {"type": "program"},
            "pageNumber": 0,
            "pageSize": 20,
            "orderBy": "createdOn",
            "orderDirection": "ASC",
            "facets": ["category", "orgId"]
          },
        );

    // _providerCard.removeWhere((element) => element.title == null);

    if (!_pageInitilized) {
      setState(() {
        _filteredKarmaPrograms = _karmaPrograms;
        _pageInitilized = true;
      });
    }
    return _karmaPrograms;
  }

  _filterKarmaPrograms() {
    String value = _textController.text;
    setState(() {
      _filteredKarmaPrograms = _karmaPrograms
          .where((karmaProgram) => karmaProgram.title
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  void _sortKarmaPrograms(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredKarmaPrograms
            .sort((a, b) => a.title.trim().compareTo(b.title.trim()));
      } else
        _filteredKarmaPrograms
            .sort((a, b) => b.title.trim().compareTo(a.title.trim()));
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
        toolbarHeight: kToolbarHeight.w,
        elevation: 0.w,
        titleSpacing: 0.w,
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
                AppLocalizations.of(context)!.mLearnExploreAllKarmaPrograms,
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
                  future: _karmaProgramsResponseData,
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data!.length > 0) {
                        return _karmaPrograms.length > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _toolBarView(),
                                  _karmaProgramListView(),
                                ],
                              )
                            : NoResultFoundWidget();
                      } else {
                        return NoResultFoundWidget();
                      }
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
                        AppLocalizations.of(context)!.mLearnSearchKarmaPrograms,
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
              height: 40.w,
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
                hint: Padding(
                  padding: const EdgeInsets.only(left: 0).w,
                  child: Container(
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
                ),
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
                  _sortKarmaPrograms(dropdownValue);
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

  Widget _karmaProgramListView() {
    return AnimationLimiter(
      child: _filteredKarmaPrograms.length > 0
          ? Column(children: [
              for (int i = 0; i < _filteredKarmaPrograms.length; i++)
                AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 475),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _karmaProgramListItemView(
                        karmaProgram: _filteredKarmaPrograms[i],
                      ),
                    ),
                  ),
                ),
            ])
          : NoResultFoundWidget(),
    );
  }

  Widget _karmaProgramListItemView({required PlayList karmaProgram}) {
    return InkWell(
        onTap: () {
          _generateInteractTelemetryData(
              clickId: TelemetryIdentifier.cardContent,
              contentId: karmaProgram.playListKey,
              subType: TelemetrySubType.karmaPrograms,
              objectType: karmaProgram.type);
          Navigator.pushNamed(context, AppUrl.karmaProgramDetailsv2,
              arguments: karmaProgram);
        },
        child: Container(
            height: 115.w,
            width: double.maxFinite,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16).w,
            padding: EdgeInsets.all(4).w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.w)),
              color: AppColors.darkBlue,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(30.w, 20.w),
                      topRight: Radius.elliptical(30.w, 20.w),
                      bottomLeft: Radius.circular(4.w),
                      bottomRight: Radius.circular(4.w)),
                  child: karmaProgram.imgUrl != null
                      ? MicroSiteImageView(
                          imgUrl: karmaProgram.imgUrl!,
                          width: 0.425.sw,
                          height: double.maxFinite,
                          fit: BoxFit.cover)
                      : Image.asset(
                          'assets/img/image_placeholder.jpg',
                          width: 0.425.sw,
                          height: double.maxFinite,
                          fit: BoxFit.cover,
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16).r,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(karmaProgram.title.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: AppColors.appBarBackground,
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 8.w),
                        Text(
                            '${karmaProgram.childrens != null ? karmaProgram.childrens!.length : 0} ${AppLocalizations.of(context)!.mHomeCardPrograms}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: AppColors.appBarBackground,
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByAllKarmaProgramsPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByAllKarmaProgramsPageUri,
        subType: TelemetrySubType.karmaPrograms,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _generateInteractTelemetryData(
      {required String contentId,
      required String subType,
      String clickId = '',
      String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByAllKarmaProgramsPageId,
        contentId: contentId,
        subType: subType,
        clickId: clickId,
        objectType: objectType,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
