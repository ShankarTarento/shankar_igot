import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/filter/competency_area_filter.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/filter/competency_type_filter.dart';
import 'package:karmayogi_mobile/ui/widgets/silverappbar_delegate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/index.dart';

// import 'package:provider/provider.dart';
// import './../../../models/index.dart';
// import './../../../respositories/index.dart';
// import './../../../constants/index.dart';
// import './../../../ui/pages/index.dart';
// import './../../../ui/widgets/index.dart';
// import './../../../localization/index.dart';

class BrowseByCompetencyFilter extends StatefulWidget {
  // static const route = AppUrl.knowledgeResourcesPage;
  final allCompetencyTypes, allCompetencyArea;
  final ValueChanged<Map>? parentAction1;
  final ValueChanged<Map>? selectedFilterIndex;
  final int? selectedTypeIndex;
  final int? selectedAreaIndex;
  final ValueChanged<bool>? isAppliedFilter;
  BrowseByCompetencyFilter(
      {this.allCompetencyTypes,
      this.allCompetencyArea,
      this.parentAction1,
      this.selectedFilterIndex,
      this.selectedTypeIndex,
      this.selectedAreaIndex,
      this.isAppliedFilter});

  @override
  _BrowseByCompetencyFilterState createState() {
    return _BrowseByCompetencyFilterState();
  }
}

class _BrowseByCompetencyFilterState extends State<BrowseByCompetencyFilter>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  List tabNames = [EnglishLang.competencyType, EnglishLang.competencyArea];
  String? _selectedType;
  String? _selectedArea;
  Map _selectedFilter = {'type': EnglishLang.all, 'area': EnglishLang.all};
  // bool _isAppliedFilter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabNames = [
      AppLocalizations.of(context)!.mStaticCompetencyArea,
      AppLocalizations.of(context)!.mCompetencyTheme
    ];
    super.didChangeDependencies();
  }

  void _selectedCompetencyFilter(Map filter) {
    setState(() {
      _selectedType = filter['type'] != null ? filter['type'] : EnglishLang.all;
      _selectedArea = filter['area'] != null ? filter['area'] : EnglishLang.all;
      _selectedFilter = {
        'type': _selectedType,
        'area': _selectedArea,
      };
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          leading: BackButton(color: AppColors.greys60),
          title: Padding(
              padding: const EdgeInsets.only(left: 10).r,
              child: Text(
                AppLocalizations.of(context)!.mStaticFilterBy,
                style: GoogleFonts.montserrat(
                  color: AppColors.greys87,
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w600,
                ),
              )),
        ),
        // Tab controller
        body: DefaultTabController(
            length: tabNames.length,
            child: SafeArea(
                child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverPersistentHeader(
                    delegate: SilverAppBarDelegate(
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.darkBlue,
                              width: 2.0.w,
                            ),
                          ),
                        ),
                        indicatorColor: AppColors.appBarBackground,
                        labelPadding: EdgeInsets.only(top: 0.0).r,
                        unselectedLabelColor: AppColors.greys60,
                        labelColor: AppColors.primaryThree,
                        labelStyle: GoogleFonts.lato(
                          fontSize: 10.0.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.lato(
                          fontSize: 10.0.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: [
                          for (var tabItem in tabNames)
                            Container(
                              width: 1.sw / 2,
                              // padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Tab(
                                child: Text(
                                  Helper.capitalizeEachWordFirstCharacter(
                                      tabItem),
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        controller: _controller,
                      ),
                    ),
                    pinned: true,
                    floating: false,
                  ),
                ];
              },

              // TabBar view
              body: Container(
                color: AppColors.lightBackground,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    CompetencyTypeFilter(
                      allCompetencyTypes: widget.allCompetencyTypes,
                      selected: _selectedCompetencyFilter,
                      selectedIndex: widget.selectedFilterIndex,
                      appliedIndex: widget.selectedTypeIndex,
                    ),
                    CompetencyAreaFilter(
                      allCompetencyArea: widget.allCompetencyArea,
                      selected: _selectedCompetencyFilter,
                      selectedIndex: widget.selectedFilterIndex,
                      appliedIndex: widget.selectedAreaIndex,
                    )
                    // AllResourcesPage(
                    //     knowledgeResources: _knowledgeResources,
                    //     parentAction: fetchData),
                    // SavedResourcesPage(
                    //     knowledgeResources: _knowledgeResources,
                    //     parentAction: fetchData),
                  ],
                ),
              ),
            ))),
        bottomNavigationBar: BottomAppBar(
            child: Container(
          height: 60.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () => setState(() {
                        widget.parentAction1!({});
                        widget.selectedFilterIndex!({
                          'type': 0,
                          'area': 0,
                        });
                        widget.isAppliedFilter!(false);
                        // widget.parentAction({'id': '', 'position': ''});
                        Navigator.pop(context);
                      }),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0).r,
                    child: SizedBox(
                      width: 150.w,
                      child: Text(
                        AppLocalizations.of(context)!.mStaticResetToDefault,
                        style: GoogleFonts.lato(
                          color: AppColors.primaryThree,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 16.0).r,
                child: Container(
                  width: 180.w,
                  color: AppColors.primaryThree,
                  child: TextButton(
                    onPressed: () => setState(() {
                      widget.isAppliedFilter!(true);
                      widget.parentAction1!(_selectedFilter);
                      Navigator.pop(context);
                    }),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryThree,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8).r,
                      )
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.mStaticApply,
                      style: GoogleFonts.lato(
                        color: AppColors.appBarBackground,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
