import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_request.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/discussion_view.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';


class DiscussionViewWrapper extends StatefulWidget {
  final DiscussionType discussionType;
  final String communityId;
  final int topicId;
  final bool isUserJoinedCommunity;
  final Function? onJoinCallback;
  final ValueNotifier<bool>? isLoading;
  final bool? showAddDiscussion;
  DiscussionViewWrapper({Key? key, required this.discussionType, required this.communityId, required this.topicId, required this.isUserJoinedCommunity,
    this.onJoinCallback, this.isLoading, this.showAddDiscussion = false}) : super(key: key);

  @override
  _DiscussionViewWrapperState createState() => _DiscussionViewWrapperState();
}

class _DiscussionViewWrapperState extends State<DiscussionViewWrapper> {

  Profile? _profileData;
  String _userRole = '';
  String _designation = '';
  String _profileStatus = '';
  final _storage = FlutterSecureStorage();
  String _userName = '';
  String _userId = '';
  String _profileImageUrl = '';
  Future<DiscussionRequest?>? _userDataFuture;
  bool _isUserJoinedCommunity = false;

  @override
  void initState() {
    super.initState();
    _isUserJoinedCommunity = widget.isUserJoinedCommunity;
    _userDataFuture = _getUserData(context);
  }

  @override
  void didUpdateWidget(covariant DiscussionViewWrapper oldWidget) {
    if (oldWidget.isUserJoinedCommunity != widget.isUserJoinedCommunity) {
      setState(() {
        _isUserJoinedCommunity = widget.isUserJoinedCommunity;
        _userDataFuture = _getUserData(context);
      });
    }
    super.didUpdateWidget(oldWidget);
  }



  Future<DiscussionRequest?> _getUserData(context) async {
    try {
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
            discussionType: widget.discussionType,
            communityId: widget.communityId,
            showAddDiscussion: widget.showAddDiscussion,
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
            enableAction: _isUserJoinedCommunity,
            enableEdit: true,
            enableDelete: true,
            showSearch: true,
        );
        return Future.value(commentRequest);
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32).r,
          child: DiscussionView(
              discussionRequest: snapshot.data!,
              onJoinCallback: widget.onJoinCallback,
              isLoading: widget.isLoading,

          ),
        );
      },
    );
  }
}
