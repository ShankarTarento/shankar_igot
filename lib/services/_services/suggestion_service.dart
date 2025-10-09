import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'dart:convert';
import 'dart:async';
import './../../models/index.dart';
import './../../constants/index.dart';

class SuggestionService {
  final String suggestionsUrl = ApiUrl.baseUrl + ApiUrl.getSuggestions;
  final _storage = FlutterSecureStorage();

  Future<List<Suggestion>?> getSuggestions() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? department = await _storage.read(key: Storage.deptName);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'size': 50,
      'offset': 0,
      'search': [
        {
          'field': 'employmentDetails.departmentName',
          'values': ['$department']
        }
      ]
    };
    var body = json.encode(data);

    Response res = await post(Uri.parse(suggestionsUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!), body: body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      List<dynamic> body = contents['result']['data'][0]['results'];
      List<Suggestion> suggestions = body
          .map(
            (dynamic item) => Suggestion.fromJson(item),
          )
          .toList();
      return suggestions;
    } else {
      return null;
    }
  }
}
