import 'package:karmayogi_mobile/env/env.dart';

class ApiUrl {
  // Mocky
  // static const tempBaseUrl = 'https://run.mocky.io/v3/';

  static String baseUrl = Env.portalBaseUrl;
  static String fracBaseUrl = Env.fracBaseUrl;
  static String apiKey = Env.apiKey;
  static String prodApiKey = Env.prodApiKey;
  // Login
  static String loginRedirectUrl = '$baseUrl/oauth2callback';

  static String parichayBaseUrl = Env.parichayBaseUrl;
  static String preProdBaseUrl = 'https://karmayogi.nic.in';
  static String revokeToken = '/pnv1/salt/api/oauth2/revoke';

  static String parichayAuthLoginUrl = '$parichayBaseUrl/pnv1/oauth2/authorize';
  static String parichayLoginRedirectUrl =
      '$baseUrl/apis/public/v8/parichay/callback';

  static String loginWebUrl = '$baseUrl/auth';
  static String signUpWebUrl = '$baseUrl/public/signup';
  static String loginShortUrl =
      '/auth/realms/sunbird/protocol/openid-connect/auth';
  static String loginUrl =
      '/auth/realms/sunbird/protocol/openid-connect/auth?redirect_uri=$loginRedirectUrl&response_type=code&scope=offline_access&client_id=android';
  static const keyCloakLogin =
      '/auth/realms/sunbird/protocol/openid-connect/token';
  static const keyCloakLogout =
      '/auth/realms/sunbird/protocol/openid-connect/logout';
  static const getParichayToken = '/pnv1/salt/api/oauth2/token';
  static const refreshToken = '/api/auth/v1/refresh/token';
  static const createNodeBBSession = '/api/discussion/user/v1/create';
  // static const basicUserInfo = '/api/user/v2/read/';
  static const basicUserInfo = '/api/user/v5/read/';
  static const getUserDetails = '/api/private/user/v1/search';
  static const getParichayUserInfo = '/pnv1/salt/api/oauth2/userdetails';
  static const updateLogin = '/api/user/v1/updateLogin';
  static const signUp = '/api/user/v1/ext/signup';
  static const privacyPolicy = '/public/privacy-policy?mode=mobile';

  // Not in use
  static const wToken = '/apis/proxies/v8/api/user/v2/read';

  // Nps rating APIs
  static const getFormId = '/api/forms/getFormById?id=';
  static const getFormFeed = '/api/user/v1/feed/';
  static const submitForm = '/api/forms/v1/saveFormSubmit';
  static const deleteFeed = '/api/user/feed/v1/delete';

  // Discussion hub new
  static const trendingDiscussion = '/api/discussion/popular?page=';
  static const recentDiscussion = '/api/discussion/recent';
  static const trendingTags = '/api/discussion/tags';
  static const discussionDetail = '/api/discussion/topic/';
  static const categoryList = '/api/discussion/categories';
  static const myDiscussions = '/api/discussion/user/';
  static const filterDiscussionsByTag = '/api/discussion/tags/';
  static const courseDiscussions = '/api/discussion/forum/v2/read';
  static const courseDiscussionList = '/api/discussion/category/list';

  // Post APIs currently not working
  static const replyDiscussion = '/api/discussion/v2/topics/';
  static const saveDiscussion = '/api/discussion/v2/topics';
  static const deleteDiscussion = '/api/discussion/v2/topics/';
  static const vote = '/api/discussion/v2/posts/';
  static const savedPosts = '/api/discussion/user/';
  static const bookmark = '/api/discussion/v2/posts/';
  static const updatePost = '/api/discussion/v2/posts/';
  static const filterDiscussionsByCategory = '/api/discussion/category/';

  /// Network hub new
  static const getSuggestions = '/api/connections/profile/find/recommended';

  // Network hub

  static const getProfileDetails =
      '/apis/protected/v8/user/profileRegistry/getUserRegistryById';
  static const getProfileDetailsByUserId = '/api/user/v1/read/';
  static const updateProfileDetailsWithoutPatch = '/api/user/private/v1/update';
  static const updateProfileDetails = '/api/user/v1/extPatch';
  static const updateProfileDetailsV2 = '/api/user/otp/v2/extPatch';
  static const approvedDomains = '/api/user/v1/email/approvedDomains';
  static const generateOTP = '/api/otp/v1/generate';
  static const generateOTPv3 = '/api/otp/v3/generate';
  static const verifyOTP = '/api/otp/v1/verify';
  static const verifyOTPv3 = '/api/otp/v3/verify';
  static const generateExtOTP = '/api/otp/ext/v1/generate';
  static const getInReviewFields =
      '/api/workflow/v2/userWFApplicationFieldsSearch';
  // static const updateUserProfileDetails =
  //     '/apis/protected/v8/user/profileDetails/updateUser';
  static const getCurrentCourse =
      '/apis/protected/v8/content/lex_auth_013125450758234112286?hierarchyType=detail';
  static const getBadges = '/apis/protected/v8/user/badge';
  static const getNationalities = '/assets/static-data/nationality.json';
  static const getCuratedHomeConfig =
      '/assets/configurations/feature/curated-home.json';
  static const getLearnHubConfig = '/assets/configurations/page/learn.json';
  static const getHomeConfig = '/assets/configurations/page/home.json';
  static const getNetcoreConfig = '/assets/configurations/netcore.json';
  static const getMasterCompetencies =
      '/assets/common/master-competencies.json';
  static const getSurveyForm = '/api/forms/getFormById?id=';
  static const getProfileEditConfig =
      '/assets/configurations/feature/edit-profile.json';
  static const getLanguages = '/api/masterData/v1/languages';
  static const getProfilePageMeta = '/api/masterData/v1/profilePageMetaData';
  static const getDepartments = '/api/portal/v1/listDeptNames';
  static const getDegrees = '/assets/static-data/degrees.json';
  static const getIndustries = '/assets/static-data/industries.json';
  static const getDesignationsAndGradePay = '/api/designation/search';
  static const getEhrmsDetails = '/api/ehrms/details';
  static const getServicesAndCadre = '/assets/static-data/govtOrg.json';
  static const getCadre = '/api/masterData/v1/profilePageMetaData';
  static const autoEnrollBatch = '/api/v1/autoenrollment';
  static const enrollProgramBatch = '/api/openprogram/v1/enrol';
  static const requestBlendedProgramBatchCountUrl =
      '/api/workflow/blendedprogram/enrol/status/count';
  static const requestBlendedProgramEnrollUrl =
      '/api/workflow/blendedprogram/enrol';
  static const requestBlendedProgramUnenroll =
      '/api/workflow/blendedprogram/unenrol';
  static const workflowBlendedProgramSearch =
      '/api/workflow/blendedprogram/user/search';
  static const getEnrollDetails = '/api/user/autoenrollment/';
  static const submitBlendedProgramSurvey = '/api/forms/v1/saveFormSubmit';
  static const enrollToCuratedProgram = '/api/curatedprogram/v1/enrol';
  static const getInsights = '/api/insights';

  /// learner leaderboard
  static const getLeaderboardData = '/api/walloffame/learnerleaderboard';

  // Network hub
  static const peopleYouMayKnow = '/api/connections/profile/find/suggests';
  static const connectionRequest =
      '/api/connections/profile/fetch/requests/received';

  static const postConnectionReq = '/api/connections/add';
  static const getMyConnections = '/api/connections/profile/fetch/established';
  static const connectionRejectAccept = '/api/connections/update';
  static const fromMyMDO = '/api/connections/profile/find/recommended';
  static const getUsersByEndpoint = '/api/user/v1/search';
  static const getRequestedConnections =
      '/api/connections/profile/fetch/requested';
  static const String getRecommendedUsers =
      "/api/connections/v3/connections/recommended";

  static const String getRecommendedMentors =
      "/api/connections/v3/connections/recommended/mentors";

  static const String getBlockedUser =
      "/api/connections/v2/connections/requests/blocked";

  static const String getConnectionsCount =
      "/api/connections/user/v1/network/connections/list";
  static const String blockUser = "/api/connections/block";

  // Knowledge Resources
  static const getKnowledgeResources =
      '/fracapis/frac/getAllNodes?type=KNOWLEDGERESOURCE&bookmarks=true';
  static const bookmarkKnowledgeResource = '/fracapis/frac/bookmarkDataNode';
  static const getKnowledgeResourcesPositions =
      '/fracapis/frac/getAllNodes?type=POSITION';
  static const knowledgeResourcesFilterByPosition =
      '/fracapis/frac/filterByMappings';

  // Learn
  static const getListOfCompetencies = '/fracapis/frac/searchNodes';
  static const getAllCompetencies = '/api/searchBy/competency';
  static const getAllCompetenciesV6 = '/api/searchBy/v2/competency';

  static const getCoursesByCompetencies = '/api/content/v1/search';
  static const getTrendingCourses = '/api/composite/v1/search';
  static const getExternalCourses = '/api/cios/v1/search/content';
  static const getExteranlCourseContentsUrl = '/api/cios/v1/content/read/';
  static const getExtCourseListByUserId = '/api/cios-enroll/v1/listbyuserid/';
  static const getUserDataOnExtCourse =
      '/api/cios-enroll/v1/readby/useridcourseid/#courseId';
  static const enrollExtCourse = '/api/cios-enroll/v1/create';
  static const getTrendingCoursesV4 = '/api/composite/v4/search';
  static const getCoursesByCollection = 'api/v8/action/content/v3/hierarchy/';

  static const getMyLearningEnrolmentlist =
      '/api/course/v2/user/enrollment/list/:wid?orgdetails=orgName,email&licenseDetails=name,description,url&fields=contentType,name,channel,mimeType,appIcon,resourceType,identifier,trackable,objectType,organisation,pkgVersion,version,trackable,courseCategory,posterImage,duration,creatorLogo,license,programDuration,avgRating,additionalTags,competencies_v5&batchDetails=name,endDate,startDate,status,enrollmentType,createdBy,certificates,batchAttributes&retiredCoursesEnabled=true';
  // Enrollment list based course id
  static const getCourseEnrollDetailsByIds =
      '/api/course/v4/user/enrollment/details/';
  // Get Enrollment Summary
  static const getEnrollmentSummary = '/api/course/v4/user/enrollment/summary/';
  // Get Enrollment list by filter
  static const getEnrollmentListByFilter =
      '/api/course/v4/user/enrollment/list/';

  static const getCourseDetails = '/api/course/v1/hierarchy/';
  static const getCourseLearners = '/api/v2/resources/user/cohorts/activeusers';
  static const getCourseAuthors = '/api/v2/resources/user/cohorts/authors';
  static const getCourseProgress = '/apis/proxies/v8/read/content-progres/';
  static const getAllTopics = '/api/v1/catalog/';
  static const updateContentProgress = '/api/course/v1/content/state/update';
  static const readContentProgress = '/api/course/v1/content/state/read';
  static const getCourseCompletionCertificate =
      '/api/certreg/v2/certs/download/';
  static const getCourseCompletionDynamicCertificate =
      '/api/certificate/dynamic/v1/generate';
  static const getCourseCompletionCertificateForMobile =
      '/apis/public/v8/course/batch/cert/download/mobile';
  static const getUserProgress = '/api/v1/batch/getUserProgress';
  static const getYourRating = '/api/ratings/v2/read';
  static const getCourseReviewSummery = '/api/ratings/v1/summary/';
  static const postReview = '/api/ratings/v1/upsert';
  static const getCourseReview = '/api/ratings/v1/ratingLookUp';
  static const getAssessmentInfo = '/api/player/questionset/v4/hierarchy/';
  static const getAssessmentQuestions = '/api/player/question/v4/list';
  static const getRetakeAssessmentInfo = '/api/user/assessment/retake/';
  static const getCourse = '/api/content/v2/read/';
  static const getBatchList = '/api/course/v1/batch/list';
  static const getTrendingSearch = '/api/trending/search';
  static const playListSearchUrl = '/api/playList/v2/search';
  static const playListReadUrl = '/api/playList/read/<playListKey>/<orgId>';

  // Providers
  static const getListOfProviders = '/api/org/v1/search';
  static const getCoursesByProvider = '/api/composite/v1/search';
  static const getAllProviders = '/api/searchBy/provider';

  // pre requisite content
  static const updatePreRequisiteContentProgress =
      '/api/content/v2/state/update';
  static const readPreRequisiteContentProgress = '/api/content/v2/state/read';

  // telemetry
  static const getTelemetryUrl = '/api/data/v1/telemetry';
  static const getPublicTelemetryUrl = '/api/data/v1/public/telemetry';
  static const saveAssessment = '/api/v2/user/assessment/submit';
  static const saveAssessmentNew = '/api/v4/user/assessment/submit';
  static const getAssessmentCompletionStatus = '/api/user/assessment/v4/result';

  // Socket connection
  static const socketUrl = 'http://40.113.200.227:4005/user';

  static const asrApiUrl =
      'https://dhruva-api.bhashini.gov.in/services/inference/pipeline';
  static const fetchModels =
      'https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline';

  // Competencies
  static const recommendedFromFrac = '/fracapis/frac/filterByMappings';
  static const recommendedFromWat = '/api/v2/workallocation/user/competencies/';
  static const allCompetencies = '/fracapis/frac/searchNodes';
  static const getLevelsForCompetency = '/fracapis/frac/getNodeById';
  static const getCompetencies = '/fracapis/frac/searchNodes';

  //Events
  static const getAllEvents = '/api/composite/v1/search';
  static const readEvent = '/api/event/v4/read/';
  static const enrollToEvent = '/api/event/batch/enroll';
  static const updateEventProgress = '/api/eventprogress/v1/event/state/update';
  static const eventEnrolRead = '/api/user/event/read/';
  static const eventStateRead = '/api/user/event/state/read';
  static const String featuredEvents = '/api/user/featured/events';
  static const String trendingEvents = '/api/user/mdo/trending/events';
  static const String eventsSummary = "/api/user/events/enroll/summary";

  //To get event enrollment list
  static const eventList = '/api/user/events/list/';

  static const eventListV2 = '/api/user/events/v2/list/';

  //Registration
  static const getAllPosition = '/assets/configurations/site.config.json';
  static const getAllMinistries = '/api/org/v1/list/ministry';
  static const getAllStates = '/api/org/v1/list/state';
  static const register = '/api/user/registration/v1/register';
  static const registerParichayAccount = '/api/user/basicProfileUpdate';
  static const getAllOrganisation = '/api/org/ext/v2/signup/search';
  static const requestForPosition = '/api/workflow/position/create';
  static const requestForOrganisation = '/api/workflow/org/create';
  static const requestForDomain = '/api/workflow/domain/create';
  static const getGroups = '/api/user/v1/groups';
  static const getKarmayogiLogo = '/assets/img/karmayogiLogo.svg';

  //contact
  static const contact = 'https://igot-stage.in/public/contact';

  //Landing page
  static const getLandingPageInfo =
      'https://igotkarmayogi.gov.in/configurations.json';
  static const getFeaturedCoursesV1 = '/api/course/v2/explore';
  static const getFeaturedCoursesV2 = '/api/course/v2/explore';

  //content flagging
  static const createFlag = '/api/user/offensive/data/flag';
  static const getFlaggedData = '/api/user/offensive/data/flag/getFlaggedData';
  static const updateFlaggedData = '/api/user/offensive/data/flag';

  //FAQ Chatbot
  static const getFaqAvailableLangUrl =
      '/api/faq/v1/assistant/available/language';
  static const getFaqDataUrl = '/api/faq/v1/assistant/configs/language';

  static const uploadProfilePhoto =
      '/api/storage/profilePhotoUpload/profileImage';
  static const getCbplan = '/api/user/v1/cbplan';
  static const competencySearch = '/api/competency/v4/search';
  static const searchByProvider = '/api/searchBy/provider';

  //Karma points
  static const karmaPointRead = '/api/karmapoints/read';
  static const totalKarmaPoint = '/api/user/totalkarmapoints';
  static const karmapointCourseRead = '/api/karmapoints/user/course/read';
  static const claimKarmaPoints = '/api/claimkarmapoints';

// config urls
  static const getUserNudgeConfig = '/assets/configurations/profile-nudge.json';
  static const getOverlayThemeData =
      '/assets/configurations/theme-override-config.json';

  // App urls
  static const androidUrl =
      'https://play.google.com/store/apps/details?id=com.igot.karmayogibharat';
  static const iOSUrl =
      'https://apps.apple.com/in/app/igot-karmayogi/id6443949491';
  static const iOSAppRatingUrl =
      'https://apps.apple.com/app/id6443949491?action=write-review';

  //Course sharing
  static const shareCourse = '/api/user/v1/content/recommend';
  // Linkedln link to share course certificate image
  static String linkedlnUrlToShareCertificate =
      'https://www.linkedin.com/sharing/share-offsite/?url=$baseUrl/apis/public/v8/cert/download/#certId';

  // Profile
  static const withdrawRequestUrl = '/api/workflow/transition';
  static const courseRecommended = '/api/courseRecommend/v1/courses';

  //GyaanKarmayogi
  static const gyaanKarmayogiConfig =
      '/assets/configurations/feature/knowledge-resource.json';
  static const getSectorData = "/api/catalog/v1/sector";

  // Standalone Assessment
  static const getStandaloneAssessmentInfo =
      '/api/player/questionset/v5/hierarchy/';
  static const getStandaloneAssessmentQuestions =
      '/api/player/question/v5/list';
  static const getStandaloneRetakeAssessmentInfo =
      '/api/user/assessment/v5/retake/';
  static const submitStandaloneAssessment = '/api/v5/user/assessment/submit';
  static const saveAssessmentQuestion = '/api/assessment/save';
  static const submitV6StandaloneAssessment = '/api/v6/user/assessment/submit';

  // Public API
  static const publicAssessmentV5Read = '/api/public/assessment/v5/read';
  static const publicAssessmentQuestionList =
      '/api/public/assessment/v5/question/list';
  static const publicAdvanceAssessmentSubmit =
      '/api/public/assessment/v5/assessment/submit';
  static const publicBasicAssessmentSubmit =
      '/api/public/assessment/v4/assessment/submit';
  static const getPublicAssessmentCompletionStatus =
      '/api/public/assessment/v5/result';

  //MicroSites
  static const getMicroSiteFormData = '/apis/v1/form/read';
  static const getLearnerReviews = '/api/ratings/v1/topReviews/';
  static const getMicroSiteInsights = '/api/microsite/read/insights';
  static const getMicroSiteCompetencies = '/api/content/v1/search';
  static const getInsightData = '/api/microsite/read/insights';
  static const getMicroSiteTopCoursesData =
      '/api/msite/content/aggregation/search';
  static const getMicroSiteCalenderData = '/api/composite/v1/search';

  //MDO channel
  static const getListOfMdoChannels = '/api/orgBookmark/v1/read/';
  static const getAnnouncementData = '/api/announcements/v1/search';
  static const getMdoCoursesData = '/api/playList/read/';
  static const getMDOTopLearnerData = '/api/walloffame/top/learners/';
  static const getCompetenciesByOrg = '/api/v1/search/competenciesByOrg/';

  // Mentorship
  static String mentorshipUrl = '$baseUrl/mentorship';

  //external search
  static const externalCourseSearch = '/api/cios/v1/search/content';

  // App config url
  static const appConfigUrl = '/assets/mobile_app/config/feature_config.json';

  ///Cadre
  static const getCadreConfigData =
      '/api/data/v2/system/settings/get/cadreConfig';

  //National learning week
  static const getMdoLeaderBoard = '/api/walloffame/v1/mdoleaderboard';
  static const nlwMandatoryCourses =
      '/api/playList/read/123456789NLW_MANDATORY_COURSES/';
  static const nlwInsights = "/api/national/learning/week/insights";
  static const nlwUserLeaderBoard = "/api/walloffame/v1/userleaderboard";

  // Custom self registration
  static const getOrgRead = '/api/org/v1/read';
  static const getOrgLevelDesignation = '/api/framework/v1/read/';
  static const getLinkValidated =
      '/api/customselfregistration/isregistrationqractive';

  /// Comment section
  static const getCommentsTree = '/api/commentTree/v1/get';
  static const getComments = '/api/comment/v3/search';
  static const getReply = '/api/comment/list';
  static const addFirstComment = '/api/comment/v1/addFirst';
  static const addNewComment = '/api/comment/v1/addNew';
  static const likeComment = '/api/comment/v1/like';
  static const reportComment = '/api/comment/report';
  static const reportReason =
      '/api/data/v2/system/settings/get/commentReportReasonConfig';
  static const deleteComment = '/api/comment/v1/delete/';
  static const editComment = '/api/comment/v1/update';
  static const likedComments = '/api/comment/v1/likedComments';
  static const getSearchConfig = '/assets/configurations/feature/search.json';

// Discussion v2
  static const getDiscussionSearch = '/api/feedDiscussion/search';
  static const getGlobalFeeds = '/api/feedDiscussion/globalFeed';
  static const getDiscussion = '/api/feedDiscussion/communityFeed';
  static const getBookmarkedDiscussion =
      '/api/feedDiscussion/bookmarkedDiscussions';
  static const discussionPostLike = '/api/feedDiscussion/question/like/';
  static const discussionReplyLike = '/api/feedDiscussion/answerPost/like/';
  static const discussionAnswerPostReplyLike =
      '/api/feedDiscussion/answerPostReply/like/';
  static const discussionPostDislike = '/api/feedDiscussion/question/dislike/';
  static const discussionReplyDislike =
      '/api/feedDiscussion/answerPost/dislike/';
  static const discussionAnswerPostReplyDislike =
      '/api/feedDiscussion/answerPostReply/dislike/';
  static const discussionPostDelete = '/api/feedDiscussion/question/delete/';
  static const discussionReplyDelete = '/api/feedDiscussion/answerPost/delete/';
  static const discussionAnswerPostReplyDelete =
      '/api/feedDiscussion/answerPostReply/delete/';
  static const discussionReport = '/api/feedDiscussion/report';
  static const createCommunityPost = '/api/feedDiscussion/create';
  static const updateCommunityPost = '/api/feedDiscussion/update';
  static const discussionUploadFile = '/api/feedDiscussion/uploadFile';
  static const createCommunityAnswerPosts = '/api/feedDiscussion/answerPosts';
  static const createCommunityAnswerPostReply =
      '/api/feedDiscussion/answerPostReply/create';
  static const createCommunityUpdateAnswerPost =
      '/api/feedDiscussion/updateAnswerPost';
  static const createCommunityUpdateAnswerPostReply =
      '/api/feedDiscussion/answerPostReply/update';
  static const discussionBookmark = '/api/feedDiscussion/bookmark/';
  static const discussionUnBookmark = '/api/feedDiscussion/unbookmark/';
  static const discussionReportReason =
      '/api/data/v2/system/settings/get/discussionReportReasonConfig';
  static const getEnrichData = '/api/feedDiscussion/v1/enrichData';

  static const getCategoryList = '/api/community/v1/category/listAll';
  static const getCommunity = '/api/community/v1/search';
  static const getCommunityDetails = '/api/community/v1/read/';
  static const getCommunityJoin = '/api/community/v1/join';
  static const getCommunityLeft = '/api/community/v1/unjoin';
  static const getUserJoinedCommunities = '/api/community/v1/user/communities';
  static const getUserAllCommunities = '/api/community/v1/user/communities/all';
  static const getCommunityMembers = '/api/community/v1/community/listuser';
  static const reportCommunity = '/api/community/v1/report';
  static const popularCommunity = '/api/community/v1/popular';
  //state learning week

  static const String slwWeekInsights = '/api/state/learning/week/insights';
  static const String slwMdoLeaderboard =
      '/api/walloffame/v1/state/mdoleaderboard/';
  static const String slwTopLearners = '/api/walloffame/state/top/learners/';
  // iGOT AI
  static const generateRecommendation = '/api/courseRecommendation/create';
  static const getRecommentationWithFeedback =
      '/api/courseRecommendation/read/';
  static const saveFeedback = '/api/courseRecommendation/feedback';
  static const String searchInternet = "/api/chatbot/v3/global/search?user_id=";
  static const String submitFeedback =
      "/api/chatbot/v3/feedbacks/save?chatID={cid}&userID={uid}";

  // Search
  static const nlpSearch = '/api/nlp/search';
  static const peopleSearch = '/api/user/v5/public/search';
  static const recentSearchRead = '/api/search/v1/recent/read';
  static const recentSearchDelete = '/api/search/v1/recent/delete';
  static const recentSearchDeleteTimestamp =
      '/api/search/v1/recent/delete/timestamp/';
  static const recentSearchCreate = '/api/search/v1/recent/create';
  static const String aiChatBot =
      '/api/chatbot/v3/search?chatID={cid}&userID={uid}';
// subtitle and transcription
  static const String getTranscriptionData =
      "/api/chatbot/v3/transcoder/stats?resource_id=";

//NOTIFICATION
  static const String get30DaysNotification = "/api/notifications/list?days=30";

  static const String getNotifications = "/api/v1/notifications/list";
  static const String getNotificationById =
      "/api/notifications/readby/<notificationId>";
  static const String markNotificationAsRead = "/api/v1/notifications/read";
  static const String notificationUnReadCount =
      "/api/v1/notifications/unread/count";
  static const String resetNotificationCount =
      "/api/v1/notifications/reset/unread/count";
  static const String notificationSettingRead = "/api/notificationSetting/read";
  static const String notificationSettingUpdate =
      "/api/notificationSetting/upsert";

  // Profile
  static const basicProfileRead = '/api/user/profile/v1/basic/';
  static const stateList = '/api/extendedprofile/list/states';
  static const districtList = '/api/extendedprofile/list/districts';
  static const saveExtendedProfile = '/api/user/profile/v1/extended';
  static const extendedProfileSummary = '/api/user/profile/v1/extended/all/';
  static const degreeList = '/api/masterdata/list/degrees';
  static const institutionList = '/api/masterdata/list/institutions';
  static const updateExtendedProfile = '/api/user/profile/v1/extended/update';
  static const extendedProfileServiceHistory =
      '/api/user/profile/v1/extended/serviceHistory/';
  static const extendedProfileEducation =
      '/api/user/profile/v1/extended/education/';
  static const extendedProfileAchievement =
      '/api/user/profile/v1/extended/achievement/';
  static const profileBannerUpload =
      '/api/storage/profilePhotoUpload/profileBanner';
  static const achievementCertificateUpload =
      '/api/storage/profilePhotoUpload/userAchievements';
  static const updateDegree = '/api/masterdata/update/degree';
  static const updateInstitute = '/api/masterdata/update/institution';
  static const connectionRelationship =
      '/api/connections/v1/profile/relationship/';
  static const String getCustomProfileField = "/api/customFields/v1/search";
  static const String getCustomProfileFieldData =
      "/api/user/profile/v1/getAdditionalFields/";
  static const String updateCustomProfileFieldData =
      "/api/user/profile/v1/update/additionalFields";
  static const String getMdoAdminList = '/assets/jsonfiles/mdo-admin-details.json';
}

class SocketUrl {
  static String socketBaseUrl = Env.socketUrl;

  static String socketUrl = socketBaseUrl + "/ws?token=<jwt_token>";

  static String socraticSocketUrl =
      socketBaseUrl + "/socratic/v1/ws?token=<jwt_token>";

  static String storyTelling =
      socketBaseUrl + "/storytelling/v1/ws?token=<jwt_token>";
}
