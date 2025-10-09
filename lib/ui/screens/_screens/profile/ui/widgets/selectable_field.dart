import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';

class SelectableField extends StatelessWidget {
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  final Color? color;

  const SelectableField(
      {super.key,
      required this.value,
      required this.placeholder,
      required this.onTap,
      this.color});
  @override
  Widget build(BuildContext context) {
    final isSelected = value.isNotEmpty;

    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          margin: EdgeInsets.only(top: 8).r,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(63).r,
              border: Border.all(color: AppColors.grey24),
              color: color),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 0.75.sw,
                child: Text(
                  isSelected ? value : placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: isSelected ? AppColors.greys : null,
                      ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.greys60),
            ],
          )),
    );
  }
}
