import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<String> RECOMMENDEDCOURSEPILLS({required BuildContext context}) => [
      AppLocalizations.of(context)!.mCourseAvailable,
      AppLocalizations.of(context)!.mCommoninProgress,
      AppLocalizations.of(context)!.mCommoncompleted
    ];

List<String> IGOTPLAN({required BuildContext context}) => [
      AppLocalizations.of(context)!.mIgotPlans,
      AppLocalizations.of(context)!.mMySpacePeerLearning,
      AppLocalizations.of(context)!.mMySpaceIgotAI
    ];
