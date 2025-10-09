import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/models/_models/learning_week_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/home_national_learning_week_card.dart';
import 'package:provider/provider.dart';

class LearningWeekCard extends StatefulWidget {
  final List configData;
  const LearningWeekCard({super.key, required this.configData});

  @override
  State<LearningWeekCard> createState() => _LearningWeekCardState();
}

class _LearningWeekCardState extends State<LearningWeekCard> {
  LearningWeekModel? nationalLearningWeekData;
  LearningWeekModel? stateLearningWeekData;

  void initState() {
    getLearningWeek();

    super.initState();
  }

  void getLearningWeek() async {
    try {
      for (var e in widget.configData) {
        if (e['type'] == null) {
          debugPrint("Error: Missing 'type' key in configData element.");
          continue;
        }

        switch (e['type']) {
          case WidgetConstants.nationalLearningWeek:
            try {
              nationalLearningWeekData = LearningWeekModel.fromJson(e);
            } catch (error) {
              debugPrint("Error parsing National Learning Week: $error");
            }
            break;

          case WidgetConstants.stateLearningWeek:
            try {
              Profile? profileDetails =
                  Provider.of<ProfileRepository>(context, listen: false)
                      .profileDetails;

              if (profileDetails == null) {
                List<Profile> profileData =
                    await Provider.of<ProfileRepository>(context, listen: false)
                        .getProfileDetailsById("");

                if (profileData.isNotEmpty) {
                  profileDetails = profileData.first;
                } else {
                  debugPrint("Error: Profile data is empty.");
                  return;
                }
              }

              if (e['data'] != null) {
                List<LearningWeekModel> allStateLearningWeekData = [];
                for (var data in e['data'] as List) {
                  try {
                    allStateLearningWeekData
                        .add(LearningWeekModel.fromJson(data));
                  } catch (error) {
                    debugPrint("Error parsing LearningWeekModel data: $error");
                  }
                }

                if (allStateLearningWeekData.isNotEmpty) {
                  String? rootOrgId =
                      profileDetails.rawDetails['profileDetails']?['refRootOrg']
                              ?['orgId'] ??
                          profileDetails.rawDetails['rootOrgId'];

                  if (rootOrgId != null) {
                    for (var element in allStateLearningWeekData) {
                      if (element.orgId == rootOrgId) {
                        stateLearningWeekData = element;
                        break;
                      }
                    }
                  }
                }
              }
            } catch (error) {
              debugPrint("Error processing State Learning Week: $error");
            }
            break;

          default:
            debugPrint("Unknown type: ${e['type']}");
        }
      }
    } catch (error) {
      debugPrint("Error in getLearningWeek method: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        nationalLearningWeekData != null && nationalLearningWeekData!.enabled
            ? HomeLearningWeekCard(
                learningWeekData: nationalLearningWeekData!,
              )
            : stateLearningWeekData != null && stateLearningWeekData!.enabled
                ? HomeLearningWeekCard(
                    learningWeekData: stateLearningWeekData!,
                  )
                : SizedBox(),
      ],
    );
  }
}
