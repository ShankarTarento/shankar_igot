import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/browse_by_all_provider_skeleton.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/_constants/app_routes.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/helper.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../../learn/courses_by_provider.dart';
import '../../skeleton/browse_by_featured_provider_skeleton.dart';
import '../microsite_screen/ati_cti_microsites_screen.dart';

class BrowseByAllProvider extends StatefulWidget {
  static const route = AppUrl.browseByAllProviderPage;
  final int? index;
  final bool isFromHome;

  BrowseByAllProvider({Key? key, this.index, this.isFromHome = false})
      : super(key: key);

  @override
  _BrowseByAllProviderState createState() {
    return new _BrowseByAllProviderState();
  }
}

class _BrowseByAllProviderState extends State<BrowseByAllProvider>
    with WidgetsBindingObserver {
  ScrollController? _scrollController;
  final _textController = TextEditingController();

  List<ProviderCardModel> _providerCard = [];
  late Future<List<ProviderCardModel>> _providerResponseFuture;
  late Future<List<ProviderCardModel>> _featuredProviderResponseFuture;
  List<ProviderCardModel> _filteredProviderCard = [];
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
    return _scrollController!.hasClients &&
        _scrollController!.offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);
    _textController.addListener(_filterProviders);
    _providerResponseFuture = _getListOfProviders();
    _featuredProviderResponseFuture = _getListOfFeaturedProviders();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByAllProviderPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByAllProviderPageUri,
        env: EnglishLang.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<List<ProviderCardModel>> _getListOfProviders() async {
    _providerCard = await Provider.of<LearnRepository>(context, listen: false)
        .getListOfProviders();
    _providerCard.removeWhere((element) => element.name == null);
    _providerCard.removeWhere((element) => element.orgId == null);

    if (!_pageInitilized) {
      setState(() {
        _filteredProviderCard = _providerCard;
        _pageInitilized = true;
        _sortProviders(dropdownValue);
      });
    }
    return _providerCard;
  }

  Future<List<ProviderCardModel>> _getListOfFeaturedProviders() async {
    try {
      Map<String, dynamic>? data = AppConfiguration.homeConfigData;
      if (data != null && data['micrositeMobile'] != null) {
        String featuredProviderDoId = Helper.getid(data['micrositeMobile']);
        if (featuredProviderDoId != '') {
          List<ProviderCardModel> _featuredProviderCard =
              await Provider.of<LearnRepository>(context, listen: false)
                  .getListOfFeaturedProviders(featuredProviderDoId);

          _featuredProviderCard.removeWhere((element) => element.name == null);
          _featuredProviderCard.removeWhere((element) => element.orgId == null);

          return _featuredProviderCard;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('An error occurred while fetching featured providers: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  _filterProviders() {
    String value = _textController.text;
    setState(() {
      _filteredProviderCard = _providerCard
          .where((provider) => provider.name
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  void _sortProviders(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredProviderCard
            .sort((a, b) => a.name!.trim().compareTo(b.name!.trim()));
      } else
        _filteredProviderCard
            .sort((a, b) => b.name!.trim().compareTo(a.name!.trim()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController!.removeListener(_scrollListener);
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _buildLayout());
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight.w,
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
                AppLocalizations.of(context)!.mStaticExploreByAllProviders,
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
            margin: EdgeInsets.only(top: 8, bottom: 8).w,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _featuredProviderView(),
                  _allProviderView(),
                ],
              ),
            )),
      ),
    );
  }

  Widget _featuredProviderView() {
    return FutureBuilder(
        future: _featuredProviderResponseFuture,
        builder: (context, AsyncSnapshot<List<ProviderCardModel>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List<ProviderCardModel> _featuredProviderList = snapshot.data ?? [];
            return (_featuredProviderList.isNotEmpty)
                ? _featuredProviderListView(_featuredProviderList)
                : SizedBox.shrink();
          } else {
            return BrowseByFeaturedProviderSkeleton();
          }
        });
  }

  Widget _allProviderView() {
    return FutureBuilder(
        future: _providerResponseFuture,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Container(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
              ).w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_providerCard.length > 0) _toolBarView(),
                  _providerListView(),
                ],
              ),
            );
          } else {
            return BrowseByAllProviderSkeleton();
          }
        });
  }

  Widget _toolBarView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 0.56.sw,
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
                      size: 24.w,
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
                        AppLocalizations.of(context)!.mStaticSearchProviders,
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
              width: 0.25.sw,
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
                  size: 24.w,
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
                  _sortProviders(dropdownValue);
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

  Widget _providerListView() {
    return AnimationLimiter(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16).w,
        child: Column(children: [
          for (int i = 0; i < _filteredProviderCard.length; i++)
            AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _providerListItemView(
                    providerCardModel: _filteredProviderCard[i],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _featuredProviderListView(
      List<ProviderCardModel> _featuredProviderList) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16).w,
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.mMicroSiteFeaturedProviders,
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: 0.12.w,
                height: 1.5.w),
          ),
        ),
        Container(
          height: 168.w,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 8).w,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _featuredProviderList.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                        child: Container(
                      width: 250.w,
                      margin: EdgeInsets.only(
                        left: (index == 0) ? 24 : 8,
                        right: (index == _featuredProviderList.length - 1)
                            ? 24
                            : 0,
                      ).w,
                      child: _providerListItemView(
                        providerCardModel: _featuredProviderList[index],
                      ),
                    )),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _providerListItemView({dynamic providerCardModel}) {
    return InkWell(
        onTap: () {
          _generateInteractTelemetryData(
              contentId: TelemetryIdentifier.cardContent,
              clickId: providerCardModel.orgId,
              objectType: providerCardModel.name);
          if ((providerCardModel.orgId ?? '').toString() != '') {
            Navigator.push(
              context,
              FadeRoute(
                  page: AtiCtiMicroSitesScreen(
                providerName: providerCardModel.name,
                orgId: providerCardModel.orgId,
              )),
            );
          } else {
            Navigator.push(
              context,
              FadeRoute(
                  page: CoursesByProvider(
                providerCardModel.clientName,
                isCollection: false,
                collectionId: '',
              )),
            );
          }
        },
        child: Container(
            height: 155.w,
            width: double.maxFinite,
            margin: EdgeInsets.only(bottom: 8).w,
            padding: EdgeInsets.all(16).w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
              color: AppColors.appBarBackground,
            ),
            child: Column(
              children: [
                (providerCardModel.logoUrl != null)
                    ? MicroSiteImageView(
                        imgUrl: providerCardModel.logoUrl.toString().trim(),
                        height: 62.w,
                        width: double.maxFinite,
                        fit: BoxFit.contain,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100.w),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(2).w,
                          child: Container(
                            height: 60.w,
                            width: 60.w,
                            decoration: BoxDecoration(
                              color: AppColors.networkBg[
                                  Random().nextInt(AppColors.networkBg.length)],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                Helper.getInitialsNew(
                                    providerCardModel.name ?? ''),
                                style: GoogleFonts.lato(
                                    color: AppColors.avatarText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                Padding(
                    padding: EdgeInsets.only(top: 16).w,
                    child: Text(
                      providerCardModel.name != null
                          ? providerCardModel.name.toString().trim()
                          : '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ))
              ],
            )));
  }

  void _generateInteractTelemetryData(
      {String? contentId,
      String? subType,
      String? clickId,
      String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.learnPageId,
        contentId: contentId ?? '',
        subType: subType ?? '',
        env: TelemetryEnv.learn,
        objectType: objectType);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
