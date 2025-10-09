import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';
import './../../../util/helper.dart';

class DiscussionItem extends StatelessWidget {
  final String user;
  final String hrs;
  final String title;
  final String category;
  final String tag;
  final String votes;
  final String comments;

  DiscussionItem(this.user, this.hrs, this.title, this.category, this.tag,
      this.votes, this.comments);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.appBarBackground,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.all(Radius.circular(4).r)),
        child: Column(
          children: [
            Container(
                width: double.infinity.w,
                padding: EdgeInsets.only(top: 20, left: 20).r,
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: AppColors.avatarGreen,
                      child: Center(
                        child: Text(
                          Helper.getInitials(user),
                          style: TextStyle(color: AppColors.avatarText),
                        ),
                      ),
                    ),
                    Container(
                        // alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10).r,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                user,
                                style: TextStyle(
                                  color: AppColors.greys87,
                                  fontSize: 12.0.sp,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5).r,
                                child: Text(
                                  hrs,
                                  style: TextStyle(
                                    color: AppColors.greys60,
                                    fontSize: 12.0.sp,
                                  ),
                                ),
                              )
                            ])),
                  ],
                )),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10).r,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 12).r,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10).r,
                      child: Icon(Icons.category),
                    ),
                    Text(
                      category,
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(),
                    ),
                  ],
                )),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10).r,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 10).r,
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 6).r,
                    decoration: BoxDecoration(
                      color: AppColors.grey08,
                      border: Border.all(color: AppColors.grey08),
                      borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(10))
                          .r,
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 12.0.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  // Container(
                  Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 20)
                              .r,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            // Add this
                            Icons.import_export, // Add this
                            color: AppColors.greys, // Add this
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5).r,
                            child: Text(
                              votes,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          )
                        ],
                      )),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20).r,
                    child: Text(
                      comments,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
