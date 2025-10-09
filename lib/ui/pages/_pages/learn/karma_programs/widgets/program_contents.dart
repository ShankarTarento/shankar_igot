import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/playlist_model.dart';
import 'package:provider/provider.dart';

import '../../../../../../models/_models/course_model.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../skeleton/widgets/browse_course_card_skeleton.dart';
import '../../../../../skeleton/widgets/container_skeleton.dart';
import '../../../../../widgets/_learn/browse_card.dart';
import 'no_result_found.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProgramContents extends StatefulWidget {
  final PlayList karmaProgram;

  const ProgramContents({Key? key, required this.karmaProgram})
      : super(key: key);

  @override
  State<ProgramContents> createState() => _ProgramContentsState();
}

class _ProgramContentsState extends State<ProgramContents> {
  late Future<List<Course>> getKarmaProgramContentFuture;
  List<Course> _programContents = [];
  ValueNotifier<List<Course>> _filteredPrograms = ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    _getKarmaProgramDetails();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getKarmaProgramContentFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Course>> programs) {
          if (programs.hasData && programs.data!.length > 0) {
            _programContents = programs.data!;
            _filteredPrograms.value = _programContents;
          }
          return programs.connectionState == ConnectionState.done
              ? (_programContents.length > 0
                  ? Column(
                      children: [
                        _getSearchBar(),
                        ValueListenableBuilder(
                            valueListenable: _filteredPrograms,
                            builder: (BuildContext context,
                                List<Course> filteredPrograms, Widget? child) {
                              return filteredPrograms.length > 0
                                  ? Column(
                                      children: [
                                        AnimationLimiter(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: BouncingScrollPhysics(),
                                            itemCount: filteredPrograms.length,
                                            itemBuilder: (context, index) {
                                              return AnimationConfiguration
                                                  .staggeredList(
                                                position: index,
                                                duration: const Duration(
                                                    milliseconds: 375),
                                                child: SlideAnimation(
                                                  verticalOffset: 50.0,
                                                  child: FadeInAnimation(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                                  bottom: 8)
                                                              .r,
                                                      child: BrowseCard(
                                                          course:
                                                              filteredPrograms[
                                                                  index],
                                                          telemetryPageId:
                                                              TelemetryPageIdentifier
                                                                  .browseByAllKarmaProgramsPageId,
                                                          telemetrySubType:
                                                              TelemetrySubType
                                                                  .karmaPrograms),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20.w)
                                      ],
                                    )
                                  : NoResultFoundWidget();
                            }),
                      ],
                    )
                  : NoResultFoundWidget())
              : _getContentLoadingSkeleton();
        });
  }

  Widget _getSearchBar() {
    return Container(
      height: 40.w,
      margin: const EdgeInsets.all(16.0).w,
      child: TextFormField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.lato(fontSize: 14.0.sp),
          onChanged: (value) => _filterProgramContents(value),
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
              borderSide: BorderSide(
                color: AppColors.appBarBackground,
                width: 1.0.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.appBarBackground),
            ),
            hintText: AppLocalizations.of(context)!.mStaticSearch,
            hintStyle: GoogleFonts.lato(
                color: AppColors.grey40,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400),
            counterStyle: TextStyle(
              height: double.minPositive,
            ),
            counterText: '',
          )),
    );
  }

  Widget _getContentLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0).w,
      child: Column(
        children: [
          ContainerSkeleton(height: 40.w),
          SizedBox(height: 16.w),
          BrowseCourseCardSkeleton(),
          BrowseCourseCardSkeleton()
        ],
      ),
    );
  }

  _filterProgramContents(String value) {
    _filteredPrograms.value = _programContents
        .where((programContent) => programContent.name
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();
  }

  Future<void> _getKarmaProgramDetails() async {
    String proxyUrl = ApiUrl.playListReadUrl;

    getKarmaProgramContentFuture =
        Provider.of<LearnRepository>(context, listen: false)
            .getKarmaProgramContents(
      PrimaryCategory.program,
      url: proxyUrl
          .replaceAll('<playListKey>', widget.karmaProgram.playListKey)
          .replaceAll('<orgId>', widget.karmaProgram.orgId),
    );
  }
}
