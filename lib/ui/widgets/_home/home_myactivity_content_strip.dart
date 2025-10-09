import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/display_widget_for_duration.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/leaderboard_nudge_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/user_nudge_card.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../constants/_constants/storage_constants.dart';
import '../../../models/_models/leaderboard_model.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../skeleton/index.dart';

class HomeMyactivityContentStrip extends StatefulWidget {
  final UserEnrollmentInfo? enrollmentInfo;
  final profileData;

  const HomeMyactivityContentStrip(
      {super.key, this.enrollmentInfo, required this.profileData});

  @override
  State<HomeMyactivityContentStrip> createState() =>
      _HomeMyactivityContentStripState();
}

class _HomeMyactivityContentStripState extends State<HomeMyactivityContentStrip>
    with SingleTickerProviderStateMixin {
  late Future<dynamic> getUserInsightFuture;
  ValueNotifier<bool> _isDisplayUserNudge = ValueNotifier(false);
  ValueNotifier<bool> _isDisplayLeaderboardNudge = ValueNotifier(false);
  AnimationController? _animationController;
  int get nudgeFadeInOutDuration => 500;
  Animation<double>? _opacityAnimation;
  Animation<double>? _fadeOutAnimation;
  Timer? _timer;
  final _storage = FlutterSecureStorage();

  /// leaderboard
  LeaderboardModel? _leaderboardData;

  @override
  void initState() {
    super.initState();
    _getUserNudgeAndThemeInfo();
    getUserInsights();
    // Create the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: nudgeFadeInOutDuration),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _fadeOutAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController!);
    _getLeaderboardData();
  }

  @override
  void dispose() async {
    _animationController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void getUserInsights() async {
    getUserInsightFuture =
        Provider.of<ProfileRepository>(context, listen: false)
            .getInsights(context);
  }

  bool _isSameMonth(String currentUpdate, String lastUpdate) {
    if (lastUpdate == '') return false;

    String _lastFormattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(lastUpdate));
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime _currentDate = format.parse(currentUpdate);
    DateTime _lastDate = format.parse(_lastFormattedDate);

    if (_currentDate.year != _lastDate.year) {
      return false;
    }
    if (_currentDate.month != _lastDate.month) {
      return false;
    }
    return true;
  }

  Future<void> _leaderboardNudgeDisplayed() async {
    try {
      await ProfileService()
          .updateLeaderboardNudgeData(DateTimeHelper.formatDate(DateTime.now()));
    } catch (e) {}
  }

  void _startTimer() {
    int start = 0;
    int nudgeStartSecond =
        Provider.of<LandingPageRepository>(context, listen: false).profileDelay;
    int nudgeEndSecond = nudgeStartSecond +
        Provider.of<LandingPageRepository>(context, listen: false).nudgeDelay;
    _isDisplayUserNudge.value =
        Provider.of<LandingPageRepository>(context, listen: false)
                .displayUserNudge &&
            Provider.of<LandingPageRepository>(context, listen: false)
                .isProfileCardExpanded;

    _isDisplayLeaderboardNudge.value =
        Provider.of<LandingPageRepository>(context, listen: false)
                .displayUserNudge &&
            Provider.of<LandingPageRepository>(context, listen: false)
                .isProfileCardExpanded;

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      start++;
      if ((start > nudgeStartSecond && start < nudgeEndSecond) &&
          (Provider.of<LandingPageRepository>(context, listen: false)
                  .displayUserNudge &&
              Provider.of<LandingPageRepository>(context, listen: false)
                  .isProfileCardExpanded)) {
        _isDisplayUserNudge.value = true;
        _animationController?.forward();
      } else if (start == nudgeEndSecond) {
        _isDisplayUserNudge.value = false;
        _animationController?.reverse();
        _timer?.cancel();
      } else {
        _isDisplayUserNudge.value = false;
      }
    });
  }

  _getUserNudgeAndThemeInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LandingPageRepository>(context, listen: false)
          .getUserNudgeAndThemeInfo();
      _startTimer();
    });
  }

  void _getLeaderboardData() async {
    List<LeaderboardModel> _leaderboardDataList = [];
    try {
      dynamic result =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getLeaderboardData();
      if (result != null) {
        _leaderboardDataList = List<LeaderboardModel>.from(
            result.map((data) => LeaderboardModel.fromJson(data)).toList());
        if (_leaderboardDataList.isNotEmpty) {
          String? userId = await _storage.read(key: Storage.wid);
          _leaderboardDataList.forEach((element) {
            if (userId == element.userId) {
              _leaderboardData = element;
            }
          });
        }
      }
    } catch (error) {
      print('$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.enrollmentInfo != null
            ? FutureBuilder(
                future: getUserInsightFuture,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.runtimeType == String ||
                        snapshot.data.runtimeType == HandshakeException) {
                      return Container(
                        width: 1.sw,
                        child: MyactivityCard(
                          profileDetails: widget.profileData,
                          enrollmentInfo:
                              widget.enrollmentInfo,
                          weeklyClaps: {},
                        ),
                      );
                    }
                    return Container(
                      width: 1.sw,
                      child: MyactivityCard(
                        profileDetails: widget.profileData,
                        enrollmentInfo:
                            widget.enrollmentInfo,
                        weeklyClaps: snapshot.data != null
                            ? snapshot.data['weekly-claps']
                            : {},
                        leaderboardRank: (_leaderboardData != null)
                            ? '${_leaderboardData!.rank}'
                            : '',
                      ),
                    );
                  } else {
                    return Container(
                        margin: EdgeInsets.all(16),
                        child: MyacticitiesCardSkeleton());
                  }
                })
            : Center(),
        // User nudge card on timely basis
        ValueListenableBuilder(
            valueListenable: _isDisplayUserNudge,
            builder:
                (BuildContext context, bool isDisplayUserNudge, Widget? child) {
              return Consumer<LandingPageRepository>(builder:
                  (BuildContext context,
                      LandingPageRepository landingPageRepository,
                      Widget? child) {
                return landingPageRepository.userNudgeInfo != null
                    ? AnimatedBuilder(
                        animation: _animationController!,
                        builder: (context, child) {
                          return Container(
                              width: 1.sw,
                              child: AnimatedOpacity(
                                duration: Duration(
                                    milliseconds: nudgeFadeInOutDuration),
                                opacity: _isDisplayUserNudge.value
                                    ? _opacityAnimation!.value
                                    : _fadeOutAnimation!.value,
                                child: Visibility(
                                  visible: _opacityAnimation!.value > 0,
                                  child: UserNudgeCard(
                                    profileDetails: widget.profileData,
                                    isDisplayUserNudge:
                                        _isDisplayUserNudge.value,
                                    landingPageRepository:
                                        landingPageRepository,
                                    opacityAnimation: _opacityAnimation!,
                                    nudgeFadeInOutDuration:
                                        nudgeFadeInOutDuration,
                                  ),
                                ),
                              ));
                        })
                    : Center();
              });
            }),

        /// leader board celebration card
        if ((_leaderboardData != null) &&
            (!_isSameMonth(DateTimeHelper.formatDate(DateTime.now()),
                widget.profileData.lastMotivationalMessageTime ?? '')))
          if (_leaderboardData!.previousRank > _leaderboardData!.rank)
            ValueListenableBuilder(
                valueListenable: _isDisplayLeaderboardNudge,
                builder: (BuildContext context, bool isDisplayUserNudge,
                    Widget? child) {
                  _leaderboardNudgeDisplayed();
                  return Container(
                      width: 1.sw,
                      child: DisplayWidgetWithDuration(
                        duration: Duration(seconds: 5),
                        child: LeaderboardNudgeCard(
                          leaderboardData: _leaderboardData!,
                        ),
                      ));
                }),
      ],
    );
  }
}