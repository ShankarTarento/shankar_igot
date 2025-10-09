import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/multi_select_item.dart';
import 'package:karmayogi_mobile/ui/widgets/_interests/_currentCompetencies/competency_filter_items.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../localization/_langs/english_lang.dart';

class FilterCompetencies extends StatefulWidget {
  final List<Set<MultiSelectItem>> competencyTypes;
  final List<Set<MultiSelectItem>> competencyAreas;
  final updateSelection;
  final resetToDefault;
  final applyFilter;

  const FilterCompetencies(
      {Key? key,
      required this.competencyTypes,
      required this.competencyAreas,
      this.updateSelection,
      this.resetToDefault,
      this.applyFilter})
      : super(key: key);

  @override
  State<FilterCompetencies> createState() => _FilterCompetenciesState();
}

class _FilterCompetenciesState extends State<FilterCompetencies> {
  List<Set<MultiSelectItem>>? _filteredCompetencyAreas;
  // final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCompetencyAreas = widget.competencyAreas;
  }

  _filterCompetencies(value) {
    setState(() {
      _filteredCompetencyAreas = widget.competencyAreas
          .where((competency) => competency.first.itemName
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: AppBar(
          titleSpacing: 0,
          foregroundColor: AppColors.greys,
          title: Text(
            AppLocalizations.of(context)!.mStaticFilterBy,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  height: 1.5.w,
                  letterSpacing: 0.12.r,
                ),
          ),
          backgroundColor: AppColors.appBarBackground),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.mStaticType,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      height: 1.5.w,
                      letterSpacing: 0.25.r,
                    ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.competencyTypes.length,
                  itemBuilder: (context, index) {
                    return CompetencyFilterItems(
                      index: index,
                      name: widget.competencyTypes[index].first.itemName ?? '',
                      isSelected:
                          widget.competencyTypes[index].first.isSelected ??
                              false,
                      updateSelection: widget.updateSelection,
                      isCompetencyArea: false,
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Text(
                AppLocalizations.of(context)!.mStaticCompetencyArea,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      height: 1.5.w,
                      letterSpacing: 0.25.r,
                    ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Container(
                height: 48.w,
                margin: EdgeInsets.only(bottom: 16).r,
                child: TextFormField(
                    onChanged: (value) {
                      _filterCompetencies(value);
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: GoogleFonts.lato(fontSize: 14.0.sp),
                    decoration: InputDecoration(
                      fillColor: AppColors.appBarBackground,
                      filled: true,
                      prefixIcon: Icon(Icons.search),
                      contentPadding:
                          EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0).r,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0).r,
                        borderSide: BorderSide(
                          color: AppColors.grey16,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1.0).r,
                        borderSide: BorderSide(
                          color: AppColors.primaryThree,
                        ),
                      ),
                      hintText: EnglishLang.search,
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      counterStyle: TextStyle(
                        height: double.minPositive,
                      ),
                      counterText: '',
                    )),
              ),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCompetencyAreas != null
                      ? _filteredCompetencyAreas!.length
                      : 0,
                  itemBuilder: (context, index) {
                    return CompetencyFilterItems(
                      index: index,
                      name:
                          _filteredCompetencyAreas![index].first.itemName ?? '',
                      isSelected:
                          _filteredCompetencyAreas![index].first.isSelected ??
                              false,
                      updateSelection: widget.updateSelection,
                      isCompetencyArea: true,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      bottomSheet: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 0.35.sw,
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.primaryThree,
                    backgroundColor: AppColors.appBarBackground,
                    minimumSize: const Size.fromHeight(40), // NEW
                  ),
                  onPressed: () {
                    widget.resetToDefault();
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 150.w,
                    child: Text(
                      AppLocalizations.of(context)!.mStaticResetToDefault,
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                height: 1.429.w,
                                letterSpacing: 0.5.r,
                              ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Container(
                width: 0.4.sw,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThree,
                    minimumSize: const Size.fromHeight(40), // NEW
                    side: BorderSide(width: 1, color: AppColors.primaryThree),
                  ),
                  onPressed: () async {
                    await widget.applyFilter();
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.mStaticApply,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          height: 1.429.w,
                          letterSpacing: 0.5.r,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
