import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';

class SearchFieldV2 extends StatefulWidget {
  final Function(String) query;
  const SearchFieldV2({
    required this.query,
    super.key,
  });

  @override
  State<SearchFieldV2> createState() => _SearchFieldV2State();
}

class _SearchFieldV2State extends State<SearchFieldV2> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 45.w,
          width: MediaQuery.of(context).size.width / 1.1,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.appBarBackground,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              contentPadding: const EdgeInsets.only(left: 12, right: 12).r,
              hintText: AppLocalizations.of(context)!.mSearchInAmritGyaanKosh,
              prefixIcon: Icon(
                Icons.search,
                color: ModuleColors.greys87,
                size: 24.sp,
              ),
              hintStyle: GoogleFonts.lato(
                fontSize: 12.sp,
                color: ModuleColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            onSubmitted: (value) {},
          ),
        ),
      ],
    );
  }
}
