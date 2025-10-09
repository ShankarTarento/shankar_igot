import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class KeyHighlights extends StatefulWidget {
  final List highlights;
  const KeyHighlights({super.key, required this.highlights});

  @override
  State<KeyHighlights> createState() => _KeyHighlightsState();
}

class _KeyHighlightsState extends State<KeyHighlights> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      int nextIndex = _controller.page?.round() ?? 0;
      if (nextIndex != _currentIndex) {
        setState(() {
          _currentIndex = nextIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.all(16).r,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100).r,
        color: AppColors.appBarBackground,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  changeToPreviousIndex();
                },
                child: CircleAvatar(
                  radius: 12.sp,
                  backgroundColor: AppColors.primaryOne,
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.appBarBackground,
                    size: 22.sp,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8).r,
                child: SizedBox(
                  height: 110.w,
                  width: 0.6.sw,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: widget.highlights.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Text(
                          widget.highlights[index]['title'] ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black87,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  changeToNextIndex();
                },
                child: CircleAvatar(
                  radius: 12.sp,
                  backgroundColor: AppColors.primaryOne,
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.appBarBackground,
                    size: 22.sp,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void changeToNextIndex() {
    if (_currentIndex <= widget.highlights.length - 1) {
      _controller.animateToPage(
        _currentIndex + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void changeToPreviousIndex() {
    if (_currentIndex > 0) {
      _controller.animateToPage(
        _currentIndex - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
