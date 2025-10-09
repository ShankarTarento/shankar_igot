import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/home_screen_components/karma_program_strip/repository/karmaprogram_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/browse_all_karma_programs.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/karma_program_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/karma_program_strip_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import '../../../constants/_constants/app_routes.dart';
import '../../../models/_models/playlist_model.dart';

class KarmaProgramsStrip extends StatefulWidget {
  final ContentStripModel stripData;
  const KarmaProgramsStrip({
    required this.stripData,
    Key? key,
  }) : super(key: key);

  @override
  State<KarmaProgramsStrip> createState() => _KarmaProgramStripState();
}

class _KarmaProgramStripState extends State<KarmaProgramsStrip> {
  late Future<List<PlayList>> getKarmaProgramsFuture;
  @override
  void initState() {
    super.initState();
    getKarmaPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 8).r,
        child: FutureBuilder(
            future: getKarmaProgramsFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<PlayList>> karmaPrograms) {
              if (karmaPrograms.connectionState == ConnectionState.waiting) {
                return KarmaProgramStripWidgetSkeleton();
              }
              if (karmaPrograms.data != null &&
                  karmaPrograms.data!.length > 0) {
                return Column(
                  children: [
                    SizedBox(
                      height: 32.w,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16).r,
                      child: TitleWidget(
                          title: widget.stripData.title!.getText(context),
                          showAllCallBack: karmaPrograms.data!.length > 2
                              ? () {
                                  Navigator.push(
                                      context,
                                      FadeRoute(
                                          page: BrowseAllKarmaPrograms(
                                        karmaPrograms: karmaPrograms.data!,
                                      )));
                                  HomeTelemetryService
                                      .generateInteractTelemetryData(
                                          TelemetryIdentifier.showAll,
                                          subType:
                                              TelemetrySubType.karmaPrograms,
                                          isObjectNull: true);
                                }
                              : null),
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    Container(
                        height: 220.w,
                        width: double.infinity.w,
                        margin: const EdgeInsets.only(top: 5, bottom: 15).r,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: karmaPrograms.data!.length > 8
                              ? 8
                              : karmaPrograms.data!.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(
                                      context, AppUrl.karmaProgramDetailsv2,
                                      arguments: karmaPrograms.data![index]);
                                  HomeTelemetryService
                                      .generateInteractTelemetryData(
                                          karmaPrograms
                                              .data![index].playListKey,
                                          primaryCategory:
                                              karmaPrograms.data![index].type,
                                          subType:
                                              TelemetrySubType.karmaPrograms,
                                          clickId:
                                              TelemetryIdentifier.cardContent);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16).r,
                                  child: KarmaProgramCard(
                                    karmaProgram: karmaPrograms.data![index],
                                  ),
                                ));
                          },
                        )),
                  ],
                );
              }
              return SizedBox();
            }));
  }

  void getKarmaPrograms() {
    getKarmaProgramsFuture = KarmaprogramRepository.getKarmaProgram(
      apiUrl: widget.stripData.apiUrl,
      request: widget.stripData.request ?? {},
    );
  }
}
