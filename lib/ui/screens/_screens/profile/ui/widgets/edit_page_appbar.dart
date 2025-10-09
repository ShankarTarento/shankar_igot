import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../constants/index.dart';

class EditPageAppbar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  const EditPageAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).r,
        child: Row(
          children: [
            Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: AppColors.greys,
                  fontSize: 16.sp,
                )
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8).r,
                child: Icon(
                  Icons.close,
                  color: AppColors.disabledGrey,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
