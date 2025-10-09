import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' show Client;

import '../../../../../../constants/index.dart';
import '../../../../../widgets/index.dart';

class SearchNoDataWidget extends StatelessWidget {
  const SearchNoDataWidget(
      {super.key, required this.searchText, Client? client})
      : client = client;

  final Client? client;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 0.25.sh),
        SvgPicture.network(ApiUrl.baseUrl + '/assets/icons/no-data.svg',
            height: 90.w,
            width: 130.w,
            httpClient: client,
            placeholderBuilder: (context) => Image.asset(
                'assets/img/image_placeholder.jpg',
                height: 90.w,
                width: 130.w,
                fit: BoxFit.fill)),
        SizedBox(height: 16.w),
        Text(
          AppLocalizations.of(context)!.mSearchSorryMessage(searchText),
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.w),
        ElevatedButton(
            onPressed: () {
              CustomTabs.setTabItem(context, 0, true);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
              child: Text(AppLocalizations.of(context)!.mSearchBackToHomePage,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: AppColors.darkBlue)),
            ),
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.darkBlue),
                        borderRadius: BorderRadius.circular(63))),
                backgroundColor: WidgetStatePropertyAll(AppColors.appBarBackground)))
      ],
    );
  }
}
