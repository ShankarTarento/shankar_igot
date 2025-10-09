import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/custom_network_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class NetworkHubSkeleton extends StatefulWidget {
  const NetworkHubSkeleton({super.key});

  @override
  State<NetworkHubSkeleton> createState() => _NetworkHubSkeletonState();
}

class _NetworkHubSkeletonState extends State<NetworkHubSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteGradientOne,
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp, size: 24.sp, color: AppColors.greys60),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.mNetworkHub,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _connectionRequestSkeleton(),
                SizedBox(height: 16.h),
                _buildNetworkCardSkeleton()
              ],
            ),
          ),
        ));
  }

  Widget _connectionRequestSkeleton() {
    return Container(
      padding: EdgeInsets.all(12).r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Column(
        children: [
          buildTitleWidget(
              title: AppLocalizations.of(context)!.mStaticConnectionRequests),
          SizedBox(height: 20.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return CustomNetworkCardSkeleton();
            },
            separatorBuilder: (context, index) => Divider(
              height: 16.h,
              color: AppColors.grey24,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitleWidget({required String title}) {
    return Row(
      children: [
        Text(
          Helper.capitalizeEachWordFirstCharacter(title),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(12).r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0).r,
        child: Column(
          children: [
            SizedBox(height: 8.h),
            buildTitleWidget(
                title: AppLocalizations.of(context)!.mStaticPeopleYouMayKnow),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 24.h,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return NetworkCardSkeleton();
              },
            ),
          ],
        ),
      ),
    );
  }
}
