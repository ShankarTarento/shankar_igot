import 'dart:io';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/_respositories/settings_repository.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../pages/_pages/search/utils/search_helper.dart';
import '../widgets/field_name_widget.dart';
import '../../model/district_model.dart';
import '../../model/photo_render_status_model.dart';
import '../../model/profile_top_section_model.dart';
import '../../model/state_model.dart';
import '../../view_model/profile_top_section_view_model.dart';
import '../../utils/profile_constants.dart';
import '../../utils/profile_helper.dart';
import '../widgets/photo_render_option.dart';
import '../widgets/profile_edit_hearder.dart';
import '../widgets/profile_image_widget.dart';
import '../widgets/selectable_field.dart';

class EditProfileTopSection extends StatefulWidget {
  final String firstName;
  final String surname;
  final String state;
  final String district;
  final String? uuid;
  final MemoryImage? image;
  final Function(ProfileTopSectionModel) onUpdateCallback;
  final ProfileRepository profileRepository;

  EditProfileTopSection(
      {super.key,
      this.firstName = '',
      this.surname = '',
      this.state = '',
      this.district = '',
      this.uuid,
      this.image,
      required this.onUpdateCallback,
      ProfileRepository? profileRepository})
      : profileRepository = profileRepository ?? ProfileRepository();

  @override
  State<EditProfileTopSection> createState() => _EditProfileTopSectionState();
}

class _EditProfileTopSectionState extends State<EditProfileTopSection> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  ValueNotifier<String> imageUrl = ValueNotifier('');
  ValueNotifier<String?> errMsg = ValueNotifier(null);
  final _formKey = GlobalKey<FormState>();
  Future<List<StateModel>>? futureStateList;
  Future<List<DistrictModel>>? futureDistrictList;
  bool isTablet = false;
  String? selectedState;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
    _nameController.text = widget.firstName;
    selectedState = widget.state;
    selectedDistrict = widget.district;
    fetchData();
    _nameFocusNode.addListener(() {
      setState(() {
        if (!_nameFocusNode.hasFocus) {
          _formKey.currentState?.validate();
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    errMsg.dispose();
    imageUrl.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      ProfileTopSectionViewModel()
              .nameValidation(_nameController.text, context) ==
          null &&
      (_nameController.text != widget.firstName ||
          selectedState != widget.state ||
          selectedDistrict != widget.district);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: InkWell(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            padding: const EdgeInsets.all(16.0).r,
            margin: EdgeInsets.only(top: 32).r,
            width: 1.0.sw,
            height: 1.0.sh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileEditHeader(
                    title: AppLocalizations.of(context)!.mStaticProfile,
                    callback: () => Navigator.pop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 24.w),
                        Center(
                          child: InkWell(
                              onTap: () => photoOptions(context),
                              child: Stack(
                                children: [
                                  Selector<ProfileRepository, Profile?>(
                                      selector: (context, profile) =>
                                          profile.profileDetails,
                                      builder:
                                          (context, profileDetails, child) {
                                        return ProfileImageWidget(
                                            profileImageUrl: profileDetails !=
                                                    null
                                                ? (profileDetails
                                                            .profileImageUrl !=
                                                        null
                                                    ? profileDetails
                                                        .profileImageUrl!
                                                    : '')
                                                : '',
                                            firstName: widget.firstName,
                                            surname: widget.surname,
                                            height: isTablet ? 0.2 : 0.4,
                                            width: isTablet ? 0.2 : 0.4);
                                      }),
                                  Positioned(
                                      bottom: isTablet ? 15.r : 5.r,
                                      right: isTablet ? 35.r : 15.r,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(63).r,
                                          color: AppColors.appBarBackground,
                                        ),
                                        padding: EdgeInsets.all(8).r,
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 16.sp,
                                          color: AppColors.darkBlue,
                                        ),
                                      ))
                                ],
                              )),
                        ),
                        SizedBox(height: 16.w),
                        FieldNameWidget(
                          isMandatory: true,
                          fieldName: AppLocalizations.of(context)!.mStaticName,
                        ),
                        SizedBox(height: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _nameController,
                              maxLength: 200,
                              onChanged: (value) {
                                errMsg.value = ProfileTopSectionViewModel()
                                    .nameValidation(value, context);
                              },
                              keyboardType: TextInputType.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: AppColors.greys),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2)
                                      .r,
                                  hintText: AppLocalizations.of(context)!
                                      .mEditProfileEnterYourFullname,
                                  hintStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(63).r,
                                    borderSide:
                                        BorderSide(color: AppColors.grey24),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(63).r,
                                    borderSide:
                                        BorderSide(color: AppColors.grey24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(63).r,
                                    borderSide:
                                        BorderSide(color: AppColors.darkBlue),
                                  ),
                                  counterStyle: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: AppColors.grey40)),
                            ),
                            ValueListenableBuilder(
                                valueListenable: errMsg,
                                builder: (context, value, child) {
                                  return Visibility(
                                    visible: value != null,
                                    child: Text(value ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                                color:
                                                    AppColors.negativeLight)),
                                  );
                                })
                          ],
                        ),
                        FieldNameWidget(
                          fieldName: AppLocalizations.of(context)!.mStaticState,
                        ),
                        SizedBox(height: 8.w),
                        FutureBuilder(
                            future: futureStateList,
                            builder: (context, snapshot) {
                              List<String> stateList = snapshot.data != null &&
                                      snapshot.data!.isNotEmpty
                                  ? ProfileTopSectionViewModel()
                                      .getStateNames(snapshot.data!)
                                  : [];
                              return SelectableField(
                                  value: selectedState ?? '',
                                  placeholder: AppLocalizations.of(context)!
                                      .mProfileSelectState,
                                  onTap: () =>
                                      ProfileHelper().showSearchableBottomSheet(
                                          context: context,
                                          items: stateList,
                                          onItemSelected: (String value) async {
                                            selectedState = value;
                                            selectedDistrict = '';
                                            futureDistrictList = Future.value(
                                                await fetchDistricts(value));

                                            if (mounted) {
                                              setState(() {});
                                            }
                                          }));
                            }),
                        SizedBox(height: 16.w),
                        FieldNameWidget(
                          fieldName:
                              AppLocalizations.of(context)!.mProfileDistrict,
                        ),
                        SizedBox(height: 8.w),
                        FutureBuilder(
                            future: futureDistrictList,
                            builder: (context, snapshot) {
                              List<String> districtList =
                                  snapshot.data != null &&
                                          snapshot.data!.isNotEmpty &&
                                          selectedState != null
                                      ? ProfileTopSectionViewModel()
                                          .getDistrictNames(
                                              snapshot.data!, selectedState!)
                                      : [];
                              return SelectableField(
                                onTap: () => selectedState == null ||
                                        selectedState!.isEmpty
                                    ? SearchHelper().showOverlayMessage(
                                        AppLocalizations.of(context)!
                                            .mProfileDistrictDisable,
                                        context,
                                        duration: 3)
                                    : ProfileHelper().showSearchableBottomSheet(
                                        context: context,
                                        items: districtList,
                                        onItemSelected: (String value) {
                                          selectedDistrict = value;
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        }),
                                value: selectedDistrict ?? '',
                                placeholder: AppLocalizations.of(context)!
                                    .mProfileSelectDistrict,
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 1.0.sw,
                  child: ElevatedButton(
                    onPressed: isFormValid
                        ? () async {
                            ProfileTopSectionModel updatedData =
                                ProfileTopSectionModel(
                                    firstName: widget.firstName);
                            bool nameUpdateStatus = false;
                            bool otherInfoUpdateStatus = false;
                            if (_nameController.text != widget.firstName &&
                                _nameController.text.isNotEmpty) {
                              bool isUpdatedSuccessully =
                                  await ProfileTopSectionViewModel().updateName(
                                      _nameController.text, context);
                              if (isUpdatedSuccessully) {
                                nameUpdateStatus = isUpdatedSuccessully;
                                updatedData.firstName = _nameController.text;
                              }
                            }
                            if ((selectedState != null &&
                                    selectedState!.isNotEmpty) ||
                                (selectedDistrict != null &&
                                    selectedDistrict!.isNotEmpty)) {
                              bool isUpdatedSuccessully = false;
                              if (widget.state.isEmpty &&
                                  widget.district.isEmpty) {
                                isUpdatedSuccessully =
                                    await ProfileTopSectionViewModel()
                                        .addStateAndDistrict(
                                            selectedState ?? '',
                                            selectedDistrict ?? '',
                                            context);
                              } else {
                                isUpdatedSuccessully =
                                    await ProfileTopSectionViewModel()
                                        .updateStateAndDistrict(
                                            widget.uuid ?? '',
                                            selectedState != widget.state
                                                ? selectedState!
                                                : '',
                                            selectedDistrict != widget.district
                                                ? selectedDistrict!
                                                : '',
                                            context);
                              }
                              if (isUpdatedSuccessully) {
                                otherInfoUpdateStatus = isUpdatedSuccessully;
                                updatedData.state = selectedState!;
                                updatedData.district = selectedDistrict!;
                              }
                            }
                            if (nameUpdateStatus && otherInfoUpdateStatus) {
                              SearchHelper().showOverlayMessage(
                                  AppLocalizations.of(context)!
                                      .mProfileUploadedSuccessfully,
                                  context,
                                  duration: 3,
                                  bgColor: AppColors.positiveLight);
                            }
                            widget.onUpdateCallback(updatedData);
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(63).r)),
                    child:
                        Text(AppLocalizations.of(context)!.mProfileSaveChanges),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future photoOptions(contextMain) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => PhotoRenderOption(
              parentContext: contextMain,
              cropShape: CustomCropShape.Circle,
              imageFormat: ImageFormat.profilePhoto,
              callBackOnImage: (PhotoRenderStatusModel photoModel) async {
                if (photoModel.image != null) {
                  File imageFile = await ProfileTopSectionViewModel()
                      .memoryImageToFile(photoModel.image!,
                          '${photoModel.fileName ?? 'IGOT${DateTime.now().microsecondsSinceEpoch}'}.${photoModel.format}');
                  double imageSize = await ProfileTopSectionViewModel()
                      .imageSizeInMb(imageFile);
                  if (imageSize <= ImageMaxSizeInMB.profileImage) {
                    String? response = await ProfileTopSectionViewModel()
                        .uploadImage(imageFile, contextMain);
                    if (response != null) {
                      imageUrl.value = response;
                      widget.onUpdateCallback(
                          ProfileTopSectionModel(profileImageUrl: response));
                    }
                  } else {
                    Helper.showToastMessage(contextMain,
                        message: AppLocalizations.of(contextMain)!
                            .mProfileProfileImageError(
                                ImageMaxSizeInMB.profileImage));
                  }
                } else if (photoModel.changePhoto) {
                  await photoOptions(contextMain);
                } else if (photoModel.deletePhoto) {
                  await ProfileTopSectionViewModel().deletePhoto(contextMain);
                  widget.onUpdateCallback(
                      ProfileTopSectionModel(profileImageUrl: ''));
                }
              },
            ));
  }

  Future<String?> showSearchableDropdown({
    required List<String> items,
    required String title,
  }) {
    final TextEditingController searchController = TextEditingController();
    List<String> filtered = List.from(items);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (items.length > 5)
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.mCommonSearch),
                  onChanged: (value) {
                    setState(() {
                      filtered = items
                          .where((item) =>
                              item.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              SizedBox(height: 10),
              Container(
                height: 200,
                width: double.maxFinite,
                child: StatefulBuilder(
                  builder: (context, setInnerState) {
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filtered[index]),
                          onTap: () => Navigator.pop(context),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchData() async {
    futureStateList =
        Future.value(await widget.profileRepository.getStateList());
    if (widget.state.isNotEmpty) {
      futureDistrictList = Future.value(await fetchDistricts(widget.state));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<DistrictModel>> fetchDistricts(String state) async {
    return await widget.profileRepository.getDistrictList(state);
  }
}
