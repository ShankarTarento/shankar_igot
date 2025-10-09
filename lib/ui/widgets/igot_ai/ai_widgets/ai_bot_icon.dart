import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/chat_bot_animation.dart';

class AiBotIcon extends StatefulWidget {
  final double size;
  final double padding;
  final bool showCheckIcon;

  const AiBotIcon(
      {super.key,
      this.size = 40,
      this.padding = 6,
      this.showCheckIcon = false});

  @override
  State<AiBotIcon> createState() => _AiBotIconState();
}

class _AiBotIconState extends State<AiBotIcon> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: widget.size.w,
            width: widget.size.w,
            margin: widget.showCheckIcon ? EdgeInsets.all(5) : null,
            padding: EdgeInsets.all(widget.padding).r,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.appBarBackground, width: 0.7),
              color: AppColors.botBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: ChatBotAnimation()),
        widget.showCheckIcon == true
            ? Positioned(
                bottom: 1.5,
                right: 1.5,
                child: Container(
                  height: 14.w,
                  width: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.positiveDark,
                    border: Border.all(
                        color: AppColors.appBarBackground, width: 0.7),
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.appBarBackground,
                    size: 12,
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }
}
