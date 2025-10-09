import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/custom_network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/custom_network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectionRequestView extends StatefulWidget {
  const ConnectionRequestView({super.key});

  @override
  State<ConnectionRequestView> createState() => _ConnectionRequestViewState();
}

class _ConnectionRequestViewState extends State<ConnectionRequestView> {
  @override
  void initState() {
    futureConnectionRequest =
        NetworkHubRepository().getConnectionRequests(offset: 0, size: 4);
    super.initState();
  }

  late Future<List<NetworkUser>> futureConnectionRequest;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NetworkUser>>(
      future: futureConnectionRequest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _connectionRequestSkeleton();
        }

        final data = snapshot.data;

        if (data != null && data.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(12).r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8).r,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _connectRequestsView(requests: data),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _connectionRequestSkeleton() {
    return Column(
      children: [
        buildTitleWidget(),
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
    );
  }

  Widget _connectRequestsView({required List<NetworkUser> requests}) {
    return Column(
      children: [
        buildTitleWidget(count: requests.length, showAll: true),
        SizedBox(height: 20.h),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return CustomNetworkCard(
              cardState: UserConnectionStatus.Received,
              user: requests[index],
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 16.h,
            color: AppColors.grey24,
          ),
        ),
      ],
    );
  }

  Widget buildTitleWidget({int? count, bool showAll = false}) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.mNetworkTabConnectionRequests,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 6.w),
        count != null
            ? CircleAvatar(
                radius: 8.r,
                backgroundColor: Colors.red,
                child: Text(count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    )),
              )
            : SizedBox(),
        Spacer(),
        showAll
            ? InkWell(
                onTap: () {
                  NetworkHubV2.setTabItem(
                      context: context, index: 1, subTabIndex: 1);
                },
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mNetworkShowAll,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16.sp, color: AppColors.darkBlue),
                  ],
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget emptyConnectionRequestView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTitleWidget(),
        SizedBox(height: 40.h),
        Text(
          AppLocalizations.of(context)!.mNetworkNoConnectionRequests,
          style: TextStyle(color: AppColors.greys60, fontSize: 14.sp),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
