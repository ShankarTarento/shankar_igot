import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/comment_request.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/comments_view.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';


class CourseComments extends StatefulWidget {
  final String courseId;
  final bool isEnrolled;
  final double bottomMargin;
  final String? tagCommentId;
  final VoidCallback? backToAllCommentsCallback;
  final bool enableUserTagging;
  CourseComments({Key? key, required this.courseId, this.isEnrolled = false, this.bottomMargin=32, this.tagCommentId, this.backToAllCommentsCallback, this.enableUserTagging = false}) : super(key: key);

  @override
  _CourseCommentsState createState() => _CourseCommentsState();
}

class _CourseCommentsState extends State<CourseComments> {

  Profile? _profileData;
  String _userRole = '';
  String _designation = '';
  String _profileStatus = '';
  final _storage = FlutterSecureStorage();
  String _userName = '';
  String _userId = '';
  String _profileImageUrl = '';
  Future<CommentRequest?>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData(context);
  }

  Future<CommentRequest?> _getUserData(context) async {
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
        CommentRequest commentRequest = CommentRequest(
            entityId: widget.courseId,
            entityType: "COURSE",
            workflow: "TOC",
            enableLike: true,
            enableReport: true,
            enableReply: true,
            userName: _userName,
            userId: _userId,
            userProfileImage: (_profileImageUrl.isNotEmpty ? _profileImageUrl : Helper.getInitialsNew(_userName)),
            userRole: _userRole,
            designation: _designation,
            profileStatus: _profileStatus,
            enableAction: widget.isEnrolled,
            enableEdit: true,
            enableDelete: true,
            tagCommentId: widget.tagCommentId,
            backToAllCommentsCallback: widget.backToAllCommentsCallback,
            enableUserTagging: widget.enableUserTagging,
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
          padding: EdgeInsets.only(left: 16.0, right: 16, bottom: widget.bottomMargin).r,
          child: CommentsView(
              commentRequest: snapshot.data!
          ),
        );
      },
    );
  }
}
