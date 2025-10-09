import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/discussion_view.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_view_skeleton.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class GlobalFeeds extends StatefulWidget {
  GlobalFeeds({Key? key,}) : super(key: key);

  @override
  GlobalFeedsState createState() => GlobalFeedsState();
}

class GlobalFeedsState extends State<GlobalFeeds> {

  Profile? _profileData;
  String _userRole = '';
  String _designation = '';
  String _profileStatus = '';
  final _storage = FlutterSecureStorage();
  String _userName = '';
  String _userId = '';
  String _profileImageUrl = '';
  Future<DiscussionRequest?>? _userDataFuture;
  List<UserCommunityIdData> _userJoinedCommunities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData(context);
  }

  @override
  void didUpdateWidget(covariant GlobalFeeds oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<DiscussionRequest?> _getUserData(context) async {
    try {
      _isLoading = true;
      _userJoinedCommunities = await _getUserJoinedCommunities();
      _profileData = await Provider.of<ProfileRepository>(context, listen: false).profileDetails;
      if (_profileData != null) {
        _userRole = _profileData?.roles?[0]??'';
        _designation = _profileData?.designation??'';
      }
      _userName = await _storage.read(key: Storage.firstName)??'';
      _userId = await _storage.read(key: Storage.userId)??'';
      _profileImageUrl = await _storage.read(key: Storage.profileImageUrl)??'';
      _profileStatus = await _storage.read(key: Storage.profileStatus)??'';

      if (_userName.isNotEmpty) {
        DiscussionRequest commentRequest = DiscussionRequest(
            discussionType: DiscussionType.globalFeeds,
            communityId: '',
            showAddDiscussion: _userJoinedCommunities.isNotEmpty,
            enableLike: true,
            enableBookmark: true,
            enableReport: true,
            enableReply: true,
            userName: _userName,
            userId: _userId,
            userProfileImage: (_profileImageUrl.isNotEmpty ? _profileImageUrl : Helper.getInitialsNew(_userName)),
            userRole: _userRole,
            designation: _designation,
            profileStatus: _profileStatus,
            enableAction: true,
            enableEdit: true,
            enableDelete: true,
        );
        _isLoading = false;
        return Future.value(commentRequest);
      } else {
        _isLoading = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      return null;
    }
  }

  Future<List<UserCommunityIdData>> _getUserJoinedCommunities() async {
    List<UserCommunityIdData> response = [];
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false).getUserJoinedCommunities();
      return response;
    } catch (err) {
      return [];
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return (_isLoading)
                ? CommentViewSkeleton(itemCount: 10,)
                : Container();
          }
          if (_userJoinedCommunities.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16).r,
              child: _noDataFound()
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16).r,
              child: DiscussionView(
                discussionRequest: snapshot.data!,
                userJoinedCommunities: _userJoinedCommunities,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _noDataFound() {
    return Container(
      child: NoDataWidget(
        title: AppLocalizations.of(context)!.mDiscussionNoGlobalFeedFoundTitle,
        message: AppLocalizations.of(context)!.mDiscussionNoGlobalFeedFound,
        maxLines: 10,
      ),
    );
  }
}
