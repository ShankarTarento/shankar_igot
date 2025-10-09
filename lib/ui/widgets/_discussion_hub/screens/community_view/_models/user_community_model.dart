
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';

class UserCommunityModel {
  List<CommunityItemData>? communityDetails;
  List<UserCommunityIdData>? communityId;


  UserCommunityModel({this.communityDetails, this.communityId});

  factory UserCommunityModel.fromJson(Map<String, dynamic> json) {
    return UserCommunityModel(
      communityDetails: (json['communityDetails'] as List<dynamic>?)
          ?.map((item) => CommunityItemData.fromJson(item))
          .toList(),
      communityId: (json['communityId'] as List<dynamic>?)
          ?.map((item) => UserCommunityIdData.fromJson(item))
          .toList(),
    );
  }
}

class UserCommunityIdData {
  String? communityId;
  String? communityName;

  UserCommunityIdData({
    this.communityId,
    this.communityName,
  });

  factory UserCommunityIdData.fromJson(Map<String, dynamic> json) {
    return UserCommunityIdData(
      communityId: json['communityid'] as String?,
      communityName: json['communityName'] ?? "",
    );
  }
}


