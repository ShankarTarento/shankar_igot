import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_tour/tour_video_progress_slider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/index.dart';
import '../profile/model/profile_model.dart';
import '../../../../respositories/_respositories/profile_repository.dart';
import '../../../../util/telemetry_repository.dart';
import 'intro_tour_screen.dart';

class IntroGetStart extends StatefulWidget {
  final Function returnCallback;
  IntroGetStart({required this.returnCallback});
  @override
  _IntroGetStartState createState() => _IntroGetStartState();
}

class _IntroGetStartState extends State<IntroGetStart> {
  final ProfileService profileService = ProfileService();

  bool showGetStart = true;
  List actionList(context) => [
        {
          'icon': 'assets/img/video_play.png',
          'description': AppLocalizations.of(context)!.mTourWhatIsiGOTKarmayogi
        },
        {
          'icon': 'assets/img/tour.png',
          'description': AppLocalizations.of(context)!.mTourTakeTour
        }
      ];
  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  Timer? _timer;
  int _start = 0;
  List allEventsData = [];
  String? deviceIdentifier;
  var telemetryEventData;
  String? identifier;
  String? primaryCategory;
  bool isFeaturedCourse = false;
  bool isvideoplaying = false;
  bool isTourView = false;
  late VideoPlayerController _videoController;
  final bool isPublic = true;

  bool _visible = true;
  List<Profile> _profileDetails = [];

  @override
  void initState() {
    super.initState();
    initializeChewiePlayer();
    // _startTimer();
    _generateImpressionTelemetryData();
  }

  Future<void> initializeChewiePlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(ApiUrl.baseUrl + '/content-store/Website_Video.mp4'),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
    )..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown
      });
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.viewer,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.getStarted);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subtype}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId ?? "",
        subType: subtype ?? "",
        env: TelemetryEnv.getStarted);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _triggerPlayerStartTelemetryEvent() async {
    _startTimer();
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.player,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.getStarted);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  _triggerPlayerEndTelemetryEvent() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        duration: _start,
        telemetryType: TelemetryType.player,
        pageUri: TelemetryPageIdentifier.homePageUri,
        rollup: {},
        env: TelemetryEnv.getStarted);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getProfileDetails() async {
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
  }

  @override
  void dispose() {
    _videoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _start = 0;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return showGetStart
        ? Stack(
            children: [
              Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: 1.sh,
                    color: AppColors.greys.withValues(alpha: 0.7),
                    child: SafeArea(
                      child: ((isvideoplaying) && (!isTourView))
                          ? _videoPlayerView()
                          : (!isTourView)
                              ? _getStartedView()
                              : SizedBox(),
                    ),
                  )),
              if (isTourView == true)
                Positioned.fill(
                  child: _profileDetails.isNotEmpty
                      ? IntroTourScreen(0,
                          profileInfo: _profileDetails[0],
                          previousPageCallback: _tourReturnCallback,
                          returnCallback: _skipCallback)
                      : IntroTourScreen(
                          0,
                          previousPageCallback: _tourReturnCallback,
                          returnCallback: _skipCallback,
                        ),
                )
            ],
          )
        : Center();
  }

  Future<void> _tourReturnCallback() async {
    setState(() {
      isvideoplaying = true;
      isTourView = false;
    });
  }

  Future<void> _skipCallback({bool isVideoSkip = false}) async {
    if (isTourView) {
      widget.returnCallback();
    } else {
      final _storage = FlutterSecureStorage();
      try {
        var response = await profileService.updateGetStarted(isSkipped: true);
        if (response['params']['status'].toString().toLowerCase() ==
            'success') {
          _storage.write(key: Storage.getStarted, value: GetStarted.finished);
        }
      } catch (e) {}
      setState(() {
        showGetStart = false;
      });
      if (isVideoSkip) {
        if (_videoController.value.isPlaying) {
          _triggerPlayerEndTelemetryEvent();
        }
        _generateInteractTelemetryData(
            contentId: TelemetryIdentifier.videoSkip,
            subtype: TelemetrySubType.video);
      } else {
        _generateInteractTelemetryData(
            contentId: TelemetryIdentifier.welcomeSkip,
            subtype: TelemetrySubType.welcome);
      }
      widget.returnCallback();
    }
  }

  Widget _videoPlayerView() {
    return Container(
        height: 1.sh,
        // color: AppColors.greys.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 87.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.circular(4).r),
                  child: ElevatedButton(
                      onPressed: () => _skipCallback(isVideoSkip: true),
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.grey16)),
                      child: Text(AppLocalizations.of(context)!.mTourSkip,
                          style: GoogleFonts.lato(
                              decoration: TextDecoration.none,
                              color: AppColors.appBarBackground,
                              fontSize: 14.sp,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              height: 1.5.w))),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0).r,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mTourWhatIsiGOTKarmayogi,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontSize: 16.sp,
                            letterSpacing: 0.5.r,
                            height: 1.5.w,
                            decoration: TextDecoration.none,
                          ),
                    ),
                    SizedBox(height: 25.w),
                    GestureDetector(
                      onPanStart: (details) => resetVisibility(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 500.w,
                                  height: 200.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                        color: AppColors.appBarBackground,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(5).r,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5).r,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videoController.value.aspectRatio,
                                      child: VideoPlayer(_videoController),
                                    ),
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _videoController,
                                  builder: (context, value, child) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (_videoController.value.isPlaying) {
                                          _videoController.pause();
                                          _triggerPlayerEndTelemetryEvent();
                                        } else {
                                          _videoController.play();
                                          _triggerPlayerStartTelemetryEvent();
                                        }
                                        //update the variable again to hide action button
                                        hideVisibilityAfterSomeTime();
                                      },
                                      child: Visibility(
                                        visible: _visible ||
                                            !_videoController.value.isPlaying,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: Icon(
                                          _videoController.value.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.grey,
                                          size: 50.0.sp,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 180,
                                  bottom: 0,
                                  child: Container(
                                    width: 380.w,
                                    child: SmoothVideoProgress(
                                      controller: _videoController,
                                      builder:
                                          (context, position, duration, _) =>
                                              VideoProgressSlider(
                                        position: position,
                                        duration: duration,
                                        controller: _videoController,
                                        swatch: AppColors.primaryThree,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 500.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(243, 150, 47, 1),
                        borderRadius: BorderRadius.circular(4).r),
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_videoController.value.isPlaying) {
                              _videoController.pause();
                              _triggerPlayerEndTelemetryEvent();
                            } else {
                              _videoController.play();
                              _triggerPlayerStartTelemetryEvent();
                            }
                          });
                          //update the variable again to hide action button
                          hideVisibilityAfterSomeTime();
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Color.fromRGBO(243, 150, 47, 1))),
                        child: ValueListenableBuilder(
                            valueListenable: _videoController,
                            builder: (context, value, child) {
                              return Text(
                                _videoController.value.isPlaying
                                    ? AppLocalizations.of(context)!.mStaticPause
                                    : AppLocalizations.of(context)!
                                        .mStaticWatch,
                                style: GoogleFonts.lato(
                                    decoration: TextDecoration.none,
                                    color: AppColors.primaryTwo,
                                    fontSize: 14.sp,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5.w),
                              );
                            })),
                  ),
                  SizedBox(height: 10.w),
                  Container(
                    width: 500.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.appBarBackground, width: 1),
                        borderRadius: BorderRadius.circular(4).r),
                    child: ElevatedButton(
                      onPressed: () {
                        _videoController.pause();
                        if (_videoController.value.isPlaying) {
                          _triggerPlayerEndTelemetryEvent();
                        }
                        _generateInteractTelemetryData(
                            contentId: TelemetryIdentifier.tourStart,
                            subtype: TelemetrySubType.tour);
                        _getProfileDetails();
                        setState(() {
                          isTourView = true;
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.grey16)),
                      child: Text(
                        AppLocalizations.of(context)!.mNext,
                        style: GoogleFonts.lato(
                            decoration: TextDecoration.none,
                            color: AppColors.appBarBackground,
                            fontSize: 14.sp,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            height: 1.5.w),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  Widget _getStartedView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16).r,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 87.w,
              height: 40.w,
              decoration: BoxDecoration(
                  color: AppColors.grey16,
                  borderRadius: BorderRadius.circular(4).r),
              child: ElevatedButton(
                  onPressed: _skipCallback,
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.grey16)),
                  child: Text(AppLocalizations.of(context)!.mStaticSkip,
                      style: GoogleFonts.lato(
                          decoration: TextDecoration.none,
                          color: AppColors.appBarBackground,
                          fontSize: 14.sp,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                          height: 1.5.w))),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ).r,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Column(children: [
                    Image(
                      image: AssetImage('assets/img/karmasahayogi.png'),
                      height: 160.w,
                    ),
                    Column(
                      children: [
                        Container(
                          width: 500.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4))
                                .r,
                            color: AppColors.darkBlue,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(47, 24, 47, 20).r,
                            child: Column(
                              children: [
                                Text(
                                    AppLocalizations.of(context)!
                                        .mTourGetStarted,
                                    style: GoogleFonts.lato(
                                        decoration: TextDecoration.none,
                                        color: AppColors.avatarText,
                                        fontSize: 16.sp,
                                        letterSpacing: 0.12,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5.w)),
                                SizedBox(height: 4.w),
                                Text(
                                    AppLocalizations.of(context)!
                                        .mTourWelcomeNote,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        decoration: TextDecoration.none,
                                        color: AppColors.avatarText,
                                        fontSize: 14.sp,
                                        letterSpacing: 0.25,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5.w))
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 160.w,
                          width: 500.w,
                          decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4))
                                  .r),
                          child: ListView.separated(
                            padding: EdgeInsets.all(0).r,
                            itemCount: actionList(context).length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 70.w,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isvideoplaying = true;
                                    });
                                    if (index != 0) {
                                      setState(() {
                                        isTourView = true;
                                      });
                                      _generateInteractTelemetryData(
                                          contentId:
                                              TelemetryIdentifier.tourStart,
                                          subtype: TelemetrySubType.tour);
                                      _getProfileDetails();
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                    left: 16, right: 16)
                                                .r,
                                            child: Icon(Icons.check_circle,
                                                size: 24.sp,
                                                color: AppColors.grey16),
                                          ),
                                          Image(
                                            image: AssetImage(
                                                actionList(context)[index]
                                                    ['icon']),
                                            height: 40.w,
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Text(
                                              actionList(context)[index]
                                                  ['description'],
                                              style: GoogleFonts.lato(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.87),
                                                  fontSize: 14.0.sp,
                                                  letterSpacing: 0.5,
                                                  height: 1.5.w,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      Spacer(),
                                      IconButton(
                                          onPressed: () {
                                            if (index == 0) {
                                              setState(() {
                                                isvideoplaying = true;
                                              });
                                            } else {
                                              if (index == 0) {
                                                setState(() {
                                                  isTourView = true;
                                                });
                                              }
                                              _getProfileDetails();
                                            }

                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios_sharp,
                                            size: 13.sp,
                                            color:
                                                Color.fromRGBO(27, 76, 161, 1),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(
                              thickness: 2,
                              color: AppColors.grey16,
                            ),
                          ),
                        )
                      ],
                    )
                  ]),
                ),
              ],
            ),
          ),
          Container(
            width: 500.w,
            height: 48.w,
            decoration: BoxDecoration(
                color: Color.fromRGBO(243, 150, 47, 1),
                borderRadius: BorderRadius.circular(4).r),
            child: ElevatedButton(
                onPressed: () {
                  _generateInteractTelemetryData(
                      contentId: TelemetryIdentifier.welcomeStart,
                      subtype: TelemetrySubType.welcome);
                  setState(() {
                    isvideoplaying = true;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Color.fromRGBO(243, 150, 47, 1))),
                child: Text(AppLocalizations.of(context)!.mTourGetStarted,
                    style: GoogleFonts.lato(
                        decoration: TextDecoration.none,
                        color: AppColors.primaryTwo,
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                        height: 1.5.w))),
          )
        ],
      ),
    );
  }

  hideVisibilityAfterSomeTime() {
    Future.delayed(const Duration(seconds: 3), () {
      if (this.mounted) {
        setState(() {
          _visible = false; //update the variable to hide action button
        });
      }
    });
  }

  resetVisibility() {
    Future.delayed(const Duration(seconds: 1), () {
      if (this.mounted) {
        setState(() {
          _visible = true; //update the variable to show action button
        });
      }
    });

    //update the variable again to hide action button
    hideVisibilityAfterSomeTime();
  }
}
