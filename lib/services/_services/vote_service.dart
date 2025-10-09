import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'dart:convert';
import 'dart:async';
import './../../constants/index.dart';

class VoteService {
  final String postUpVoteUrl = ApiUrl.baseUrl + ApiUrl.vote;
  final _storage = FlutterSecureStorage();

  Future<dynamic> postVote(mainPid, voteType) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    // String cookie = await _storage.read(key: 'cookie');

    Map data;
    if (voteType == 'upVote') {
      data = {
        'delta': '1',
        '_uid': nodebbUserId,
      };
    } else {
      data = {
        'delta': '-1',
        '_uid': nodebbUserId,
      };
    }
    var body = json.encode(data);

    Response res = await post(
        Uri.parse(postUpVoteUrl + mainPid.toString() + '/vote'),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['code'];
    } else {
      throw 'Can\'t post upvote.';
    }
  }

  Future<dynamic> deleteVote(mainPid) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    // String cookie = await _storage.read(key: 'cookie');

    Response res = await delete(
        Uri.parse(
            postUpVoteUrl + mainPid.toString() + '/vote?_uid=$nodebbUserId'),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!));
    // print(res.body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['code'];
    } else {
      throw 'Can\'t delete upvote.';
    }
  }
}
