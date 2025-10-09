import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsSortBy extends StatefulWidget {
  final Function(Map<String, dynamic>) onChanged;
  final Map? sortBy;
  const EventsSortBy({super.key, required this.onChanged, this.sortBy});

  @override
  State<EventsSortBy> createState() => _EventsSortByState();
}

class _EventsSortByState extends State<EventsSortBy> {
  String? _selectedItem;

  final List<Map<String, dynamic>> _items = [
    {
      "A-Z": {'name': "asc"},
    },
    // {
    //   "Z-A": {'name': "desc"},
    // },
    // {
    //   "Start Date": {"startDate": "asc"}
    // }
  ];

  @override
  void initState() {
    super.initState();

    if (widget.sortBy != null) {
      widget.sortBy!.forEach((key, value) {
        switch ({key: value}) {
          case {'name': "asc"}:
            _selectedItem = "A-Z";
            break;
          case {'name': "desc"}:
            _selectedItem = "Z-A";
            break;
          case {"startDate": "asc"}:
            _selectedItem = "Start Date";
            break;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant EventsSortBy oldWidget) {
    if (oldWidget.sortBy != widget.sortBy) {
      _selectedItem = null;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mCommonSortBy,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 16.w,
        ),
        Container(
          width: 1.sw,
          padding: EdgeInsets.symmetric(horizontal: 12).r,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08, width: 1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: DropdownButton<String>(
            underline: SizedBox(),
            isExpanded: true,
            value: _selectedItem,
            hint: Text(AppLocalizations.of(context)!.mCommonSortBy),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue;
                for (var item in _items) {
                  if (item.containsKey(newValue)) {
                    widget.onChanged(item[newValue]);
                  }
                }
              });
            },
            items: _items
                .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
              String label = item.keys.first;
              return DropdownMenuItem<String>(
                value: label,
                child: Text(label),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 16.w,
        ),
      ],
    );
  }
}
