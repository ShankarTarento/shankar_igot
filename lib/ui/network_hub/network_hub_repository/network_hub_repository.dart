import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/services/network_hub_services.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';

class NetworkHubRepository {
  static Profile? _currentUserDetails;

  Future<List<NetworkUser>> getConnectionRequests(
      {required int offset, required int size}) async {
    List<NetworkUser> connectionRequests = [];
    try {
      final response = await NetworkHubServices.getConnectionRequests();
      if (response.statusCode == 200) {
        final Map content = jsonDecode(response.body);
        final List data = content['result']['data'] as List;

        connectionRequests = data.map((e) => NetworkUser.fromJson(e)).toList();
        return connectionRequests;
      }
    } catch (e) {
      debugPrint('Error fetching connection requests: $e');
    }
    return connectionRequests;
  }

  Future<List<RecommendedUser>> getRecommendedConnections(
      {required int size, required int offset}) async {
    List<RecommendedUser> recommendedUsers = [];

    try {
      final response = await NetworkHubServices.getRecommendedUsers(
          offset: offset, size: size);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load recommended connections. Status code: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> content = jsonDecode(response.body);
      final List<dynamic>? results =
          content['result']?['response'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        return recommendedUsers;
      }

      recommendedUsers =
          results.map((item) => RecommendedUser.fromJson(item)).toList();

      return recommendedUsers;
    } catch (e) {
      debugPrint('Error fetching recommended connections: $e');
      throw Exception(
          'An error occurred while fetching recommended connections.');
    }
  }

  Future<List<NetworkUser>> getMyConnections(
      {required int offset, required int size}) async {
    try {
      final response =
          await NetworkHubServices.getMyConnections(offset: offset, size: size);
      if (response.statusCode == 200) {
        final Map content = jsonDecode(utf8.decode(response.bodyBytes));
        final List data = content['result']['data'] as List;

        return data.map((e) => NetworkUser.fromJson(e)).toList();
      } else {
        throw Exception(
            'Failed to load my connections. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching my connections: $e');
      throw Exception('An error occurred while fetching my connections.');
    }
  }

  Future<List<NetworkUser>> getRequestedConnections(
      {required int offset, required int size}) async {
    try {
      final response = await NetworkHubServices.getRequestedConnections(
          offset: offset, size: size);
      if (response.statusCode == 200) {
        final Map content = jsonDecode(utf8.decode(response.bodyBytes));
        final List data = content['result']['data'] as List;

        return data.map((e) => NetworkUser.fromJson(e)).toList();
      } else {
        throw Exception(
            'Failed to load my connections. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching my connections: $e');
      throw Exception('An error occurred while fetching my connections.');
    }
  }

  Future<List<RecommendedUser>> getRecommendedMentors(
      {required int offset, required int size}) async {
    List<RecommendedUser> recommendedMentors = [];
    try {
      final response = await NetworkHubServices.getRecommendedMentors(
          offset: offset, size: size);
      if (response.statusCode == 200) {
        final Map content = jsonDecode(utf8.decode(response.bodyBytes));
        final List data = content['result']['response'] as List;
        recommendedMentors =
            data.map((e) => RecommendedUser.fromJson(e)).toList();
        return recommendedMentors;
      } else {
        throw Exception(
            'Failed to load recommended mentors. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching recommended mentors: $e');
      throw Exception('An error occurred while fetching recommended mentors.');
    }
  }

  Future<List<NetworkUser>> getBlockedUsers(
      {required int offset, required int size}) async {
    List<RecommendedUser> users = [];
    List<NetworkUser> blockedUsers = [];

    try {
      final response =
          await NetworkHubServices.getBlockedUsers(offset: offset, size: size);
      if (response.statusCode == 200) {
        final Map content = jsonDecode(utf8.decode(response.bodyBytes));
        final List data = content['result']['response'] as List;
        users = data.map((e) => RecommendedUser.fromJson(e)).toList();
        for (var user in users) {
          blockedUsers.add(NetworkUser(
            userId: user.userId,
            departmentName: user.employmentDetails?.departmentName ?? "",
            fullName: user.personalDetails?.firstname ?? "",
            designation: user.designation,
            professionalDetails: [
              ProfessionalDetails(
                designation: user.designation ?? "",
                group: user.professionalDetails?.first.group ?? "",
              )
            ],
            organisationId: user.rootOrgId,
            roles: user.role,
            status: "Blocked",
            profileImageUrl: user.profileImageUrl,
          ));
        }

        return blockedUsers;
      } else {
        throw Exception(
            'Failed to load blocked users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching blocked users: $e');
      return [];
    }
  }

  Future<String> updateConnectionStatus(
      {required String connectionDepartmentTo,
      required String connectionIdTo,
      required String userNameTo,
      required String status}) async {
    //return "Successful";
    Profile? currentUser = await currentUserProfile;

    final response = await NetworkHubServices.updateConnection(
        connectionDepartmentTo: connectionDepartmentTo,
        connectionIdTo: connectionIdTo,
        userNameFrom: currentUser?.firstName ?? "",
        deptNameFrom: currentUser?.department ?? "",
        userNameTo: userNameTo,
        status: status);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map content = jsonDecode(utf8.decode(response.bodyBytes));

      return content['result']['message'];
    } else {
      throw Exception(
          'Failed to update connection status. Status code: ${response.statusCode}');
    }
  }

  Future<String> createConnectionRequest(
      {required String connectionId,
      required String userNameTo,
      required String userDepartmentTo}) async {
    Profile? currentUser = await currentUserProfile;
    if (currentUser == null) {
      throw Exception('Current user profile is not available.');
    }
    final response = await NetworkHubServices.createConnectionRequest(
        connectionId: connectionId,
        userNameFrom: currentUser.firstName,
        userDepartmentFrom: currentUser.department,
        userNameTo: userNameTo,
        userDepartmentTo: userDepartmentTo);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map content = jsonDecode(utf8.decode(response.bodyBytes));
      return content['result']['message'];
    } else {
      throw Exception(
          'Failed to create connection request. Status code: ${response.statusCode}');
    }
  }

  static Future<Profile?> getCurrentUserProfile() async {
    try {
      final response = await ProfileService().getProfileDetailsById(null);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        final Map profileData = decodedBody['result']['response'];

        if (profileData.isNotEmpty) {
          _currentUserDetails =
              Profile.fromJson(profileData as Map<String, dynamic>);
          return _currentUserDetails;
        } else {
          debugPrint('Profile list is empty.');
          return null;
        }
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception caught in getCurrentUserProfile: $e');
      return null;
    }
  }

  static Future<Profile?> get currentUserProfile async {
    if (_currentUserDetails != null) {
      return _currentUserDetails;
    }
    _currentUserDetails = await getCurrentUserProfile();
    return _currentUserDetails;
  }

  Future<List> getConnectionsCount() async {
    try {
      final response = await NetworkHubServices.getConnectionsCount();

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch connections count: ${response.statusCode}');
      }

      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> content = jsonDecode(decodedBody);

      final List<dynamic> data =
          content['result']?['facets']?[0]?['values'] ?? [];
      return data;
    } catch (e, stackTrace) {
      debugPrint('Error fetching connections count: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  Future<String> blockUser({
    required String connectionId,
    required String userNameTo,
    required String userDepartmentTo,
  }) async {
    try {
      final currentUser = await currentUserProfile;

      if (currentUser == null) {
        throw Exception('User profile not found.');
      }

      final response = await NetworkHubServices.blockUser(
        connectionId: connectionId,
        userNameFrom: currentUser.firstName,
        userDepartmentFrom: currentUser.department,
        userNameTo: userNameTo,
        userDepartmentTo: userDepartmentTo,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final content = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        final message = content['result']?['message'];

        if (message != null) {
          return message.toString();
        } else {
          throw Exception('Response does not contain a message.');
        }
      } else {
        throw Exception(
            'Failed to block user. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error blocking user: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('An error occurred while blocking the user.');
    }
  }
}
