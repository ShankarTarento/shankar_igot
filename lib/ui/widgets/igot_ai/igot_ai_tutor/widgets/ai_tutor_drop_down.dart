import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_tutor_type.dart';

class AiTutorDropdown extends StatefulWidget {
  final Function(AiTutorType) onTypeSelected;
  final AiTutorType selectedType;
  final List<AiTutorType> aiTutorTypes;

  const AiTutorDropdown({
    Key? key,
    required this.onTypeSelected,
    required this.selectedType,
    required this.aiTutorTypes,
  }) : super(key: key);

  @override
  _AiTutorDropdownState createState() => _AiTutorDropdownState();
}

class _AiTutorDropdownState extends State<AiTutorDropdown> {
  late List<AiTutorType> aiTutorTypes;
  late AiTutorType _selectedType;

  @override
  void initState() {
    super.initState();
    aiTutorTypes = widget.aiTutorTypes;
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AiTutorType>(
      value: _selectedType,
      onChanged: (AiTutorType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedType = newValue;
            widget.onTypeSelected(newValue);
          });
        }
      },
      isExpanded: true,
      underline: const SizedBox(),
      selectedItemBuilder: (BuildContext context) {
        return aiTutorTypes.map<Widget>((AiTutorType item) {
          return Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.w),
                  Text(item.subTitle,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.grey)),
                ],
              ),
            ],
          );
        }).toList();
      },
      items: aiTutorTypes.asMap().entries.map((entry) {
        final type = entry.value;
        final isSelected = _selectedType == type;

        return DropdownMenuItem<AiTutorType>(
          value: type,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.w),
                    Text(type.subTitle,
                        style: TextStyle(fontSize: 12.sp, color: AppColors.grey)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.darkBlue, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}
