import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:karmayogi_mobile/env/env.dart';

const String IOS_BUNDLE_ID = 'in.nic.igot.karmayogi';

const String ANDROID_BUNDLE_ID = 'com.igot.karmayogibharat';
const String APP_VERSION = '4.2.11';
const String APP_NAME = 'iGOT Karmayogi';
const String APP_ENVIRONMENT = Environment.prod;
const String TELEMETRY_ID = 'api.sunbird.telemetry';
const String DEFAULT_CHANNEL = 'igot';
// ignore: non_constant_identifier_names
String TELEMETRY_PDATA_ID = Platform.isIOS
    ? Env.telemetryPdataId.replaceAll("android", "ios")
    : Env.telemetryPdataId;
// ignore: non_constant_identifier_names
String TELEMETRY_PDATA_PID =
    Platform.isIOS ? 'karmayogi-mobile-ios' : 'karmayogi-mobile-android';
const String TELEMETRY_EVENT_VERSION = '3.0';
const String APP_DOWNLOAD_FOLDER = '/storage/emulated/0/Download';
const String ASSESSMENT_FITB_QUESTION_INPUT =
    '<input style=\"border-style:none none solid none\" />';
const String APP_STORE_ID = '6443949491';

const String supportEmail = "mission[dot]karmayogi[at]gov[dot]in";
bool get modeProdRelease =>
    (APP_ENVIRONMENT == Environment.prod) && kReleaseMode;

// ignore: non_constant_identifier_names
String PARICHAY_CODE_VERIFIER = Env.parichayCodeVerifier;
// ignore: non_constant_identifier_names
String PARICHAY_CLIENT_ID = Env.parichayClientId;
// ignore: non_constant_identifier_names
String PARICHAY_CLIENT_SECRET = Env.parichayClientSecret;

// ignore: non_constant_identifier_names
String PARICHAY_KEYCLOAK_CLIENT_SECRET = Env.parichayKeycloakSecret;

// ignore: non_constant_identifier_names
String X_CHANNEL_ID = Env.xChannelId;

// ignore: non_constant_identifier_names
String SOURCE_NAME = Env.sourceName;

// ignore: non_constant_identifier_names
String SPV_ADMIN_ROOT_ORG_ID = Env.spvAdminRootOrgId;

late String mdoID;
late String mdo;
bool enableCuratedProgram = true;

/// To enable netcore SDK
const bool isNetcoreActive = true;
const int RATING_LIMIT = 11;
const int RATING_DURATION_IN_DAYS = 15;
const int CLAP_DURATION = 60;
const int CACHE_EXPIRY_DURATION = 10;
const String blendedProgramFormVersion = "1.1";

// New home
const double COURSE_CARD_HEIGHT = 310.0;
const double COURSE_CARD_WIDTH = 245.0;
const double DISCUSS_CARD_HEIGHT = 148.0;
const int DISCUSS_CARD_DISPLAY_LIMIT = 5;
const BUTTON_ANIMATION_DURATION = Duration(milliseconds: 200);
const int CLAPS_WEEK_COUNT = 4;
const int SHOW_ALL_CHECK_COUNT = 12;
const int SHOW_ALL_DISPLAY_COUNT = 1;
const int CERTIFICATE_COUNT = 4;
const double SHOWALL_CARD_HEIGHT = 310.0;
const double SHOWALL_CARD_WIDTH = 150.0;
const int SHOW2 = 2;
const int SHOW3 = 3;
const int SHOW4 = 4;
const int SHOW6 = 6;

// App default design size
const double DEFAULT_DESIGN_WIDTH = 424;
const double DEFAULT_DESIGN_HEIGHT = 896;

// App default design size
const double IPAD_DESIGN_WIDTH = 900;
const double IPAD_DESIGN_HEIGHT = 1400;

//CBP plan
const int CBP_COURSE_ON_TIMELINE_LIST_LIMIT = 2;
const int CBP_UPCOMING_SHOW_DATE_DIFF = 30;
const List<String> CBP_STATS_FILTER = [
  CBPFilterTimeDuration.last3month,
  CBPFilterTimeDuration.last6month,
  CBPFilterTimeDuration.lastYear
];

//Karma point
const int KARMAPOINT_DISPLAY_LIMIT = 3;
const int KARMAPOINT_READ_LIMIT = 6;
const int COURSE_RATING_POINT = 2;
const int COURSE_COMPLETION_POINT = 5;
const int ACBP_COURSE_COMPLETION_POINT = 15;
const int FIRST_ENROLMENT_POINT = 5;
const int KARMPOINT_AWARD_LIMIT_TO_COURSE = 4;

//Competency
const int SUBTHEME_VIEW_COUNT = 2;
const int COMPETENCY_ITEM_DISPLAY_LIMIT = 4;

//Trending courses
const int COURSE_LISTING_PAGE_LIMIT = 100;

//event
const int EVENT_COMPLETION_PERCENTAGE = 50;
const int EVENT_EXPLORE_LIST_LIMIT = 3;
const double EVENT_COMPLETION_DURATION = 180;

//TOC
const int RATING_DEFAULT_PERCENTAGE = 50;
const int COURSE_COMPLETION_PERCENTAGE = 100;

enum CourseCategory { programs, courses, certifications, under_30_mins }

enum EnrolmentStatus { enrolled, withdrawn, waiting, removed, rejected }

enum ProgressUpdateType { timeBased, percentageBased }

enum WFBlendedProgramStatus {
  INITIATE,
  SEND_FOR_MDO_APPROVAL,
  SEND_FOR_PC_APPROVAL,
  APPROVED,
  REJECTED,
  WITHDRAWN,
  WITHDRAW,
  REMOVED
}

enum WFBlendedWithdrawCheck {
  SEND_FOR_MDO_APPROVAL,
  SEND_FOR_PC_APPROVAL,
  REMOVED,
  REJECTED
}

enum FieldTypes { radio, textarea, rating, checkbox, text }

enum WFBlendedProgramAprovalTypes {
  oneStepPCApproval,
  oneStepMDOApproval,
  twoStepMDOAndPCApproval,
  twoStepPCAndMDOApproval
}

enum EnvironmentValues { igot, igotqa, igotuat, igotprod }

class AppLocale {
  static const hindi = "hi";
  static const english = "en";
  static const tamil = "ta";
  static const assamese = "as";
  static const bengali = "bn";
  static const telugu = "te";
  static const kannada = "kn";
  static const malaylam = "ml";
  static const gujarati = "gu";
  static const oriya = "or";
  static const punjabi = 'pa';
  static const marathi = "mr";
}

class RegistrationRequests {
  static const String STATE = 'INITIATE';
  static const String ACTION = 'INITIATE';
  static const String POSITION_SERVICE_NAME = 'position';
  static const String ORGANISATION_SERVICE_NAME = 'organisation';
  static const String DOMAIN_SERVICE_NAME = 'domain';
  static const String IGOT_DEPT_NAME = 'iGOT';
}

class ProfileRequests {
  static const String withdrawAction = 'WITHDRAW';
  static const String sendForApprovalState = 'SEND_FOR_APPROVAL';
  static const String profileServiceName = 'profile';
}

class RegExpressions {
  static RegExp specialChar = RegExp(r'[^\w\s]');
  static RegExp validEmail = RegExp(
      r"[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*@((?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?){2,}\.){1,3}(?:\w){2,}");
  static RegExp validPhone = RegExp(
      r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$');
  static RegExp htmlValidator = RegExp(r'<[^>]+>');
  static RegExp inputTagRegExp =
      RegExp(r'<input\b[^>]*>', caseSensitive: false);
  static RegExp unicodeSpecialChar = RegExp(r'[^\p{L}\p{N}_]+', unicode: true);
  static RegExp registrationLink = RegExp(r"\/crp\/\d+\/\d+$");
  static RegExp extractOrgIdFromRegisterLink = RegExp(r"\/crp\/\d+\/(\d+)$");
  static RegExp alphabetsWithDot = RegExp(r"^[a-zA-Z\s.]+$");
  static RegExp alphabetsAndSpaces = RegExp(r'^[A-Za-z ]+$');
  static RegExp mulipleSpace = RegExp(r'^[^\s]+( [^\s]+)*( *)$');
  static RegExp alphaNumeric = RegExp(r'^[A-Za-z0-9 ]+$');
  static RegExp alphabets = RegExp(r"^[a-zA-Z]+$");
  static RegExp numeric = RegExp(r'\d');
  static RegExp alphabetWithAmbresandDotCommaSlashBracket =
      RegExp(r'^[a-zA-Z\s(),.&/]+$');
  static RegExp alphaNumWithDotCommaBracketHyphen =
      RegExp(r'^[a-zA-Z0-9\s(),.-]+$');
  static RegExp alphabetWithDotCommaBracket = RegExp(r'^[a-zA-Z\s(),.]+$');
  static RegExp startAndEndWithSpace = RegExp(r"^\s|\s$");
  static RegExp multipleConsecutiveSpace = RegExp(r'\s{2,}');
  static RegExp alphabetsWithAmbresandHyphenSlashParentheses =
      RegExp(r'^[a-zA-Z\s()&\-/]+$');
  static RegExp alphabetsWithAmbresandParentheses = RegExp(r'^[a-zA-Z\s()&]+$');
  static RegExp alphabetWithAmbresandDotCommaSlashBracketHyphen =
      RegExp(r'^[a-zA-Z\s(),.&/\-]+$');
}

class VegaConfiguration {
  static bool isEnabled = false;
}

class iGotClient {
  static const String androidClientId = 'android';
  static const String parichayClientId = 'parichay-oAuth-mobile';
}

class Roles {
  static const String spv = 'SPV_ADMIN';
  static const String mdo = 'MDO_ADMIN';
  static const String mentor = 'mentor';
}

class Environment {
  static const String dev = '.env.dev';
  static const String qa = '.env.qa';
  static const String uat = '.env.uat';
  static const String prod = '.env.prod';
}

class ChartType {
  static const String profileViews = 'profileViews';
  static const String platformUsage = 'platformUsage';
}

class AppDatabase {
  static const String name = 'igot_karmayogi';
  static const String telemetryEventsTable = 'telemetry_events';
  static const String feedbackTable = 'user_feedback';
  static const String apiDataTable = 'api_data';
}

class ChatBotLocale {
  static const hindi = "hi";
  static const english = "en";
}

class EventType {
  static const karmayogiTalks = "Karmayogi Talks";
  static const webinar = "Webinar";
  static const karmayogiSaptah = "Karmayogi Saptah";
  static const rajyaKarmayogiSaptha = "Rajya Karmayogi Saptah";
}

class FaqConfigType {
  static const info = 'IN';
  static const issue = 'IS';
}

class AcademicDegree {
  static const String graduation = 'graduation';
  static const String postGraduation = 'postGraduation';
}

class DegreeType {
  static const String xStandard = 'X_STANDARD';
  static const String xiiStandard = 'XII_STANDARD';
  static const String graduate = 'GRADUATE';
  static const String postGraduate = 'POSTGRADUATE';
}

class EMimeTypes {
  static const String collection = 'application/vnd.ekstep.content-collection';
  static const String html = 'application/vnd.ekstep.html-archive';
  static const String ilp_fp = 'application/ilpfp';
  static const String iap = 'application/iap-assessment';
  static const String m4a = 'audio/m4a';
  static const String mp3 = 'audio/mpeg';
  static const String mp4 = 'video/mp4';
  static const String m3u8 = 'application/x-mpegURL';
  static const String interaction = 'video/interactive';
  static const String pdf = 'application/pdf';
  static const String png = 'image/png';
  static const String quiz = 'application/quiz';
  static const String dragDrop = 'application/drag-drop';
  static const String htmlPicker = 'application/htmlpicker';
  static const String webModule = 'application/web-module';
  static const String webModuleExercise = 'application/web-module-exercise';
  static const String youtube = 'video/x-youtube';
  static const String handsOn = 'application/integrated-hands-on';
  static const String rdbmsHandsOn = 'application/rdbms';
  static const String classDiagram = 'application/class-diagram';
  static const String channel = 'application/channel';
  static const String collectionResource = 'resource/collection';
  // Added on UI Onl;
  static const String certification = 'application/certification';
  static const String playlist = 'application/playlist';
  static const String unknown = 'application/unknown';
  static const String externalLink = 'text/x-url';
  static const String youtubeLink = 'video/x-youtube';
  static const String assessment = 'application/json';
  static const String newAssessment = 'application/vnd.sunbird.questionset';
  static const String survey = 'application/survey';
  static const String offlineSession = 'application/offline';
  static const String offline = 'application/offline';
}

class EDisplayContentTypes {
  static const String assessment = 'ASSESSMENT';
  static const String audio = 'AUDIO';
  static const String certification = 'CERTIFICATION';
  static const String channel = 'Channel';
  static const String classDiagram = 'CLASS_DIAGRAM';
  static const String course = 'COURSE';
  static const String dDefault = 'DEFAULT';
  static const String dragDrop = 'DRAG_DROP';
  static const String externalCertification = 'EXTERNAL_CERTIFICATION';
  static const String externalCourse = 'EXTERNAL_COURSE';
  static const String goals = 'GOALS';
  static const String handsOn = 'HANDS_ON';
  static const String iap = 'IAP';
  static const String instructorLed = 'INSTRUCTOR_LED';
  static const String interactiveVideo = 'INTERACTIVE_VIDEO';
  static const String knowledgeArtifact = 'KNOWLEDGE_ARTIFACT';
  static const String module = 'MODULE';
  static const String pdf = 'PDF';
  static const String html = 'HTML';
  static const String playlist = 'PLAYLIST';
  static const String program = 'PROGRAM';
  static const String quiz = 'QUIZ';
  static const String resource = 'RESOURCE';
  static const String rdbmsHands_on = 'RDBMS_HANDS_ON';
  static const String video = 'VIDEO';
  static const String webModule = 'WEB_MODULE';
  static const String webPage = 'WEB_PAGE';
  static const String youtube = 'YOUTUBE';
  static const String knowledgeBoard = 'Knowledge Board';
  static const String learningJourney = 'Learning Journeys';
}

class Azure {
  static const String host = 'https://karmayogi.nic.in/';
  static const String bucket = 'content-store';
}

class QuestionTypes {
  static const String singleAnswer = 'singleAnswer';
  static const String multipleAnswer = 'multipleAnswer';
}

class AssessmentQuestionType {
  static const String radioType = 'mcq-sca';
  static const String radioWeightageType = 'mcq-sca-tf';
  static const String checkBoxType = 'mcq-mca';
  static const String checkBoxWeightageType = 'mcq-mca-w';
  static const String matchCase = 'mtf';
  static const String fitb = 'fitb';
  static const String ftb = 'ftb';
}

class IntentType {
  static const String direct = 'direct';
  static const String discussions = 'discussions';
  static const String competencyList = 'competencylist';
  static const String contact = 'contact';
  static const String course = 'course';
  static const String tags = 'tags';
  static const String learners = 'learners';
  static const String visualisation = 'visualisations';
  static const String coursesCompetency = 'courses_with_competency';
  static const String competencyCourses = 'competency_courses';
  static const String images = 'images';
  static const String links = 'links';
  static const String youtubeVideo = 'youtubeVideo';
  static const String dateFormat = 'dd-MM-yyyy';
  static const String dateFormat2 = 'd MMM, y';
  static const String dateFormat3 = 'd MMM, y  – HH:mm ';
  static const String dateFormat4 = "yyyy-MM-dd";
  static const String dateFormat5 = "yyyy-MM-dd HH:mm:ss";
  static const String dateFormat6 = "E, d MMM, yy";
  static const String dateFormatYearOnly = 'y';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ssZ';
  static const String dateFormat7 = 'EEE, MMM d h:mm a';
  static const String achievementDateFormat = 'MMM yyyy';
}

class PrimaryCategory {
  static const String practiceAssessment = "Practice Question Set";
  static const String finalAssessment = "Course Assessment";
  static const String preEnrolmentAssessment = "Pre Enrolment Assessment";
  static const String program = 'program';
  static const String course = 'course';
  static const String learningResource = 'Learning resource';
  static const String standaloneAssessment = 'standalone assessment';
  static const String blendedProgram = 'Blended Program';
  static const String event = 'event';

  static const String curatedProgram = 'Curated Program';
  static const String moderatedCourses = 'Moderated Course';
  static const String moderatedProgram = 'Moderated Program';
  static const String moderatedAssessment = 'Moderated Assessment';
  static const String inviteOnlyProgram = 'Invite-Only Program';
  static const String offlineSession = 'Offline Session';
  static const String inviteOnlyAssessment = 'Invite-Only Assessment';
  static const String recentlyAdded = 'recentlyAdded';
  static const String trendingAcrossDepartment = 'trendingAcrossDepartment';
  static const String externalCourse = 'External Course';
  static const String caseStudy = 'Case Study';
  static const String teachersResource = 'Teachers Resource';
  static const String referenceResource = "Reference Resource";
  static const String comprehensiveAssessmentProgram =
      "Comprehensive Assessment Program";
  static const String multilingualCourse = 'Multilingual Course';
  static const String landingPageResource = 'Landing Page Resource';
  static List<String> programCategoriesList = [
    PrimaryCategory.comprehensiveAssessmentProgram.toLowerCase(),
    PrimaryCategory.curatedProgram.toLowerCase(),
    PrimaryCategory.moderatedProgram.toLowerCase(),
    PrimaryCategory.inviteOnlyProgram.toLowerCase(),
    PrimaryCategory.blendedProgram.toLowerCase()
  ];
  static List<String> dynamicCertProgramCategoriesList = [
    PrimaryCategory.curatedProgram.toLowerCase()
  ];
}

class DeviceOS {
  static const String android = 'Android';
  static const String iOS = 'iOS';
}

class AttendenceMarking {
  static const int bufferHour = 1;
}

class GetStarted {
  static const int autoCloseDuration = 3000;
  static const String finished = 'true';
  static const String reset = 'false';
}

class NPS {
  static const String enable = 'true';
  static const String disable = 'false';
}

class CBPFilterCategory {
  static const String contentType = "Content Type";
  static const String status = "Status";
  static const String timeDuration = 'Time Duration';
  static const String competencyArea = 'Competency Area';
  static const String provider = 'Provider';
  static const String competencyTheme = "Competency Theme";
  static const String competencySubtheme = 'Competency Sub-Theme';
}

class CBPCourseStatus {
  static const String inProgress = "In Progress";
  static const String notStarted = "Not started";
  static const String completed = 'Completed';
}

class CBPFilterTimeDuration {
  static const String upcoming7days = "Upcoming 7 days";
  static const String upcoming30days = "Upcoming 30 days";
  static const String upcoming3months = "Upcoming 3 months";
  static const String upcoming6months = "Upcoming 6 months";
  static const String lastWeek = "Last week";
  static const String lastMonth = "Last month";
  static const String last3month = "Last 3 months";
  static const String last6month = "Last 6 months";
  static const String lastYear = "Last year";
}

class OperationTypes {
  static const String couseCompletion = 'COURSE_COMPLETION';
  static const String firstEnrolment = 'FIRST_ENROLMENT';
  static const String rating = 'RATING';
  static const String firstLogin = 'FIRST_LOGIN';
}

class CompetencyAreas {
  static const String behavioural = 'behavioural';
  static const String functional = 'functional';
  static const String domain = 'domain';
}

class CompetencyFilterCategory {
  static const String competencyArea = "Competency Area";
  static const String competencyTheme = "Competency Theme";
  static const String competencySubtheme = 'Competency Sub-Theme';
}

class CompetencyFacetsCategory {
  static const String competencyAreaFacetV6 =
      "competencies_v6.competencyAreaName";
  static const String competencyThemeFacetV6 =
      "competencies_v6.competencyThemeName";
  static const String competencySubthemeFacetV6 =
      "competencies_v6.competencySubThemeName";
  static const String competencyAreaFacetV5 = "competencies_v5.competencyArea";
  static const String competencyThemeFacetV5 =
      "competencies_v5.competencyTheme";
  static const String competencySubthemeFacetV5 =
      "competencies_v5.competencySubTheme";
}

class CertificateType {
  static const String png = "png";
  static const String pdf = "pdf";
}

class FeedCategory {
  static const String nps = 'NPS2';
  static const String inAppReview = 'InAppReview';
}

class TocButtonStatus {
  static const String enroll = "enroll";
  static const String start = "start";
  static const String resume = "resume";
  static const String startAgain = "start again";
  static const String takeTest = "take test";
}

class AssessmentQuestionStatus {
  static const String MarkForReviewAndNext = "Mark for review & next";
  static const String clearResponse = "Clear Response";
  static const String saveAndNext = "Save & Next";
  static const String nextSection = "Next Section";
  static const String notAnswered = "Not answered";
  static const String correct = "Correct";
  static const String wrong = "Wrong";
  static const String incorrect = "Incorrect";
  static const String all = "All";
  static const String unattempted = "Unattempted";
  static const String retakeNotAllowed = "Retake Not Allowed";
  static const String previous = "Previous";
}

class UserProfileStatus {
  static const String verified = 'VERIFIED';
  static const String notVerified = 'NOT-VERIFIED';
  static const String notMyUser = 'NOT-MY-USER';
}

class UserProfileVisibilityControls {
  static const int publicAccess = 0;
  static const int privateAccess = 1;
  static const int connectionOnlyAccess = 10;
}

class VerifidKarmayogi {
  static const String verifiedKarmayogiYes = 'Yes';
  static const String verifiedKarmayogiNo = 'No';
}

class AssessmentType {
  static const questionWeightage = 'questionWeightage';
  static const optionalWeightage = 'optionalWeightage';
}

class ApiTtl {
  static const Duration compositeSearch = Duration(minutes: 30);
  static const Duration recentlyAddedProgram = Duration(minutes: 10);
  static const Duration recentlyAddedCourse = Duration(minutes: 10);
  static const Duration getListOfProviders = Duration(hours: 4);
  static const Duration getRatingReviews = Duration(hours: 1);

  static const Duration getBatchList = Duration(minutes: 1);
  static const Duration getHomeConfig = Duration(minutes: 5);
  static const Duration getCbplan = Duration(minutes: 10);
  static const Duration getProfileDetails = Duration(milliseconds: 100);
  static const Duration getExternalCourses = Duration(hours: 1);
  static const Duration getSearchConfig = Duration(minutes: 2);
  static const Duration getRecommendedCourse = Duration(hours: 4);
  static const Duration approvedDomainTtl = Duration(minutes: 30);
  static const Duration userEnrollmentSummaryTtl = Duration(seconds: 10);
  static const Duration getDesignationMaster = Duration(hours: 4);
  static const Duration generateAIRecommendation = Duration(hours: 8);
  static const Duration getOrgDetails = Duration(hours: 4);
  static const Duration search = Duration(minutes: 30);
  static const Duration eventSummary = Duration(minutes: 5);
  static const Duration stateAndDistrict = Duration(hours: 4);
  static const Duration searchConfig = Duration(minutes: 5);
  static const Duration getFaqLanguage = Duration(hours: 24);
  static const Duration getFaqData = Duration(minutes: 24);
  static const Duration orgDetails = Duration(minutes: 0);
  static const Duration getInReviewFields = Duration(minutes: 15);
  static var getMyLearningEnrolmentlist = Duration(minutes: 5);
}

class DateFormatString {
  static const String ddMMyyyy = 'dd-MM-yyyy';
  static const String yyyyMMdd = 'yyyy-MM-dd';
  static const String ddMonthyyyy = 'dd MMM yyyy';
  static const String MMMddyyyy = 'MMM dd, yyyy';
}

class ApiResponseMsg {
  static const String userNotEnrolled = 'User not enrolled into the course';
}

class AssessmentSectionType {
  static const String paragraph = 'paragraph';
  static const String section = 'section';
}

class InviteOnlyBatchStatus {
  static const String batchNotStarted = 'batchNotStarted';
}

class BlendedProgramProfileSurvey {
  static const String existingData = 'Available user filled iGOT profile';
  static const String allData = 'Full iGOT profile';
  static const String customData = 'Custom iGOT profile';
}

class BroadCastEvent {
  static const String Default = 'default';
  static const String InAppMessage = 'InAppMessage';
  static const String PushNotification = 'PushNotification';
}

class EnrollmentAPIFilter {
  static const String all = 'All';
  static const String inProgress = 'In-Progress';
  static const String completed = 'Completed';
}

class FileExtension {
  static const String pdf = '.pdf';
  static const String doc = '.doc';
  static const String docx = '.docx';
  static const String pptx = '.pptx';
  static const String ppt = '.ppt';
  static const String text = '.txt';
}

typedef IntCallback = void Function(int value);

class HiveConstants {
  static const String hiveBoxName = 'igot_api_cache';
}
