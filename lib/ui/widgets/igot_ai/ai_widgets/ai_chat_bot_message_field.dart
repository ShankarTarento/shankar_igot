import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiChatBotMessageField extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final Function() sendMessage;
  final bool isLoading;
  const AiChatBotMessageField(
      {super.key,
      required this.controller,
      required this.isLoading,
      required this.scrollController,
      required this.sendMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.appBarBackground,
        padding: const EdgeInsets.all(16.0).r,
        child: Container(
          padding: EdgeInsets.all(1.5).r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40).r,
            gradient: LinearGradient(
              colors: [AppColors.primaryOne, AppColors.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            height: 45.w,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 5).r,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40).r,
                color: AppColors.appBarBackground),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        scrollController
                            .jumpTo(scrollController.position.maxScrollExtent);
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      hintText:
                          "${AppLocalizations.of(context)!.mAskAnything}...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                isLoading
                    ? SizedBox(height: 32.w, width: 32.w, child: PageLoader())
                    : Padding(
                        padding: EdgeInsets.only(top: 4.0).r,
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            sendMessage();
                          },
                          child: const Icon(
                            Icons.send,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
