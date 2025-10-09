import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/connection_relationship_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../localization/index.dart';
import '../../models/_models/nodal_model.dart';
import '../../models/_models/register_organisation_model.dart';
import '../../models/index.dart';
import '../../ui/screens/_screens/profile/model/achievement_item_model.dart';
import '../../ui/screens/_screens/profile/model/designation_model.dart';
import '../../ui/screens/_screens/profile/model/district_model.dart';
import '../../ui/screens/_screens/profile/model/education_qualification_item_model.dart';
import '../../ui/screens/_screens/profile/model/extended_profile_model.dart';
import '../../ui/screens/_screens/profile/model/profile_field_status_model.dart';
import '../../ui/screens/_screens/profile/model/service_history_model.dart';
import '../../ui/screens/_screens/profile/model/state_model.dart';

class ProfileRepository with ChangeNotifier {
  final ProfileService profileService = ProfileService();
  final RegistrationService registrationService = RegistrationService();
  final _storage = FlutterSecureStorage();
  String _errorMessage = '';
  Response? _data;
  Profile? _profileDetails;
  Profile? get profileDetails => _profileDetails;
  List<dynamic> _designationsList = [];
  List<dynamic> get designationsList => _designationsList;
  List<dynamic> _groupList = [];
  List<dynamic> get groupList => _groupList;
  List<ProfileFieldStatusModel> _inReview = [];
  List<ProfileFieldStatusModel> get inReview => _inReview;
  List<ProfileFieldStatusModel> _rejectedFields = [];
  List<ProfileFieldStatusModel> get rejectedFields => _rejectedFields;
  List<ProfileFieldStatusModel> _approvedFields = [];
  List<ProfileFieldStatusModel> get approvedFields => _approvedFields;
  List<Nationality> _nationalities = [];
  List<Nationality> get nationalities => _nationalities;
  List<Language> _languages = [];
  List<Language> get languages => _languages;
  List<dynamic> _organisations = [];
  List<dynamic> get organisation => _organisations;
  List<dynamic> _industries = [];
  List<dynamic> get industries => _industries;
  List<dynamic> _gradePay = [];
  List<dynamic> get gradePay => _gradePay;
  List<dynamic> _services = [];
  List<dynamic> get services => _services;
  List<dynamic> _cadre = [];
  List<dynamic> get cadre => _cadre;
  List<dynamic> _graduations = [];
  List<dynamic> get graduations => _graduations;
  List<dynamic> _postGraduations = [];
  List<dynamic> get postGraduations => _postGraduations;
  int? _resendOTPTime;
  int? get resendOTPTime => _resendOTPTime;
  List<dynamic> _orgLevelDesignationsList = [];
  List<dynamic> get orgLevelDesignationsList => _orgLevelDesignationsList;
  bool _designationUpdateStatus = false;
  bool get designationUpdateStatus => _designationUpdateStatus;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  double _profileCompletionPercentage = 0;
  double get profileCompletionPercentage => _profileCompletionPercentage;

  Future<List<Profile>> getProfileDetails() async {
    try {
      final response = await profileService.getProfileDetails();
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body = contents['result']['UserProfile'];
      List<Profile> profileDetails = body
          .map(
            (dynamic item) => Profile.fromJson(item),
          )
          .toList();
      return profileDetails;
    } else {
      // throw 'Can\'t get profile details.';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Profile>> getProfileDetailsById(String id) async {
    try {
      _isLoading = true;
      final response = await profileService.getProfileDetailsById(id);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
        Map<String, dynamic> body = contents['result']['response'];

        List<Profile> profileDetailsById = [];

        profileDetailsById.add(Profile.fromJson(body));

        if (id == '') {
          _profileDetails = profileDetailsById.first;
          _storage.write(
            key: Storage.profileStatus,
            value: _profileDetails!.profileStatus.toString(),
          );
          _profileCompletionPercentage =
              _profileDetails!.profileCompletionPercentage;

          var orgName =
              contents['result']['response']['rootOrg']['orgName'] as String?;
          if (orgName != null) {
            _storage.write(
              key: Storage.deptName,
              value: orgName,
            );
          }
        }
        _isLoading = false;
        notifyListeners();
        return profileDetailsById;
      } else {
        // throw 'Can\'t get profile details by ID.';
        _isLoading = false;
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      _isLoading = false;
      return [];
    }
  }

  Future<List<Nationality>> getNationalities() async {
    if (nationalities.isEmpty) {
      try {
        final response = await profileService.getNationalities();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        List<dynamic> body = contents['nationalities'];
        _nationalities = body
            .map(
              (dynamic item) => Nationality.fromJson(item),
            )
            .toList();
        notifyListeners();
      } else {
        // throw 'Can\'t get nationalities.';
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _nationalities;
  }

  Future<List<Language>> getLanguages() async {
    if (languages.isEmpty) {
      try {
        final response = await profileService.getLanguages();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
        List<dynamic> body = contents['languages'];
        _languages = body
            .map(
              (dynamic item) => Language.fromJson(item['name']),
            )
            .toList();
        notifyListeners();
      } else {
        // throw 'Can\'t get languages.';
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _languages;
  }

  //get edit profile configuration
  Future<int?> getResendOtpTime() async {
    if (resendOTPTime == null) {
      final editProfileConfig = await profileService.getProfileEditConfig();
      _resendOTPTime = editProfileConfig['resendOTPTime'];
      notifyListeners();
    }
    return _resendOTPTime != null ? _resendOTPTime : 180;
  }

  Future<List<dynamic>> getDegrees(type) async {
    if (type == 'graduation' ? graduations.isEmpty : postGraduations.isEmpty) {
      try {
        final response = await profileService.getDegrees(type);
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        if (type == 'graduation') {
          _graduations = contents['graduations'];
        } else {
          _postGraduations = contents['postGraduations'];
        }
        notifyListeners();
      } else {
        // throw 'Can\'t get degrees.';
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return type == 'graduation' ? _graduations : _postGraduations;
  }

  Future<List<dynamic>> getOrganisations() async {
    if (organisation.isEmpty) {
      try {
        final response = await profileService.getOrganisations();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        _organisations = jsonDecode(_data!.body);
        notifyListeners();
      } else {
        // throw 'Can\'t get Organisations.';
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _organisations;
  }

  Future<List<dynamic>> getIndustries() async {
    if (industries.isEmpty) {
      try {
        final response = await profileService.getIndustries();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        _industries = contents['industries'];
        notifyListeners();
      } else {
        // throw 'Can\'t get Industries.';
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return industries;
  }

  Future<List<dynamic>> getDesignations(int offset, String query) async {
    try {
      final response = await profileService.getDesignations(offset, query);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body = [];
      for (int index = 0;
          index < contents['result']['result']['data'].length;
          index++) {
        body.add(contents['result']['result']['data'][index]['designation']);
      }
      _designationsList = body;
      notifyListeners();
    } else {
      // throw 'Can\'t get Industries.';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
    return _designationsList;
  }

  Future<List<dynamic>> getGroups() async {
    if (groupList.isEmpty) {
      try {
        final response = await registrationService.getGroup();
        _groupList = response;
        notifyListeners();
      } catch (_) {
        return [];
      }
    }
    return _groupList;
  }

  Future<List<ProfileFieldStatusModel>> getInReviewFields(
      {bool isRejected = false, bool isApproved = false, bool forceUpdate = false}) async {
    try {
      final response = await ProfileService()
          .getInReviewFields(isRejected: isRejected, isApproved: isApproved, forceUpdate: forceUpdate);
      if (response['result']['data'] != null &&
          response['result']['data'].isNotEmpty) {
        List<ProfileFieldStatusModel> data = response['result']['data']
            .map<ProfileFieldStatusModel>(
                (dynamic result) => ProfileFieldStatusModel.fromJson(result))
            .toList();
        if (isRejected) {
          _rejectedFields = data;
          _rejectedFields
              .sort((a, b) => b.lastUpdatedOn.compareTo(a.lastUpdatedOn));
        } else if (isApproved) {
          _approvedFields = data;
          _approvedFields
              .sort((a, b) => b.lastUpdatedOn.compareTo(a.lastUpdatedOn));
        } else {
          _inReview = data;
        }
      } else {
        if (isRejected) {
          _rejectedFields = [];
        } else if (isApproved) {
          _approvedFields = [];
        } else {
          _inReview = [];
        }
      }
      // log('Approved: $approvedFields');
      // log('Rejected: $rejectedFields');
      // log('InReview: $inReview');
      notifyListeners();
    } catch (_) {
      return [];
    }
    return isRejected
        ? _rejectedFields
        : isApproved
            ? _approvedFields
            : _inReview;
  }

  Future<List<dynamic>> getGradePay() async {
    if (gradePay.isEmpty) {
      try {
        final response = await profileService.getGradePay();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        List<dynamic> body = contents['designations']['gradePay'];

        _gradePay = [];
        for (int index = 0; index < body.length; index++) {
          _gradePay.insert(index, body[index]['name']);
        }
        notifyListeners();
      } else {
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _gradePay;
  }

  Future<List<dynamic>> getServices() async {
    if (services.isEmpty) {
      try {
        final response = await profileService.getServices();
        _data = response;
      } catch (_) {
        return [];
      }
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(_data!.body);
        _services = contents['services'];
        notifyListeners();
      } else {
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    }
    return _services;
  }

  Future<List<dynamic>> getCadre() async {
    if (cadre.isEmpty) {
      try {
        final response = await profileService.getCadre();

        if (response.statusCode == 200) {
          var contents = jsonDecode(response.body);
          List<dynamic> body = contents['govtOrg']['cadre'];
          _cadre = [];
          for (int index = 0; index < body.length; index++) {
            _cadre.insert(index, body[index]['name']);
          }
          notifyListeners();
        } else {
          _errorMessage = _data!.statusCode.toString();
          throw _errorMessage;
        }
      } catch (_) {
        return [];
      }
    }
    return _cadre;
  }

  Future<dynamic> getUserName(wid) async {
    try {
      final response = await profileService.getUserName(wid);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      Map wTokenResponse;
      wTokenResponse = json.decode(_data!.body);

      return wTokenResponse['result']['response']['userName'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<dynamic> getInsights(BuildContext context) async {
    try {
      final response = await profileService.getUserInsights();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);

      // // To display the popup to rate the app on weekly claps
      // Future.delayed(Duration(seconds: 2), () async {
      //   await Provider.of<InAppReviewRespository>(context, listen: false)
      //       .rateAppOnWeeklyClap(contents['result']['response'],
      //           context: context);
      // });

      return contents['result']['response'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      return _errorMessage;
    }
  }

  // Upload profile photo
  Future<dynamic> profilePhotoUpdate(image) async {
    var response;
    try {
      response = await profileService.uploadProfilePhoto(image);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var contents = jsonDecode(responseBody);

      return contents['result']['url'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      return response.statusCode;
    }
  }

  // Read karma points(or get history of karma points)
  Future<dynamic> getKarmaPointHistory({limit, offset}) async {
    var response;
    try {
      response = await profileService.getKarmaPointHistory(
          limit: limit, offset: offset);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // Get Total karma point info
  Future<dynamic> getTotalKarmaPoint() async {
    var response;
    try {
      response = await profileService.getTotalKarmaPoint();
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // read karma point for course
  Future<dynamic> getKarmaPointCourseRead(String courseId) async {
    var response;
    try {
      response = await profileService.getKarmaPointCourseRead(courseId);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      return contents['kpList'];
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  // Claim karma points
  Future<dynamic> claimKarmaPoints(String courseId) async {
    var response;
    try {
      response = await profileService.claimKarmaPoints(courseId);
    } catch (_) {
      return _;
    }
    if (response.statusCode == 200) {
      return EnglishLang.success;
    } else {
      _errorMessage = response.statusCode.toString();
      return _errorMessage;
    }
  }

  ///Share course
  Future<List> getRecipientList(String query, int limit) async {
    List _usersList;
    try {
      var temp = await profileService.getRecipientList(query, limit);
      _usersList = temp['result']['response']['content'];
    } catch (_) {
      return [];
    }

    return _usersList;
  }

  /// Learner leaderboard
  Future<dynamic> getLeaderboardData() async {
    try {
      final response = await profileService.getLeaderboardData();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['result']['result'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  /// Request for cadre service
  Future<dynamic> requestForService({
    required BuildContext context,
    required String typeOfCivilService,
    required String service,
    String? cadreControllingAuthority,
  }) async {
    Helper.showSnackBarMessage(
        context: context,
        text: '${typeOfCivilService}, ${service}, ${cadreControllingAuthority}',
        bgColor: AppColors.positiveLight);
    // try {
    //   final response = await profileService.requestForProfileField(
    //       fullName: profileDetails.firstName,
    //       email: profileDetails.primaryEmail,
    //       field: fieldValue,
    //       mobileNumber: personalDetails['mobile'],
    //       isPosition: isPosition,
    //       isOrg: isOrg,
    //       isDomain: isDomain);
    //   _data = response;
    // } catch (_) {
    //   Helper.showSnackBarMessage(
    //       context: context,
    //       text: AppLocalizations.of(context).mStaticSomethingWrongTryLater,
    //       bgColor: AppColors.positiveLight);
    // }
    // if (_data.statusCode == 200) {
    //   var contents = jsonDecode(_data.body);
    //   Helper.showSnackBarMessage(
    //       context: context,
    //       text: contents['result']['message'],
    //       bgColor: AppColors.positiveLight);
    // } else {
    //   Helper.showSnackBarMessage(
    //       context: context,
    //       text: AppLocalizations.of(context).mStaticSomethingWrongTryLater,
    //       bgColor: AppColors.positiveLight);
    // }
  }

  /// get Cadre Config Data
  Future<dynamic> getCadreConfigData() async {
    try {
      final response = await profileService.getCadreConfigData();
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['result']['response']['value'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<String>> getRecommendedCourse() async {
    try {
      final response = await profileService.getRecommendedCourse();
      _data = response;
    } catch (_) {
      return [].cast<String>();
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['result']['courseList'] != null
          ? contents['result']['courseList'].cast<String>()
          : [].cast<String>();
    } else {
      _errorMessage = _data!.statusCode.toString();
      return [].cast<String>();
    }
  }

  // Custom self registration
  // get org framework id
  Future<RegistrationLinkModel?> getOrgFrameworkId({String? orgId}) async {
    try {
      String? organisationId =
          orgId ?? await _storage.read(key: Storage.deptId);
      if (organisationId != null) {
        final response =
            await registrationService.getOrgFrameworkId(organisationId);
        _data = response;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return RegistrationLinkModel.fromJson(contents['result']['response']);
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  // Get designations based on org id

  Future<List<dynamic>> getOrgBasedDesignations(String orgId,
      {bool notify = true}) async {
    try {
      final response = await registrationService.getOrgBasedDesignations(orgId);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body = [];
      for (Map<String, dynamic> category in contents['result']['framework']
          ['categories']) {
        if (category['code'] == 'org' && category['terms'] != null) {
          for (Map<String, dynamic>? term in category['terms']) {
            if (term != null && term['associations'] != null) {
              for (Map<String, dynamic> association in term['associations']) {
                body.add(association['name']);
              }
            }
          }
        }
      }
      _orgLevelDesignationsList = body;
      if (notify) {
        notifyListeners();
      }
    } else {
      // throw 'Can\'t get Industries.';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
    return _orgLevelDesignationsList;
  }

  // Org search by id
  Future<OrganisationModel?> getOrganizationData(String orgId) async {
    try {
      final response = await registrationService.getOrganizationData(orgId);
      _data = response;
    } catch (_) {
      return null;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return OrganisationModel.fromJson(contents['result']['response'].first);
    } else {
      // throw 'Can\'t get Industries.';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  // To send the OTP to email address
  Future<String> generateEmailOTP(String emailAddress) async {
    try {
      final response = await profileService.generateEmailOTP(emailAddress);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  Future<String> generateEmailExtOTP(String emailAddress) async {
    try {
      final response = await profileService.generateEmailExtOTP(emailAddress);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  Future<String> verifyEmailOTP(String emailId, String otp) async {
    try {
      final response = await profileService.verifyEmailOTP(emailId, otp);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  // get approved email domains
  Future<List<String>> getApprovedEmailDomains() async {
    try {
      final response = await profileService.getApprovedEmailDomains();
      if (response!.statusCode == 200) {
        var contents = jsonDecode(response!.body);
        return contents['result']['domains'] != null ||
                contents['result']['domains'].isNotEmpty
            ? List<String>.from(contents['result']['domains'])
            : [];
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // To send the OTP to email
  Future<dynamic> generatePrimaryEmailOTP(String email) async {
    try {
      var response = await profileService.generatePrimaryEmailOTP(email);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (e) {
      return e.toString();
    }
  }

  // To verify email OTP
  Future<String> verifyPrimaryEmailOTP(String emailId, String otp) async {
    try {
      final response = await profileService.verifyPrimaryEmailOTP(emailId, otp);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  // Verify registration link
  Future<String> getRegisterLinkValidated(String link) async {
    try {
      final response = await registrationService.getRegisterLinkValidated(link);
      _data = response;
    } catch (_) {
      return 'Invalid Link';
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      return contents['params']['errmsg'].toString();
    } else {
      _errorMessage = _data!.statusCode.toString();
      return _errorMessage;
    }
  }

  // To send the OTP to mobile number
  Future<String> generateMobileNumberOTP(String mobileNumber) async {
    try {
      final Map response =
          await profileService.generateMobileNumberOTP(mobileNumber);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  //To verify the OTP
  Future<dynamic> verifyMobileNumberOTP(String mobileNumber, String otp) async {
    try {
      final Map response =
          await profileService.verifyMobileNumberOTP(mobileNumber, otp);
      return response['params']['errmsg'] != null
          ? response['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  Future<String> getSelfRegister(
      {required String fullName,
      required String email,
      required String group,
      required String mobileNumber,
      required OrganisationModel organisation,
      required String designation,
      required String registrationLink,
      bool isWhatsappConsent = false}) async {
    try {
      var response = await registrationService.getSelfRegister(
          fullName: fullName,
          email: email,
          group: group,
          mobileNumber: mobileNumber,
          organisation: organisation,
          designation: designation,
          registrationLink: registrationLink,
          isWhatsappConsent: isWhatsappConsent);
      if (response.statusCode == 202) {
        return EnglishLang.success;
      } else {
        Map data = jsonDecode(response.body);
        if (data['result']['result'] != null) {
          return data['result']['result'];
        } else if (data['params']['errmsg'] != null) {
          return data['params']['errmsg'];
        } else {
          return EnglishLang.errorMessage;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<String> withdrawDesignation({
    required String wfId,
  }) async {
    try {
      await profileService.withdrawProfileField(wfId: wfId);
      return EnglishLang.success;
    } catch (e) {
      return EnglishLang.failed;
    }
  }

  void designationStatus(bool value) {
    if (value != _designationUpdateStatus) {
      _designationUpdateStatus = value;
      notifyListeners();
    }
  }

  Future<dynamic> updateProfileDetails(Map profileDetails) async {
    try {
      final Map response =
          await profileService.updateProfileDetails(profileDetails);
      return response;
    } catch (_) {
      return '';
    }
  }

  Future<Profile?> getBasicProfileDetailsById(String id,
      {bool isCurrentUser = false}) async {
    try {
      final response = await profileService.getBasicProfileDetailsById(id);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
        Map<String, dynamic> body = contents['result']['response'];

        Profile? profileDetailsById = contents['result']['response'] != null
            ? Profile.fromJson(body)
            : null;
        if (profileDetailsById != null &&
            profileDetailsById.profileStatus != null) if (isCurrentUser) {
          _storage.write(
            key: Storage.profileStatus,
            value: profileDetailsById.profileStatus.toString(),
          );
          _profileDetails = profileDetailsById;
          _profileCompletionPercentage =
              profileDetailsById.profileCompletionPercentage;
          notifyListeners();
        }
        return profileDetailsById;
      } else {
        _errorMessage = _data!.statusCode.toString();
        debugPrint(_errorMessage);
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<StateModel>> getStateList() async {
    try {
      final response = await profileService.getStateList();
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> body = contents['result']['statesList'] ?? [];

        List<StateModel> stateList = body.isNotEmpty
            ? body.map((item) => StateModel.fromJson(item)).toList()
            : [];
        return stateList;
      } else {
        _errorMessage = _data!.statusCode.toString();
        debugPrint(_errorMessage);
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<DistrictModel>> getDistrictList(String state) async {
    try {
      final response = await profileService.getDistrictList(state);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> body = contents['result']['districtsList'] ?? [];

        List<DistrictModel> districtList = body.isNotEmpty
            ? body.map((item) => DistrictModel.fromJson(item)).toList()
            : [];
        return districtList;
      } else {
        _errorMessage = _data!.statusCode.toString();
        debugPrint(_errorMessage);
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<String> saveExtendedProfile(Map<String, dynamic> content) async {
    try {
      final response = await profileService.saveExtendedProfile(content);
      var contents = jsonDecode(response.body);
      return contents['params']['errMsg'] != null
          ? contents['params']['errMsg']
          : contents['params']['errmsg'] != null
              ? contents['params']['errmsg']
              : contents['responseCode'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<ExtendedProfile?> getExtendedProfile(String? userId) async {
    try {
      final response = await profileService.getExtendedProfile(userId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        Map<String, dynamic> body = contents['result']['response'] ?? {};

        ExtendedProfile extendedProfile = ExtendedProfile.fromJson(body);
        return extendedProfile;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<String>> getDegreeList() async {
    try {
      final response = await profileService.getDegreeList();
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> list = contents['result']['degreesList']['degrees'] ?? [];
        return list.map((item) => item.toString()).toList();
      } else {
        _errorMessage = _data!.statusCode.toString();
        debugPrint(_errorMessage);
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<String>> getInstitutionList() async {
    try {
      final response = await profileService.getInstitutionList();
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> list =
            contents['result']['institutionList']['institutions'] ?? [];
        return list.map((item) => item.toString()).toList();
      } else {
        _errorMessage = _data!.statusCode.toString();
        debugPrint(_errorMessage);
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<String> updateExtendedProfile(Map<String, dynamic> content) async {
    try {
      final response = await profileService.updateExtendedProfile(content);
      var contents = jsonDecode(response.body);
      return contents['params']['errMsg'] != null
          ? contents['params']['errMsg']
          : contents['params']['errmsg'] != null
              ? contents['params']['errmsg']
              : contents['responseCode'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<ServiceHistoryModel>> getExtendedServiceHistory(
      String? userId) async {
    try {
      final response = await profileService.getExtendedServiceHistory(userId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> body =
            contents['result']['response']['serviceHistory'] ?? [];

        List<ServiceHistoryModel> serviceHistoryList = body.isNotEmpty
            ? body.map((e) => ServiceHistoryModel.fromJson(e)).toList()
            : [];
        return serviceHistoryList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<EducationalQualificationItem>> getExtendedEducationHistory(
      String? userId) async {
    try {
      final response = await profileService.getExtendedEducationHistory(userId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> body =
            contents['result']['response']['educationalQualifications'] ?? [];

        List<EducationalQualificationItem> serviceHistoryList = body.isNotEmpty
            ? body.map((e) => EducationalQualificationItem.fromJson(e)).toList()
            : [];
        return serviceHistoryList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<AchievementItem>> getExtendedAchievements(String? userId) async {
    try {
      final response = await profileService.getExtendedAchievements(userId);
      if (response!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response!.bodyBytes));
        List<dynamic> body =
            contents['result']['response']['achievements'] ?? [];

        List<AchievementItem> achievementList = body.isNotEmpty
            ? body.map((e) => AchievementItem.fromJson(e)).toList()
            : [];
        return achievementList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // To update profile banner
  Future<String?> uploadProfileBanner(File image) async {
    var response;
    try {
      response = await profileService.uploadProfileBanner(image);
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var contents = jsonDecode(responseBody);

        return contents['result']['url'];
      } else {
        _errorMessage = _data!.statusCode.toString();
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadAchievementCertificate(File image) async {
    var response;
    try {
      response = await profileService.uploadAchievementCertificate(image);
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var contents = jsonDecode(responseBody);

        return contents['result'];
      } else {
        _errorMessage = _data!.statusCode.toString();
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // To update degree master list
  Future<String> updateDegreeMasterList(String degree) async {
    try {
      final response = await profileService.updateDegreeMasterList(degree);

      var data = jsonDecode(response.body);
      return data['params']['errmsg'] != null
          ? data['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

  // To update institution master list
  Future<String> updateInstitutionMasterList(String institution) async {
    try {
      final response =
          await profileService.updateInstitutionMasterList(institution);

      var data = jsonDecode(response.body);
      return data['params']['errmsg'] != null
          ? data['params']['errmsg'].toString()
          : '';
    } catch (_) {
      return '';
    }
  }

// To get org master list
  Future<List<OrganisationModel>> getOrgMasterList(
      {int offset = 0, String query = ''}) async {
    try {
      final response =
          await profileService.getOrgMasterList(offset: offset, query: query);

      var contents = jsonDecode(response.body);
      List<dynamic> data = contents['result']['response']['content'];
      List<OrganisationModel> ministries = data
          .map(
            (dynamic item) => OrganisationModel.fromJson(item),
          )
          .toList();
      return ministries;
    } catch (_) {
      return [];
    }
  }

  // To get org based designation
  Future<List<DesignationModel>> getOrgBasedDesignationList(
      {int offset = 0,
      required List<String> orgIdList,
      String query = ''}) async {
    try {
      final response = await profileService.getOrgBasedDesignationList(
          offset: offset, orgIdList: orgIdList, query: query);

      var contents = jsonDecode(response.body);
      List<dynamic> data = contents['result']['Term'] ?? [];
      List<DesignationModel> designations = data
          .map(
            (dynamic item) => DesignationModel.fromJson(item),
          )
          .toList();
      return designations;
    } catch (_) {
      return [];
    }
  }

  /// Get profile connection relationship
  Future<ConnectionRelationshipModel?> getConnectionRelationship(
      String id) async {
    try {
      final response = await profileService.getConnectionRelationship(id);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
        Map<String, dynamic> body = contents['result']['response'];

        ConnectionRelationshipModel? connectionRelationshipModel =
            contents['result']['response'] != null
                ? ConnectionRelationshipModel.fromJson(body)
                : null;
        return connectionRelationshipModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void clearProfileDetails() {
    if (_profileDetails != null) {
      _profileDetails = null;
      _profileCompletionPercentage = 0;
      notifyListeners();
    }
  }

  Future<List<NodalModel>> getNodalUser() async {
    try {
      var temp = await profileService.getNodalUser();
      var data = temp['content'];
      if (data != null && data.isNotEmpty) {
        return List<NodalModel>.from(data.map((x) => NodalModel.fromJson(x)))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
