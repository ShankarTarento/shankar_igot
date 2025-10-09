import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CompetencyFilterItems extends StatefulWidget {
  final int index;
  final String name;
  bool isSelected;
  final bool isCompetencyArea;
  final updateSelection;
  CompetencyFilterItems(
      {Key? key,
      required this.index,
      this.name = '',
      required this.isSelected,
      this.updateSelection,
      required this.isCompetencyArea})
      : super(key: key);

  @override
  State<CompetencyFilterItems> createState() => _CompetencyFilterItemsState();
}

class _CompetencyFilterItemsState extends State<CompetencyFilterItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6).r,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8).r,
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: widget.isSelected,
              onChanged: (value) {
                setState(() {
                  widget.isSelected = value ?? false;
                });

                widget.isCompetencyArea
                    ? widget.updateSelection(widget.index, value, widget.name,
                        isCompetencyArea: true)
                    : widget.updateSelection(widget.index, value, widget.name,
                        isCompetencyType: true);
              },
            ),
          ),
          Container(
            width: 0.78.sw,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2).r,
              child: Text(
                widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      height: 1.429.w,
                      letterSpacing: 0.25.r,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
