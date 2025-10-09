import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:igot_ui_components/ui/widgets/microsite_spane_text/microsites_span_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/microsites_learner_reviews_view_skeleton.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../util/helper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_learner_reviews_data_model.dart';
import 'microsites_learner_reviews_content_widget.dart';

class MicroSitesLearnerReviewsView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? orgId;
  final ColumnData columnData;

  MicroSitesLearnerReviewsView({
    this.containerKey,
    this.orgId,
    required this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesLearnerReviewsViewState createState() {
    return _MicroSitesLearnerReviewsViewState();
  }
}

class _MicroSitesLearnerReviewsViewState
    extends State<MicroSitesLearnerReviewsView> {
  final ScrollController _reviewItemScrollController = ScrollController();

  MicroSitesLearnerDataModel? microSitesLearnerDataModel;
  Future<MicroSitesLearnerReviewsDataModel>? microSitesLearnerReviewsDataModel;
  int currentLearnerIndex = 0;

  @override
  void initState() {
    super.initState();
    getSectionData();
    getLearnerReviews();
  }

  Future<void> getSectionData() async {
    var responseData = widget.columnData.data;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        microSitesLearnerDataModel =
            MicroSitesLearnerDataModel.fromJson(responseData);
      });
    });
  }

  Future<void> getLearnerReviews() async {
    try {
      var learnerReviewResponseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getLearnerReviews(widget.orgId ?? "");

      if (mounted) {
        setState(() {
          if (learnerReviewResponseData != null) {
            microSitesLearnerReviewsDataModel = Future.value(
                MicroSitesLearnerReviewsDataModel.fromJson(
                    learnerReviewResponseData));
          } else {
            microSitesLearnerReviewsDataModel =
                Future.value(MicroSitesLearnerReviewsDataModel());
          }
        });
      }
    } catch (e) {
      print("Error fetching learner reviews: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
        key: widget.containerKey,
        margin: EdgeInsets.only(
          bottom: 16,
        ).w,
        child: FutureBuilder(
            future: microSitesLearnerReviewsDataModel,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data.content != null) {
                  List<Content> _contentList = snapshot.data.content;
                  if (_contentList.length > 3) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 12, right: 12, bottom: 8).w,
                          child: MicroSiteSpanText(
                            textOne:
                                microSitesLearnerDataModel!.detaulTitle ?? '',
                            textTwo: microSitesLearnerDataModel!.myTitle ?? '',
                            textOneColor: AppColors.black,
                            textTwoColor: AppColors.primaryOne,
                          ),
                        ),
                        _learnerListView(snapshot.data.content),
                        _learnerReviewSectionView(
                            snapshot.data.content[currentLearnerIndex]),
                        _learnerListIndicator(snapshot.data.content),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  return SizedBox.shrink();
                }
              } else {
                return MicroSitesLearnerReviewsViewSkeleton();
              }
            }));
  }

  Widget _learnerListView(List<Content> contentList) {
    return Container(
      margin: EdgeInsets.only(top: 16).w,
      height: 70.w,
      alignment: Alignment.center,
      child: ListView.builder(
          controller: _reviewItemScrollController,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: contentList.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  horizontalOffset: 50,
                  child: FadeInAnimation(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        if (index == 0)
                          SizedBox(
                            width: 16.w,
                          ),
                        _learnerListItem(
                          name: contentList[index].userDetails!.firstName ?? '',
                          profileUrl:
                              contentList[index].userDetails!.profileImageUrl ??
                                  '',
                          itemIndex: index,
                        ),
                      ])),
                ));
          }),
    );
  }

  Widget _learnerListItem({String? name, String? profileUrl, int? itemIndex}) {
    return Container(
      margin: EdgeInsets.only(
        right: 4,
      ).w,
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentLearnerIndex = itemIndex!;
          });
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8).w,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(100.w),
                ),
                child: Container(
                  padding: EdgeInsets.all(4).w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4).w),
                      color: (itemIndex == currentLearnerIndex)
                          ? AppColors.orangeTourText
                          : null),
                  child: ((profileUrl ?? '') != '')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(63.w),
                          child: CachedNetworkImage(
                            height: 48.w,
                            width: 48.w,
                            fit: BoxFit.fill,
                            imageUrl:
                                Helper.convertGCPImageUrl(profileUrl) ?? "",
                            placeholder: (context, url) => ContainerSkeleton(
                              height: 48.w,
                              width: 48.w,
                              radius: 63.w,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/img/image_placeholder.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : Container(
                          height: 48.w,
                          width: 48.w,
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              Helper.getInitialsNew(name ?? ""),
                              style: GoogleFonts.lato(
                                  color: AppColors.avatarText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0.sp),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            if (itemIndex == currentLearnerIndex)
              Positioned(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SvgPicture.asset(
                    'assets/img/icon_arrow_drop_down.svg',
                    width: 10.w,
                    height: 10.w,
                    fit: BoxFit.cover,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _learnerReviewSectionView(Content content) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4).w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.w)),
        border: Border.all(color: AppColors.orangeTourText),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.orangeTourText.withValues(alpha: 0.15),
            AppColors.orangeTourText.withValues(alpha: 0.15),
            AppColors.orangeTourText.withValues(alpha: 0.08),
            AppColors.orangeTourText..withValues(alpha: 0.0),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (content.contentInfo?.identifier != null)
            _learnerReviewedContentView(content),
          Container(
              height: 2.w,
              margin: EdgeInsets.only(left: 48, right: 48, top: 16).r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.orangeTourText.withValues(alpha: 0.1),
                    AppColors.orangeTourText.withValues(alpha: 0.8),
                    AppColors.orangeTourText.withValues(alpha: 0.8),
                    AppColors.orangeTourText.withValues(alpha: 0.1),
                  ],
                  stops: [
                    0.0,
                    0.3,
                    0.7,
                    1.0
                  ], // Adjust stops for a smooth fade effect
                ),
              )),
          if (content.userDetails != null &&
              content.userDetails!.firstName != null)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16).w,
              child: Text(
                content.userDetails!.firstName ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.9.w,
                  letterSpacing: 0.25.w,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16).w,
            child: RatingBarIndicator(
              rating:
                  content.rating != null ? (content.rating!.toDouble()) : 0.0,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: AppColors.primaryOne,
              ),
              itemCount: 5,
              itemSize: 24.0.w,
              direction: Axis.horizontal,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16)
                    .w,
            child: Text(
              content.review!,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                height: 1.3.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _learnerReviewedContentView(Content content) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(top: 8).w,
              child: MicroSiteLearnerReviewsContentWidget(
                  contentInfo: content.contentInfo)),
        ],
      ),
    );
  }

  Widget _learnerListIndicator(List<Content> contentList) {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPageIndicator(contentList.length),
            Row(
              children: [
                MicroSiteIconButton(
                  onTap: () {
                    if (currentLearnerIndex > 0) {
                      _scrollToIndex(currentLearnerIndex - 1);
                    } else {
                      _scrollToIndex(contentList.length - 1);
                    }
                  },
                  backgroundColor: AppColors.black,
                  icon: Icons.arrow_back_ios_sharp,
                  iconColor: AppColors.appBarBackground,
                ),
                MicroSiteIconButton(
                  onTap: () {
                    if (currentLearnerIndex < contentList.length - 1) {
                      _scrollToIndex(currentLearnerIndex + 1);
                    } else {
                      _scrollToIndex(0);
                    }
                  },
                  backgroundColor: AppColors.black,
                  icon: Icons.arrow_forward_ios_sharp,
                  iconColor: AppColors.appBarBackground,
                ),
              ],
            )
          ],
        ));
  }

  void _scrollToIndex(int index) {
    double itemStart = index * 50.0;
    double itemEnd = itemStart + 70.0;
    double viewportStart = _reviewItemScrollController.offset;
    double viewportEnd = viewportStart + 1.sw;

    if (itemStart >= viewportStart && itemEnd <= viewportEnd) {
      setState(() {
        currentLearnerIndex = index;
      });
    } else {
      _reviewItemScrollController.animateTo(
        itemStart,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentLearnerIndex = index;
      });
    }
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 2.0).w,
          height: 4.w,
          width: currentLearnerIndex == index ? 12.w : 4.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50.w)),
            color: currentLearnerIndex == index
                ? AppColors.orangeTourText
                : AppColors.black,
          ),
        );
      }),
    );
  }
}
