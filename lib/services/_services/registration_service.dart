import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/register_organisation_model.dart';

import 'package:karmayogi_mobile/models/_models/registration_position_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class RegistrationService {
  // final _storage = FlutterSecureStorage();
  Future<List<RegistrationPosition>> getPositions() async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllPosition),
    );
    var contents = jsonDecode(response.body);
    List<dynamic> data = contents['positions'];
    List<RegistrationPosition> positions = data
        .map(
          (dynamic item) => RegistrationPosition.fromJson(item),
        )
        .toList();
    // developer.log(positions.toString());
    return positions;
  }

  Future<List<dynamic>> getGroup() async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getGroups),
    );
    var contents = jsonDecode(response.body);
    List<dynamic> data = contents['result']['response'];
    return data;
  }

  Future<List<OrganisationModel>> getMinistries({String parentId = ''}) async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl +
          (parentId == ''
              ? ApiUrl.getAllMinistries
              : ApiUrl.getAllMinistries.replaceAll('ministry', parentId))),
    );
    var contents = jsonDecode(response.body);
    List<dynamic> data = contents['result']['response']['content'];
    List<OrganisationModel> ministries = data
        .map(
          (dynamic item) => OrganisationModel.fromJson(item),
        )
        .toList();
    // developer.log(ministries.toString());
    return ministries;
  }

  Future<dynamic> getOrganisation(
      {String? searchText, String? category}) async {
    Map requestBody = {
      "request": {
        "filters": {
          "orgName": "$searchText",
          "parentType": category == EnglishLang.center
              ? EnglishLang.ministry.toLowerCase()
              : EnglishLang.state.toLowerCase()
        },
        "limit": 50
      }
    };

    var encodedData = jsonEncode(requestBody);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllOrganisation),
        headers: NetworkHelper.registerPostHeaders(),
        body: encodedData);

    List<OrganisationModel> organisations;
    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      List<dynamic> data = contents['result']['response'];
      organisations = data
          .map(
            (dynamic item) => OrganisationModel.fromJson(item),
          )
          .toList();
    } else {
      return jsonDecode(response.body)['params']['errmsg'];
    }
    return organisations;
  }

  Future<List<OrganisationModel>> getStates() async {
    Response response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllStates),
    );
    var contents = jsonDecode(response.body);
    List<dynamic> data = contents['result']['response']['content'];
    List<OrganisationModel> states = data
        .map(
          (dynamic item) => OrganisationModel.fromJson(item),
        )
        .toList();
    // developer.log(states.toString());
    return states;
  }

  Future<dynamic> registerAccount(
    String fullName,
    String email,
    String group,
    String mobileNumber,
    OrganisationModel organisation, {
    bool isParichayUser = false,
  }) async {
    // var _profileDetails = json.encode(profileDetails);
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);

    Map data;
    if (isParichayUser) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token.toString());
      String userId = decodedToken['sub'].split(':')[2];
      await _storage.write(key: Storage.userId, value: userId);
      data = {
        "request": {
          "userId": userId,
          "firstName": fullName,
          "email": email,
          "group": group,
          "phone": mobileNumber,
          "orgName": organisation.name,
          "channel": organisation.name,
          "organisationType": organisation.orgType,
          "organisationSubType": organisation.subOrgType,
          "mapId": organisation.id,
          "sbOrgId": organisation.subOrgId,
          "sbRootOrgId": organisation.subRootOrgId,
          "source": SOURCE_NAME,
        }
      };
    } else {
      data = {
        "firstName": fullName,
        "email": email,
        "group": group,
        "phone": mobileNumber,
        "orgName": organisation.name,
        "channel": organisation.name,
        "organisationType": organisation.orgType,
        "organisationSubType": organisation.subOrgType,
        "mapId": organisation.id,
        "sbOrgId": organisation.subOrgId,
        "sbRootOrgId": organisation.subRootOrgId,
        "source": SOURCE_NAME,
      };
    }

    var body = json.encode(data);
    // log("request: " + body.toString());
    String url = ApiUrl.baseUrl +
        (isParichayUser ? ApiUrl.registerParichayAccount : ApiUrl.register);
    Response response = await post(Uri.parse(url),
        headers: isParichayUser
            ? NetworkHelper.registerParichayUserPostHeaders(token)
            : NetworkHelper.registerPostHeaders(),
        body: body);
    return response;
  }

  Future<dynamic> requestForRegistrationField(String fullName, String email,
      String field, String fieldDescription, String mobileNumber,
      {bool isPosition = false,
      bool isOrg = false,
      bool isDomain = false}) async {
    Map data;
    data = {
      "state": RegistrationRequests.STATE,
      "action": RegistrationRequests.ACTION,
      "serviceName": isPosition
          ? RegistrationRequests.POSITION_SERVICE_NAME
          : isOrg
              ? RegistrationRequests.ORGANISATION_SERVICE_NAME
              : RegistrationRequests.DOMAIN_SERVICE_NAME,
      "userId": Helper.generateRandomString(),
      "applicationId": Helper.generateRandomString(),
      "actorUserId": Helper.generateRandomString(),
      "deptName": RegistrationRequests.IGOT_DEPT_NAME,
      "updateFieldValues": [
        {
          "toValue": isPosition
              ? {"position": field}
              : isOrg
                  ? {"organisation": field}
                  : {"domain": field},
          "fieldKey": isPosition
              ? "position"
              : isOrg
                  ? "organisation"
                  : "domain",
          "description": fieldDescription,
          "firstName": fullName,
          "email": email,
          "mobile": mobileNumber
        }
      ],
    };

    var body = json.encode(data);

    String url = ApiUrl.baseUrl +
        (isPosition
            ? ApiUrl.requestForPosition
            : isOrg
                ? ApiUrl.requestForOrganisation
                : ApiUrl.requestForDomain);
    Response response = await post(Uri.parse(url),
        headers: NetworkHelper.registerRequestFieldHeader(), body: body);
    return response;
  }

  Future<String> getKarmayogiLogo() async {
    Response response = await get(
      Uri.parse(
          convertToPortalPublicUrl(ApiUrl.baseUrl) + ApiUrl.getKarmayogiLogo),
    );
    if (response.statusCode == 200) {
      return response.body;
    }
    return '';
  }

  String convertToPortalPublicUrl(String baseUrl) {
    return (baseUrl.replaceFirst('portal.', ''));
  }

  Future<dynamic> getOrgFrameworkId(String orgId) async {
    Map data;
    data = {
      'request': {'organisationId': orgId}
    };

    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.getOrgRead;
    Response response = await post(Uri.parse(url),
        headers: NetworkHelper.registerPostHeaders(), body: body);
    return response;
  }

  Future<dynamic> getOrgBasedDesignations(String orgId) async {
    Response response = await HttpService.get(
        ttl: ApiTtl.getDesignationMaster,
        apiUri:
            Uri.parse(ApiUrl.baseUrl + ApiUrl.getOrgLevelDesignation + orgId),
        headers: NetworkHelper.registerPostHeaders());
    return response;
  }

  Future<dynamic> getSelfRegister(
      {required String fullName,
      required String email,
      required String group,
      required String mobileNumber,
      required OrganisationModel organisation,
      required String designation,
      required bool isWhatsappConsent,
      required String registrationLink}) async {
    Map data = {
      "firstName": fullName,
      "email": email,
      "group": group,
      "phone": mobileNumber,
      "position": designation,
      "orgName": organisation.name,
      "channel": organisation.name,
      "organisationType": organisation.orgType,
      "organisationSubType": organisation.subOrgType,
      "mapId": organisation.id,
      "sbOrgId": organisation.subOrgId,
      "sbRootOrgId": organisation.subRootOrgId,
      "source": SOURCE_NAME,
      "isWhatsappConsent": isWhatsappConsent,
      "registrationLink": registrationLink
    };

    var body = json.encode(data);
    // log("request: " + body.toString());
    String url = ApiUrl.baseUrl + ApiUrl.register;
    Response response = await post(Uri.parse(url),
        headers: NetworkHelper.registerPostHeaders(), body: body);
    return response;
  }

  // Org search by id

  Future<dynamic> getOrganizationData(String orgId) async {
    Map<String, dynamic> body = {
      "request": {
        "filters": {
          "identifier": [orgId]
        }
      }
    };
    var data = json.encode(body);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAllOrganisation),
        headers: NetworkHelper.signUpPostHeaders(),
        body: data);
    return response;
  }

  Future<dynamic> getRegisterLinkValidated(String link) async {
    var body = json.encode({'registrationLink': link});
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLinkValidated),
        headers: NetworkHelper.registerPostHeaders(),
        body: body);
    return response;
  }
}
