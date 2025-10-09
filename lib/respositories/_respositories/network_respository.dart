import 'package:flutter/widgets.dart';
import './../../models/index.dart';
import './../../services/index.dart';

class NetworkRespository with ChangeNotifier {
  ConnectionRequest? _crList;
  ConnectionRequest? _pymkList;
  int noOfConnectionRequest = 0;

  /// Process people you may know
  Future<List> getPymkList() async {
    List _usersList = [];
    try {
      final pymkInfo = await NetworkService.getPeopleYouMayKnow();
      _pymkList = ConnectionRequest.fromJson(pymkInfo['result']);
      List userIds = [];
      // print(_pymkList.data.length);
      if (_pymkList!.data.length > 0) {
        for (var data in _pymkList!.data) {
          userIds.add(data['id']);
        }
        _usersList = await getUsersNames(userIds);
      }
    } catch (_) {
      return [];
    }
    return _usersList;
  }

  /// Process connection request
  Future<ConnectionRequest?> getCrList() async {
    try {
      final crInfo = await NetworkService.getConnectionRequests();
      if (crInfo != null) {
        _crList = ConnectionRequest.fromJson(crInfo['result']);
        if (_crList != null) {
          noOfConnectionRequest = _crList!.data.length;

          notifyListeners();
        }
      }
    } catch (_) {
      throw _;
    }

    return _crList;
  }

  /// Process connection request
  Future<List> getUsersNames(List userIds) async {
    List _usersList;
    try {
      var temp = await NetworkService.getUsersListByIds(userIds);
      _usersList = temp['result']['response']['content'];
    } catch (_) {
      return [];
    }

    return _usersList;
  }

  Future<List<dynamic>> getRequestedConnections() async {
    List<dynamic> data;
    try {
      final response = await NetworkService.getRequestedConnections();

      data = response['result']['data'];
    } catch (_) {
      return [];
    }

    return data;
  }
}
