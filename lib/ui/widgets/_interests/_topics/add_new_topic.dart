import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewTopic extends StatefulWidget {
  final addToDesiredTopics;
  final List desiredTopics;
  const AddNewTopic(
      {Key? key, this.addToDesiredTopics, required this.desiredTopics})
      : super(key: key);

  @override
  State<AddNewTopic> createState() => _AddNewTopicState();
}

class _AddNewTopicState extends State<AddNewTopic> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _topicController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.all(16).r,
        content: SingleChildScrollView(
          child: Container(
            width: 0.8.sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create the topic',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        height: 1.429.w,
                        letterSpacing: 0.25.r,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16).r,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(4).r,
                    ),
                    child: Focus(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value != null &&
                              widget.desiredTopics.contains(value.trim())) {
                            return 'Topic already exist';
                          } else {
                            return null;
                          }
                        },
                        controller: _topicController,
                        style: GoogleFonts.lato(fontSize: 14.0.sp),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0).r,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey16)),
                          hintText: 'Type here',
                          hintStyle: Theme.of(context).textTheme.labelLarge,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.primaryThree, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 0.23.sw,
                      margin: EdgeInsets.only(right: 16).r,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryThree,
                          backgroundColor: AppColors.appBarBackground,
                          minimumSize: const Size.fromHeight(40), // NEW
                          side: BorderSide(
                              width: 1, color: AppColors.primaryThree),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.mStaticCancel,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                height: 1.429.w,
                                letterSpacing: 0.5.r,
                              ),
                        ),
                      ),
                    ),
                    Container(
                      width: 100.w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryThree,
                          minimumSize: const Size.fromHeight(40), // NEW
                          side: BorderSide(
                              width: 1, color: AppColors.primaryThree),
                        ),
                        onPressed: () {
                          if ((_topicController.text.isNotEmpty &&
                                  _topicController.text.trim().length > 0) &&
                              !widget.desiredTopics
                                  .contains(_topicController.text.trim())) {
                            widget.addToDesiredTopics(_topicController.text);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.mTopicsAddTopic,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                height: 1.429.w,
                                letterSpacing: 0.5.r,
                              ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
