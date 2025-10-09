import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class DropDownListWidget extends StatefulWidget {
  final List options;
  final String? selectedValue;
  final ValueChanged changeOption;

  const DropDownListWidget(
      {Key? key,
      required this.options,
      this.selectedValue,
      required this.changeOption})
      : super(key: key);

  @override
  State<DropDownListWidget> createState() => _DropDownListWidgetState();
}

class _DropDownListWidgetState extends State<DropDownListWidget> {
  String selectedOption =''; 

  @override
  void initState() {
    super.initState();
    selectedOption =
        widget.selectedValue ?? ''; // Initialize with default value
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey16, width: 1),
      ),
      margin: EdgeInsets.only(right: 4),
      padding: EdgeInsets.only(left: 8),
      child: DropdownButton<String>(
        underline: SizedBox(), // Remove the default underline
        value: selectedOption.isEmpty ? null : selectedOption,
        hint: const Text('Select an option'),
        items: widget.options
            .cast<Map<String, dynamic>>()
            .map<DropdownMenuItem<String>>((Map<String, dynamic> element) {
          return DropdownMenuItem<String>(
            value: element['value']['body'] as String,
            child: Text(
              _truncateWithEllipsis(element['value']['body'].toString(), 100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedOption = newValue ?? ''; 
          });
          widget.changeOption(newValue ?? '');
        },
      ),
    );
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }
}
