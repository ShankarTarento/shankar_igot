import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import './../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseFilters extends StatefulWidget {
  final String? filterName;
  final List? items;
  final List? selectedItems;
  final ValueChanged<Map> parentAction1;
  final ValueChanged<String> parentAction2;

  CourseFilters(
      {Key? key,
      this.filterName,
      this.items,
      this.selectedItems,
      required this.parentAction1,
      required this.parentAction2})
      : super(key: key);
  @override
  _CourseFiltersState createState() => _CourseFiltersState();
}

class _CourseFiltersState extends State<CourseFilters> {
  Map? data;

  void _updateFilter(i) {
    data = {'filter': widget.filterName, 'item': widget.items?[i]};
    widget.parentAction1(data!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.greys87,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0).r,
                child: Text(
                  widget.filterName ?? "",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                ),
              )
            ],
          ),
        ),
        // Tab controller
        body: SingleChildScrollView(
          child: Container(
            // height: MediaQuery.of(context).size.height,
            constraints: BoxConstraints(minHeight: 1.sh),
            child: Column(children: <Widget>[
              for (int i = 0; i < widget.items!.length; i++)
                Container(
                    margin: const EdgeInsets.only(bottom: 1).r,
                    child: ListTile(
                      title: Text(
                        Helper.capitalize(
                            widget.items![i].toString().toLowerCase()),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      onTap: () => {_updateFilter(i)},
                      selected: widget.filterName == EnglishLang.resourceType
                          ? (widget.selectedItems!.contains(widget.items![i])
                              ? true
                              : false)
                          : (widget.selectedItems!.contains(widget.items![i] ==
                                      EnglishLang.moderatedCourse
                                  ? widget.items![i]
                                  : (widget.items![i].toLowerCase()))
                              ? true
                              : false),
                      selectedTileColor: AppColors.selectedTile,
                    )),
            ]),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
          height: 60.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  widget.parentAction2(widget.filterName ?? "");
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  AppLocalizations.of(context)!.mStaticResetToDefault,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Container(
                  width: 180.w,
                  color: AppColors.primaryThree,
                  child: TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryThree,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .mCompetenciesContentTypeApplyFilters,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
