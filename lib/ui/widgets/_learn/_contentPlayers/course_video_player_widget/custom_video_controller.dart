import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/transcription_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_contentPlayers/course_video_player_widget/custom_controller.dart';

class CustomVideoController extends StatefulWidget {
  final List<SubtitleUrl> subtitles;
  final SubtitleUrl? defaultSubtitle;
  final Function(SubtitleUrl?) onSubtitleSelected;

  const CustomVideoController({
    super.key,
    required this.subtitles,
    required this.onSubtitleSelected,
    this.defaultSubtitle,
  });

  @override
  State<CustomVideoController> createState() => _CustomVideoControllerState();
}

class _CustomVideoControllerState extends State<CustomVideoController> {
  SubtitleUrl? _selectedSubtitle;

  @override
  void initState() {
    super.initState();
    _selectedSubtitle = widget.defaultSubtitle;
  }

  void _showSubtitleMenu(TapDownDetails details) async {
    final selectedLabel = _selectedSubtitle?.label;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          details.globalPosition.dx,
          details.globalPosition.dy,
          0,
          0,
        ),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(
        maxWidth: 130.w,
        maxHeight: 220.h,
        minWidth: 125.w,
      ),
      menuPadding: EdgeInsets.all(0),
      items: [
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: 'custom_scrollable_list',
          enabled: false,
          child: Container(
            height: 220.h,
            width: 125.w,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSubtitleMenuItem('off', selectedLabel == null),
                  ...widget.subtitles.map(
                    (subtitle) => _buildSubtitleMenuItem(
                      subtitle.label,
                      subtitle.label == selectedLabel,
                      language: subtitle.language,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );

    // Handle selection
    if (selectedValue != null && selectedValue != 'custom_scrollable_list') {
      if (selectedValue == 'off') {
        setState(() {
          _selectedSubtitle = null;
        });
        widget.onSubtitleSelected(null);
      } else {
        final selectedSubtitle = widget.subtitles.firstWhere(
          (subtitle) => subtitle.label == selectedValue,
        );
        setState(() {
          _selectedSubtitle = selectedSubtitle;
        });
        widget.onSubtitleSelected(selectedSubtitle);
      }
    }
  }

  PopupMenuItem<String> _buildSubtitleMenuItem(String value, bool isSelected,
      {String? language}) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        language ?? 'Off',
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          fontSize: 12.sp,
          color: isSelected ? AppColors.darkBlue : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMaterialControl(
      subtitleWidget: widget.subtitles.isNotEmpty
          ? GestureDetector(
              onTapDown: _showSubtitleMenu,
              child: const Icon(Icons.subtitles, color: Colors.white),
            )
          : SizedBox(),
    );
  }
}
