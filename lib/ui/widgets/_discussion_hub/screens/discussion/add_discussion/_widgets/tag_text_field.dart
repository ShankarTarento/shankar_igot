import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'field_title_widget.dart';

class TagTextField extends StatefulWidget {
  final List<String>? tags;
  final String errorMessage;
  final bool? addHashTag;
  final bool? isMandatory;

  TagTextField(
      {Key? key, this.tags, this.errorMessage = "", this.addHashTag = true, this.isMandatory = false})
      : super(key: key);

  @override
  _TagTextFieldState createState() => _TagTextFieldState();
}

class _TagTextFieldState extends State<TagTextField> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkForEnterKey);
  }

  @override
  void dispose() {
    _controller.removeListener(_checkForEnterKey);
    _controller.dispose();
    super.dispose();
    _scrollController.dispose();
  }

  void _checkForEnterKey() {
    final text = _controller.text;

    if (text.endsWith('\n')) {
      final tag = text.trim();

      if (tag.isNotEmpty) {
        if ((widget.tags??[]).contains(tag)) {
          setState(() {
            _errorMessage = widget.errorMessage;
          });
        } else {
          setState(() {
            (widget.tags??[]).add(tag);
            _controller.clear();
            _errorMessage = '';
          });
          Future.delayed(Duration(milliseconds: 100), () {
            double currentScrollPosition = _scrollController.offset;
            double targetScrollPosition = currentScrollPosition + 16; // Scroll 50 pixels

            _scrollController.animateTo(
              targetScrollPosition,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      }
    }
  }

  void _removeTag(String tag) {
    setState(() {
      (widget.tags??[]).remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeadingView(),
        _buildTagInputView()
      ],
    );
  }

  Widget _buildHeadingView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8).r,
      child: FieldTitleWidget(
          fieldName: AppLocalizations.of(context)!.mDiscussSubTabTags,
          isMandatory: widget.isMandatory!
      ),
    );
  }

  Widget _buildTagInputView() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greys60),
        borderRadius: BorderRadius.all(
          Radius.circular(4).r,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 0, right: 4).w,
        child: Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((widget.tags??[]).isNotEmpty)
                        SizedBox(width: 20.w),
                      Wrap(
                        spacing: 8.0.w,
                        runSpacing: 4.0.w,
                        children: (widget.tags??[]).map((tag) {
                          return Chip(
                            label: Center(
                              child: Text(
                                widget.addHashTag! ? '#$tag' : tag,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            backgroundColor: AppColors.grey16,
                            deleteIcon: Icon(Icons.cancel_rounded, color: AppColors.greys60, size: 18.w,),
                            onDeleted: () => _removeTag(tag),
                            deleteIconColor: AppColors.greys60, // Icon color
                            padding: EdgeInsets.symmetric(horizontal: 4.0).w,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60.0.r),
                            ),
                          );
                        }).toList(),
                      ),
                      Container(
                        width: 300.w,
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: (_controller.text.isNotEmpty || (widget.tags??[]).isNotEmpty)
                                ? ''
                                : AppLocalizations.of(context)?.mStaticEnterTags ?? '',

                          ),
                          style: GoogleFonts.lato(fontSize: 14.0.sp),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            _controller.text += '\n';
                            _checkForEnterKey();
                          }, // Handle Enter key
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).w,
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.lato(
                    color: AppColors.negativeLight,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,),
                ),
              )
          ],
        ),
      ),
    );
  }
}
