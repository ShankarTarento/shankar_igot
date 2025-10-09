import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/feedback/models/information_card_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedbackDatabase {
  static const String name = 'igot_karmayogi';
  static const String userFeedbackTable = 'user_feedback';
}

class FeedbackColors {
  static const Color background = Colors.white;
  static const Color black87 = Color.fromRGBO(0, 0, 0, 0.87);
  static const Color black60 = Color.fromRGBO(0, 0, 0, 0.60);
  static const Color black40 = Color.fromRGBO(0, 0, 0, 0.40);
  static const Color black16 = Color.fromRGBO(0, 0, 0, 0.16);
  static const Color black08 = Color.fromRGBO(0, 0, 0, 0.08);
  static const Color black04 = Color.fromRGBO(0, 0, 0, 0.04);
  static const Color textFieldHint = Color.fromRGBO(0, 0, 0, 0.40);
  static const Color textFieldBorder = Color.fromRGBO(0, 0, 0, 0.16);
  static const Color textFieldDescText = Color.fromRGBO(0, 0, 0, 0.60);
  static const Color ratedColor = Color.fromRGBO(246, 153, 83, 1);
  static const Color unRatedColor = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color customBlue = Color.fromRGBO(39, 117, 184, 1);
  static const Color lightGrey = Color.fromRGBO(245, 245, 245, 1);
  static const Color primaryBlue = Color.fromRGBO(39, 117, 184, 1);
  static const Color primaryBlueBg = Color.fromRGBO(39, 117, 184, 0.1);
  static const Color negativeLight = Color.fromRGBO(209, 57, 36, 1);
  static const Color positiveLight = Color.fromRGBO(29, 137, 35, 1);
  static const Color negativeLightBg = Color.fromRGBO(209, 57, 36, 0.1);
  static const Color positiveLightBg = Color.fromRGBO(29, 137, 35, 0.1);
  static const Color avatarRed = Color.fromRGBO(196, 84, 78, 1);
  static const Color blueCard = Color.fromRGBO(2, 75, 163, 1);
  static const Color avatarGreen = Color.fromRGBO(78, 158, 135, 1);
  static const Color ghostWhite = Color.fromRGBO(248, 244, 249, 1);
}

class WallOfFameAssets {
  static const IconData up = Icons.arrow_drop_up_sharp;
  static const IconData down = Icons.arrow_drop_down_sharp;
  static const String crown = 'assets/img/rank_one_crown.png';
  static const String kp_logo = 'assets/img/kp_icon.svg';
}

class FeedbackApiEndpoint {
  static const String baseUrl = 'https://rain.tarento.com';
  static const String getSurveyDetails = '/api/forms/getFormById?id=';
  static const String submitSurvey = '/api/forms/saveFormSubmit';
  static const String submitContentSurvey = '/api/forms/v1/saveFormSubmit';
  static const String getSubmittedFeedback = '/api/forms/getAllApplications';
}

class FeedbackPageRoute {
  static const String microSurveysPage = '/microSurveysPage';
  static const String microSurveyPage = '/microSurveyPage';
  static const String surveyDetails = '/surveyDetails';
  static const String surveyResults = '/surveyResults';
}

class QuestionType {
  static const String radio = 'radio';
  static const String checkbox = 'checkbox';
  static const String rating = 'rating';
  static const String text = 'text';
  static const String email = 'email';
  static const String textarea = 'textarea';
  static const String numeric = 'numeric';
  static const String date = 'date';
  static const String boolean = 'boolean';
  static const String heading = 'heading';
  static const String separator = 'separator';
  static const String dropdown = 'dropdown';
  static const String phoneNumber = 'phonenumber';
}

class MicroSurveyType {
  static const String microSurveyType1 = 'Micro survey scenario 1';
  static const String microSurveyType2 = 'Micro survey scenario 2';
  static const String microSurveyType3 = 'Micro survey scenario 3';
}

class RegistrationType {
  static const int resendOtpTimeLimit = 60;
  static const int resendEmailOtpTimeLimit = 60;
}

const MICRO_SURVEY_ID = '1617090681344';
// const MICRO_SURVEY_ID = '1623155373000';

List<InformationCardModel> scenario1summary(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.list,
          information: '3 ${AppLocalizations.of(context)!.mCommonQuestions}',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.replay,
          information: AppLocalizations.of(context)!.mStaticUnlimitedRetakes,
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.timer,
          information:
              '${AppLocalizations.of(context)!.mCommonTotal} 5 ${AppLocalizations.of(context)!.mStaticMinutes}',
          iconColor: AppColors.primaryThree),
    ];
List<InformationCardModel> practiceScenario1summary(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.list,
          information: '3 ${AppLocalizations.of(context)!.mCommonQuestions}',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.replay,
          information: AppLocalizations.of(context)!.mStaticUnlimitedRetakes,
          iconColor: AppColors.primaryThree),
      // InformationCardModel(
      //     scenarioNumber: 3,
      //     icon: Icons.timer,
      //     information: 'Total 5 mins',
      //     iconColor: AppColors.primaryThree),
    ];
List<InformationCardModel> scenario2summary(context) => const [
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.timer,
          information: '60 seconds per question',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.list,
          information: '3 questions',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.replay,
          information: 'Retake available after 1 month',
          iconColor: AppColors.primaryThree)
    ];

List<InformationCardModel> scenario3summary(context) => const [
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.timer,
          information: 'No time limit',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.list,
          information: '3 questions',
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.timer,
          information: 'Unlimited takes allowed',
          iconColor: AppColors.primaryThree)
    ];
List<InformationCardModel> scenario1info(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: 'If time runs out answers will be autosubmitted',
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information:
              'Skipped questions can be attempted again before submitting',
          iconColor: AppColors.greys60)
    ];
List<InformationCardModel> practiceScenario1info(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
      // InformationCardModel(
      //     scenarioNumber: 1,
      //     icon: Icons.info,
      //     information: 'If time runs out answers will be autosubmitted',
      //     iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!
              .mSkippedQuestionsAttemptedBeforeSubmiting,
          iconColor: AppColors.greys60)
    ];

List<InformationCardModel> scenario2info(context) => [
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mTimeRunsOut,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information:
              AppLocalizations.of(context)!.mUnansweredConsideredIncorrect,
          iconColor: AppColors.greys60)
    ];

List<InformationCardModel> scenario3info(context) => [
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mScoresWillNotBeStored,
          iconColor: AppColors.greys60)
    ];
List<InformationCardModel> scenario4summary(context) => const [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.list,
          information: '3 questions',
          iconColor: AppColors.darkBlue),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.timer_outlined,
          information: 'Total 5 mins',
          iconColor: AppColors.darkBlue),
    ];
List<InformationCardModel> practiceScenario4summary(context) => const [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.list,
          information: '3 questions',
          iconColor: AppColors.darkBlue),
    ];

List<InformationCardModel> practiceScenario4Info(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mStaticUnlimitedRetakes,
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information: AppLocalizations.of(context)!
              .mSkippedQuestionsAttemptedBeforeSubmiting,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
    ];
List<InformationCardModel> scenarioV2Info(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mStaticUnlimitedRetakes,
          iconColor: AppColors.primaryThree),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mTimeRunsOut,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.info,
          information: AppLocalizations.of(context)!
              .mSkippedQuestionsAttemptedBeforeSubmiting,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 4,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
    ];
List<InformationCardModel> scenario4Info(context) => [
      InformationCardModel(
          scenarioNumber: 1,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mTimeRunsOut,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 2,
          icon: Icons.info,
          information: AppLocalizations.of(context)!
              .mSkippedQuestionsAttemptedBeforeSubmiting,
          iconColor: AppColors.greys60),
      InformationCardModel(
          scenarioNumber: 3,
          icon: Icons.info,
          information: AppLocalizations.of(context)!.mNoNegativeMarking,
          iconColor: AppColors.greys60),
    ];
