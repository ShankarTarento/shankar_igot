import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatefulWidget {
  final String message;

  const MessageCard({
    super.key,
    required this.message,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  Profile? profile;

  @override
  void initState() {
    profile =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0).r,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.65.sw),
            padding: const EdgeInsets.all(12).r,
            decoration: BoxDecoration(
              color: AppColors.deepBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ).r,
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: AppColors.appBarBackground,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          profile != null
              ? profile!.profileImageUrl != null &&
                      profile!.profileImageUrl != ""
                  ? SizedBox(
                      height: 45.w,
                      width: 45.w,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20).r,
                          child: Image.network(profile!.profileImageUrl!)),
                    )
                  : CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.darkBlue,
                      child: Text(
                        Helper.getInitials(profile!.firstName),
                        style: GoogleFonts.lato(
                            color: AppColors.appBarBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp),
                      ),
                    )
              : CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.darkBlue,
                  child: Icon(
                    Icons.person,
                    color: AppColors.appBarBackground,
                    size: 30.r,
                  ),
                ),
        ],
      ),
    );
  }
}
