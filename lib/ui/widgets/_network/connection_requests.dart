import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:provider/provider.dart';
import '../_common/page_loader.dart';
import '../title_bold_widget.dart';
import '../title_regular_grey60.dart';
import './../../../constants/index.dart';
import './../../../respositories/index.dart';
import './../../../services/index.dart';
import './../../../ui/pages/index.dart';
import './../../../util/faderoute.dart';
import './../../../util/helper.dart';
import './../../../localization/_langs/english_lang.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

//ignore: must_be_immutable
class ConnectionRequests extends StatefulWidget {
  final connectionRequests;
  bool isShow;
  bool isFromHome;
  bool isFromProfile;
  final parentAction;

  ConnectionRequests(this.connectionRequests, this.isShow,
      {this.isFromHome = false, this.isFromProfile = false, this.parentAction});
  @override
  _ConnectionRequestsState createState() => _ConnectionRequestsState();
}

class _ConnectionRequestsState extends State<ConnectionRequests> {
  dynamic _response;
  List _tempData = [];
  List _filteredData = [];
  String _dropdownValue = EnglishLang.lastAdded;
  bool _pageInitialized = false;
  List<LocalizationText> dropdownItems = [];
  dynamic _data;

  @override
  void initState() {
    super.initState();
    setState(() {
      _data = widget.connectionRequests;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dropdownItems =
        LocalizationText.getNetworkConnectionRequestFilter(context: context);
  }

  /// Get connection request response
  Future<List> _getUserNames(context) async {
    try {
      if (!_pageInitialized) {
        List ids = [];
        if (widget.connectionRequests != null) {
          for (int i = 0; i < _data.data.length; i++) {
            ids.add(_data.data[i]['id']);
          }
        }
        if (ids.length > 0) {
          _tempData =
              await Provider.of<NetworkRespository>(context, listen: false)
                  .getUsersNames(ids);
          _filteredData = _tempData;
        }
        setState(() {
          _pageInitialized = true;
        });
      }
      if (_dropdownValue == EnglishLang.sortByName) {
        setState(() {
          _filteredData.sort((a, b) => (a['profileDetails']['personalDetails']
                      ['firstname'] +
                  (a['profileDetails']['personalDetails']['surname'] != null
                      ? a['profileDetails']['personalDetails']['surname']
                      : ''))
              .toLowerCase()
              .compareTo((b['profileDetails']['personalDetails']['firstname'] +
                      (b['profileDetails']['personalDetails']['surname'] != null
                          ? b['profileDetails']['personalDetails']['surname']
                          : ''))
                  .toLowerCase()));
        });
      } else if (_dropdownValue == EnglishLang.lastAdded) {
        setState(() {
          _filteredData = _tempData.toList();
        });
      }
      // print('_filteredData: ' + _filteredData.toString());
      return _filteredData;
    } catch (err) {
      throw err;
    }
  }

  /// Post accept / reject
  postRequestStatus(context, status, connectionId, connectionDepartment) async {
    try {
      _response = await NetworkService.postAcceptReject(
          status, connectionId, connectionDepartment);

      if (_response['result']['message'] == 'Successful') {
        if (status == 'Approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .mNetworkConnectionRequestAccepted),
              backgroundColor: AppColors.positiveLight,
            ),
          );
        }

        if (status == 'Rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .mStaticConnectionRequestRejected),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() {
          _tempData.removeWhere((data) => data['id'] == connectionId);
          widget.parentAction();
        });
        try {
          final dataNode =
              await Provider.of<NetworkRespository>(context, listen: false)
                  .getCrList();

          setState(() {
            _data = dataNode;
          });
        } catch (err) {
          return err;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (err) {
      return err;
    }

    return _response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUserNames(context),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List data = snapshot.data as List;
            if (data.length == 0) {
              return !widget.isFromHome
                  ? Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            Container(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60).r,
                                  child: SvgPicture.asset(
                                    'assets/img/connections.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16).r,
                              child: Text(
                                AppLocalizations.of(context)!.mStaticNoRequests,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      letterSpacing: 0.25.r,
                                      height: 1.5.w,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8).r,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mStaticNoRequestText,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      letterSpacing: 0.25.r,
                                      height: 1.5.w,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Padding(
                      padding: widget.isFromProfile
                          ? const EdgeInsets.all(0)
                          : const EdgeInsets.only(left: 16, right: 16).r,
                      child: Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                            color: AppColors.appBarBackground,
                            borderRadius: BorderRadius.circular(
                                    widget.isFromProfile ? 12 : 4)
                                .r),
                        child: Padding(
                          padding: widget.isFromProfile
                              ? const EdgeInsets.fromLTRB(14, 16, 16, 16).r
                              : const EdgeInsets.all(16.0).r,
                          child: Text(
                              AppLocalizations.of(context)!
                                  .mNetworkNoConnectionRequests,
                              // textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14.sp)),
                        ),
                      ),
                    );
            } else {
              return Container(
                // margin: EdgeInsets.only(bottom: 65),

                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        Column(
                          children: [
                            if (widget.isShow)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                            15.0, 18.0, 15.0, 15.0)
                                        .r,
                                    child: SizedBox(
                                      width: 150.w,
                                      child: Text(
                                        _filteredData.length.toString() +
                                            ' ' +
                                            AppLocalizations.of(context)!
                                                .mStaticConnectionRequests,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontSize: 14.sp,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 130.w,
                                    margin:
                                        EdgeInsets.only(right: 16, top: 8).r,
                                    child: DropdownButton<String>(
                                      value: _dropdownValue,
                                      icon:
                                          Icon(Icons.arrow_drop_down_outlined),
                                      iconSize: 26,
                                      elevation: 16,
                                      hint: Container(
                                          width: 80.w,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: 16).r,
                                          child: Text(
                                            '${AppLocalizations.of(context)!.mCommonSortBy} ',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      style:
                                          TextStyle(color: AppColors.greys87),
                                      underline: Container(
                                        // height: 2,
                                        color: AppColors.lightGrey,
                                      ),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return dropdownItems.map<Widget>(
                                            (LocalizationText item) {
                                          return Row(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                          15.0, 15.0, 0, 15.0)
                                                      .r,
                                                  child: SizedBox(
                                                    width: 80.w,
                                                    child: Text(
                                                      item.displayText,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                            ],
                                          );
                                        }).toList();
                                      },
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _dropdownValue = newValue ?? '';
                                          // _sortMembers(_dropdownValue);
                                        });
                                      },
                                      items: dropdownItems
                                          .map<DropdownMenuItem<String>>(
                                              (LocalizationText value) {
                                        return DropdownMenuItem<String>(
                                          value: value.value,
                                          child: SizedBox(
                                            width: 80.w,
                                            child: Text(
                                              value.displayText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        AnimationLimiter(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i <
                                      (widget.isFromHome
                                          ? (_filteredData.length > 1 ? 2 : 1)
                                          : _filteredData.length);
                                  i++)
                                AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          FadeRoute(
                                            page: ChangeNotifierProvider<
                                                NetworkRespository>(
                                              create: (context) =>
                                                  NetworkRespository(),
                                              child: NetworkProfile(
                                                profileId: _filteredData[i]
                                                    ['id'],
                                                connectionStatus:
                                                    UserConnectionStatus
                                                        .Pending,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          color: AppColors.appBarBackground,
                                          margin:
                                              EdgeInsets.only(bottom: 5.0).r,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 1.sw,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: _filteredData
                                                                .length >
                                                            1
                                                        ? BorderSide(
                                                            color: AppColors
                                                                .lightBackground,
                                                            width: 2.0)
                                                        : BorderSide.none,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(15.0)
                                                              .r,
                                                      child: Container(
                                                        height: 40.w,
                                                        width: 40.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                                  .networkBg[
                                                              Random().nextInt(
                                                                  AppColors
                                                                      .networkBg
                                                                      .length)],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            _filteredData[i][
                                                                        'profileDetails'] !=
                                                                    null
                                                                ? Helper.getInitials(_filteredData[i]['profileDetails']
                                                                            ['personalDetails']
                                                                        [
                                                                        'firstname'] +
                                                                    ' ' +
                                                                    (_filteredData[i]['profileDetails']['personalDetails']['surname'] !=
                                                                            null
                                                                        ? _filteredData[i]['profileDetails']['personalDetails']
                                                                            ['surname']
                                                                        : ''))
                                                                : 'UN',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displaySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Wrap(
                                                            children: [
                                                              TitleBoldWidget(
                                                                _filteredData[i]
                                                                            [
                                                                            'profileDetails'] !=
                                                                        null
                                                                    ? _filteredData[i]['profileDetails']['personalDetails']
                                                                            [
                                                                            'firstname'] +
                                                                        ' ' +
                                                                        (_filteredData[i]['profileDetails']['personalDetails']['surname'] !=
                                                                                null
                                                                            ? _filteredData[i]['profileDetails']['personalDetails']['surname']
                                                                            : '')
                                                                    : 'UN',
                                                                fontSize:
                                                                    14.0.sp,
                                                                letterSpacing:
                                                                    0.25.r,
                                                              ),
                                                              (_filteredData[i][
                                                                              'profileDetails']
                                                                          [
                                                                          'profileStatus'] ==
                                                                      UserProfileStatus
                                                                          .verified)
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(left: 8)
                                                                              .r,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        size: 20
                                                                            .sp,
                                                                        color: AppColors
                                                                            .positiveLight,
                                                                      ),
                                                                    )
                                                                  : Center()
                                                            ],
                                                          ),
                                                          TitleRegularGrey60(
                                                            _filteredData[i][
                                                                        'rootOrgName'] !=
                                                                    null
                                                                ? _filteredData[
                                                                        i][
                                                                    'rootOrgName']
                                                                : '',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                      10.0)
                                                                  .r,
                                                          child:
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    postRequestStatus(
                                                                        context,
                                                                        EnglishLang
                                                                            .rejected,
                                                                        _filteredData[i]
                                                                            [
                                                                            'id'],
                                                                        _filteredData[i]
                                                                            [
                                                                            'rootOrgName']);
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: AppColors
                                                                          .grey40,
                                                                      size: 26
                                                                          .w)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                                  .fromLTRB(
                                                                      4.0,
                                                                      15.0,
                                                                      20.0,
                                                                      15.0)
                                                              .r,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              postRequestStatus(
                                                                  context,
                                                                  EnglishLang
                                                                      .approved,
                                                                  _filteredData[
                                                                      i]['id'],
                                                                  _filteredData[
                                                                          i][
                                                                      'rootOrgName']);
                                                            },
                                                            child: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                size: 26.w,
                                                                color: AppColors
                                                                    .positiveLight),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            }
          } else {
            return PageLoader(
              top: MediaQuery.of(context).size.height / 4,
            );
          }
        });
  }
}
