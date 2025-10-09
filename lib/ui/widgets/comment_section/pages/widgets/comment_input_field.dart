import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_profile_image_widget.dart';
import 'package:provider/provider.dart';

class CommentInputField extends StatefulWidget {
  final String? Function(String?)? validatorFuntion;
  final FocusNode? focusNode;
  final Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final bool readOnly;
  final bool isDate;
  final int? maxLength;
  final Widget? suffix;
  final Widget? suffixIcon;
  final bool showSuffixIcon;
  final int? minLines;
  final int? maxLines;
  final String? counterText;
  final String? initialValue;
  final double height;
  final double borderRadius;
  final Function(String)? onChanged;
  final Function(List<TagUserDataModel>)? onUserTagged;
  final List<TagUserDataModel>? mentionedUserList;
  final bool enableUserTagging;

  const CommentInputField({
    Key? key,
    this.validatorFuntion,
    this.focusNode,
    this.onFieldSubmitted,
    required this.controller,
    required this.keyboardType,
    this.hintText,
    this.onTap,
    this.readOnly = false,
    this.isDate = false,
    this.maxLength,
    this.suffix,
    this.suffixIcon,
    this.showSuffixIcon = false,
    this.minLines,
    this.maxLines,
    this.counterText,
    this.onChanged,
    this.initialValue,
    this.height = 48,
    this.borderRadius = 0,
    this.onUserTagged,
    this.mentionedUserList,
    required this.enableUserTagging,
  }) : super(key: key);

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<TagUserDataModel> _taggedUsers = [];
  List<TagUserDataModel> _filteredUsers = [];
  Map<String, String> _userIdToFirstNameMap = {};
  String _lastQuery = '';
  String? _currentRequestQuery = '';

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    if ((widget.mentionedUserList ?? []).isNotEmpty) {
      _taggedUsers = widget.mentionedUserList!;
      for (final item in _taggedUsers) {
        if ((item.userId ?? '').isNotEmpty) {
          _userIdToFirstNameMap[item.userId!] = item.userName ?? '';
        }
      }
    }
  }

  Future<void> _findSuggestions(String query) async {
    if (query.length < 1 || query == _lastQuery) return;
    _currentRequestQuery = query;
    try {
      final users = await getUserListForTagging(query);
      if (_currentRequestQuery == query) {
        setState(() {
          _filteredUsers = users;
          _lastQuery = query;
        });
      }
    } catch (e) {}
  }

  Future<List<TagUserDataModel>> getUserListForTagging(String searchText) async {
    List<TagUserDataModel> response = [];
    try {
      response = await Provider.of<DiscussionRepository>(context, listen: false).getUserListForTagging(searchText);
      return response;
    } catch (err) {
      return [];
    }
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {}
  }

  void _onTextChanged(String value) async {
    if (!mounted) return;
    if (widget.enableUserTagging) {
      final cursorPosition = widget.controller.selection.baseOffset;
      final mentionedUserIds = _userIdToFirstNameMap.entries
          .where((entry) => value.contains('@${entry.value}'))
          .map((entry) => entry.key)
          .toSet();

      _taggedUsers.removeWhere((user) => !mentionedUserIds.contains(user.userId));

      if (widget.onUserTagged != null) {
        widget.onUserTagged!(_taggedUsers);
      }
      final textBeforeCursor = value.substring(0, cursorPosition);
      final match = RegExp(r'@(\w+)$').firstMatch(textBeforeCursor);
      if (match != null) {
        final keyword = match.group(1)!;
        await _findSuggestions(keyword.toLowerCase());
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  void _onUserSelected(TagUserDataModel user) {
    final value = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;
    final textBeforeCursor = value.substring(0, cursorPosition);
    final match = RegExp(r'@(\w+)$').firstMatch(textBeforeCursor);

    if (match != null) {
      final start = match.start;
      final tagDisplayName = user.userName ?? '';
      final newText = value.replaceRange(start, cursorPosition, '@$tagDisplayName ');

      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + tagDisplayName.length + 2),
      );
      _removeOverlay();

      if (user.userId != null) {
        _userIdToFirstNameMap[user.userId!] = tagDisplayName;
      }
      if (!_taggedUsers.any((u) => u.userId == user.userId)) {
        _taggedUsers.add(user);
        widget.onUserTagged?.call(_taggedUsers);
      }
    }
  }

  Color _getUserColorByFirstAndLast(String name) {
    try {
      if (name.trim().isEmpty || AppColors.networkBg.isEmpty) {
        return AppColors.grey40;
      }
      final trimmedName = name.trim().toUpperCase();
      final firstCharCode = trimmedName.codeUnitAt(0);
      final lastCharCode = trimmedName.codeUnitAt(trimmedName.length - 1);

      final combinedHash = (firstCharCode + lastCharCode) % AppColors.networkBg.length;

      return AppColors.networkBg[combinedHash];
    } catch (e) {
      return AppColors.grey40;
    }
  }

  void _showOverlay() {
    _removeOverlay();
    if (!mounted) return;
    final overlay = Overlay.of(context);
    if (_filteredUsers.isEmpty) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 1.sw - 32.w,
        child: CompositedTransformFollower(
          offset: Offset(0, 40.h),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.appBarBackground,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey40,
                    blurRadius: 8.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 200.h
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return InkWell(
                      onTap: () => _onUserSelected(user),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        child: Row(
                          children: [
                            CommentProfileImageWidget(
                                profilePic: "",
                                name: user.firstName??'',
                                errorImageColor: _getUserColorByFirstAndLast(user.firstName??''),
                                iconSize: 28.w
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.firstName??'',
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '@${user.userName}',
                                    style: GoogleFonts.lato(
                                      color: AppColors.grey40,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8).r,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius).r,
          ),
          height: widget.height.w,
          child: TextFormField(
            maxLength: widget.maxLength,
            initialValue: widget.initialValue,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validatorFuntion,
            focusNode: widget.focusNode,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onFieldSubmitted,
            controller: widget.controller,
            style:
            GoogleFonts.lato(fontSize: 12.0.sp, fontWeight: FontWeight.w400),
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            maxLines: widget.maxLength,
            minLines: widget.minLines,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: (widget.readOnly && !widget.isDate)
                  ? AppColors.grey04
                  : AppColors.appBarBackground,
              contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 10.0).r,
              border: const OutlineInputBorder(),
              disabledBorder:
              const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey08),
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
              ),
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.grey40,
                fontSize: 12.sp,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: (widget.readOnly && !widget.isDate)
                        ? AppColors.grey08
                        : AppColors.darkBlue,
                    width: 1.0.w),
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
              ),
              suffix: widget.suffix != null ? widget.suffix : SizedBox(),
              suffixIcon: ((widget.suffixIcon != null) && widget.showSuffixIcon)
                  ? widget.suffixIcon
                  : SizedBox(),
              counterText: widget.counterText,
            ),
          ),
        ),
      ),
    );
  }
}
