import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/explore_network/widgets/connection_request_view.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/explore_network/widgets/mentors_strip.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/explore_network/widgets/network_recommendation_view.dart';

class ExploreNetwork extends StatefulWidget {
  const ExploreNetwork({super.key});

  @override
  State<ExploreNetwork> createState() => _ExploreNetworkState();
}

class _ExploreNetworkState extends State<ExploreNetwork> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16).r,
            child: Column(
              children: [
                SizedBox(
                  height: 16.w,
                ),
                ConnectionRequestView(),
                SizedBox(
                  height: 16.w,
                ),
                NetworkRecommendationView(),
                SizedBox(
                  height: 16.w,
                ),
              ],
            ),
          ),
          MentorsStrip(),
          SizedBox(
            height: 50.w,
          ),
        ],
      ),
    );
  }
}
