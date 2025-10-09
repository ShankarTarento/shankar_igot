import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/services/_services/report_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../constants/_constants/color_constants.dart';
import '../../../_common/page_loader.dart';

class ReportCommentWidget extends StatefulWidget {
  final String commentId;
  final List<String> reportReason;
  final ValueChanged<Map<String, dynamic>>? onSubmitCallback;

  const ReportCommentWidget(
      {Key? key,
      required this.commentId, required this.reportReason, this.onSubmitCallback})
      : super(key: key);

  @override
  State<ReportCommentWidget> createState() => _ReportCommentWidgetState();
}

class _ReportCommentWidgetState extends State<ReportCommentWidget> {
  List<String> _reportReasons = [];
  List<String> _selectedReasons = [];
  final _textController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isOtherSelected = false;
  ValueNotifier<bool> _isLoading = ValueNotifier(false);
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _reportReasons = widget.reportReason;
  }

  ReportService reportService = ReportService();
  Future<void> _reportContent(String otherReason) async {
    _isLoading.value = true;
    Map<String, dynamic> requestData = {
      'reportReasons': _selectedReasons,
    };
    requestData['otherComment'] = _textController.text;

    if (widget.onSubmitCallback != null) {
      widget.onSubmitCallback!(requestData);
    }
    _isLoading.value = false;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onItemChanged(String item, bool? value) {
    setState(() {
      if (value == true) {
        _selectedReasons.add(item);
      } else {
        _selectedReasons.remove(item);
      }
      _isOtherSelected = (_selectedReasons.any((reason) => (reason.toLowerCase() == 'others'.toLowerCase())
          || reason.toLowerCase() == 'other'.toLowerCase()));
      if (_isOtherSelected) {
        Future.delayed(Duration(milliseconds: 1000), () {
          _scrollToBottom();
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            FocusScope.of(context).requestFocus(_commentFocus);
          });
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  bool isValidated() {
    if (_selectedReasons.isEmpty) return false;
    if (_isOtherSelected && _textController.text.isEmpty) return false;
    if (_isOtherSelected && (_textController.text.length > 200)) return false;
    if ((_isOtherSelected && _selectedReasons.length == 1) && _textController.text.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8.sh,
      color: AppColors.appBarBackground,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20).r,
                  height: 6.w,
                  width: 0.25.sw,
                  decoration: BoxDecoration(
                    color: AppColors.grey16,
                    borderRadius: BorderRadius.all(Radius.circular(16)).r,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: AppColors.redBgShade,
                    size: 28.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0).r,
                    child: Text(
                      AppLocalizations.of(context)!.mStaticReporting,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: AppColors.grey08,
                height: 30.w,
                thickness: 1,
              ),
              _reasonsView(),
            ],
          ),

          _actionButton(isValidated()),
        ],
      ),
    );
  }

  Widget _reasonsView() {
    return Container(
      height: 0.56.sh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.mStaticWhatHappened,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.w,),
            Text(
              "${AppLocalizations.of(context)!.mCommentReportChoices}?",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp
              ),
            ),
            SizedBox(height: 12.w,),
            AnimationLimiter(
              child: Column(
                children: List.generate(
                  _reportReasons.length, (index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 475),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0).r,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: Checkbox(
                                    value: _selectedReasons.contains(_reportReasons[index]),
                                    activeColor: AppColors.darkBlue,// Check if item is selected
                                    onChanged: (bool? value) {
                                      _onItemChanged(_reportReasons[index], value);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8).r,
                                  child: Text(
                                    _reportReasons[index],
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w400,
                                        fontSize: 14.sp
                                    ),
                                  ),
                                ), // Display item text
                              ],
                            ),
                          )
                      ),
                    ),
                  );
                },
                ),
              ),
            ),
            if (_isOtherSelected)
              _otherReasonView(),
          ],
        ),
      ),
    );
  }

  Widget _otherReasonView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16).r,
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _commentFocus,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.appBarBackground,
              contentPadding: EdgeInsets.all(8.0).r,
              border: const OutlineInputBorder(),
              disabledBorder:
              const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey08),
                borderRadius: BorderRadius.circular(8.0).r,
              ),
              hintText: AppLocalizations.of(context)!.mStaticTellUsWhatHappened,
              hintStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.grey40,
                fontSize: 14.sp,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.darkBlue,
                    width: 1.0.w),
                borderRadius: BorderRadius.circular(8.0).r,
              ),
            ),
          ),
          Visibility(
            visible:
            _textController.text.length > 200,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8).r,
                child: Text(
                  AppLocalizations.of(context)!.mCommentReportReasonLimitExceeds,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: AppColors.negativeLight
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 0.307.sh,
          )
        ],
      ),
    );
  }

  Widget _actionButton(bool isEnabled) {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 16).r,
      alignment: Alignment.center,
      child: ElevatedButton(
          onPressed: () async {
            if (isValidated()) {
              await _reportContent(_textController.text);
            }
          },
          child: ValueListenableBuilder(
              valueListenable: _isLoading,
              builder: (BuildContext context, bool isLoading, Widget? child) {
                return Container(
                  width: 68.w,
                  alignment: Alignment.center,
                  child: isLoading
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8).w,
                    child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: Center(
                          child: PageLoader(
                            strokeWidth: 2,
                            isLightTheme: false,
                          ),
                        )
                    ),
                  ) : Text(
                    AppLocalizations.of(context)!.mStaticSubmit,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppColors.darkBlue:  AppColors.grey16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63).r,
            ),
          )),
    );
  }
}
