import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/screens/app_inbox/widgets/smt_image_notification_view.dart';
import 'package:karmayogi_mobile/ui/screens/app_inbox/widgets/smt_notification_item_view.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';
import 'package:smartech_appinbox/smartech_appinbox.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'widgets/smt_audio_notification_view.dart';
import 'widgets/smt_carousel_notification_view.dart';
import 'widgets/smt_gif_notification_view.dart';
import 'widgets/smt_simple_notification_view.dart';
import 'widgets/smt_video_notification_view.dart';

class SMTAppInboxScreen extends StatefulWidget {
  const SMTAppInboxScreen({Key? key}) : super(key: key);

  @override
  State<SMTAppInboxScreen> createState() => _SMTAppInboxScreenState();
}

class _SMTAppInboxScreenState extends State<SMTAppInboxScreen> {
  List<MessageCategory> categoryList = [];
  List<SMTAppInboxMessages> inboxList = [];
  bool isDataLoading = true;

  var appBarHeight = AppBar().preferredSize.height;
  int messageLimit = 30;
  String smtInboxDataType = "all";
  String smtAppInboxMessageType = "inbox";
  Int64? latestMessageTimeStamp;
  @override
  void initState() {
    super.initState();
    initialApiCall();
    getMessagesList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initialApiCall() async {
    await getMessageListByApiCall();
    await Future.wait([
      getAppInboxCategoryWiseMessageList(),
      getCategoryList(),
      getAppInboxMessageCount(),
    ]);
    isDataLoading = false;
    setState(() {});
  }

  pullToRefreshApiCall() async {
    smtInboxDataType = "latest";
    categoryList = [];
    await getMessageListByApiCall(smtInboxDataType: smtInboxDataType);
    await Future.wait([
      getAppInboxCategoryWiseMessageList(),
      getCategoryList(),
      getAppInboxMessageCount(),
    ]);
  }

  Future getCategoryList() async {
    categoryList = [];
    await SmartechAppinbox().getAppInboxCategoryList().then((value) {
      if (value != null) {
        categoryList.addAll(value);
      }
      log("getCategoryList: " + categoryList.toString());
    });
  }

  Future getAppInboxCategoryWiseMessageList(
      {List<MessageCategory>? categoryList}) async {
    inboxList = [];
    await SmartechAppinbox()
        .getAppInboxCategoryWiseMessageList(
            categoryList: categoryList
                    ?.where((element) => element.selected)
                    .map((e) => e.name)
                    .toList() ??
                [])
        .then((value) {
      if (value != null) {
        inboxList.addAll(value);
      }
      setState(() {});
    });
  }

  markMessageAsDismissed(String trid) async {
    await SmartechAppinbox().markMessageAsDismissed(trid);
  }

  markMessageAsClicked(String deeplink, String trid) async {
    await SmartechAppinbox().markMessageAsClicked(deeplink, trid);
  }

  markMessageAsViewed(String trid) async {
    await SmartechAppinbox().markMessageAsViewed(trid);
  }

  /// ======>  This is method to get all notifications <======= ///
  getMessagesList() async {
    await SmartechAppinbox().getAppInboxMessages().then((value) {
      print(value);
    });
  }

  Future getMessageListByApiCall(
      {int? messageLimit,
      String? smtInboxDataType,
      List<MessageCategory>? filterCategoryList}) async {
    await SmartechAppinbox()
        .getAppInboxMessagesByApiCall(
            messageLimit: messageLimit ?? 30,
            smtInboxDataType: smtInboxDataType ?? "",
            categoryList: categoryList
                .where((element) => element.selected)
                .map((e) => e.name)
                .toList())
        .then((value) {
      print("getMessageListByApiCall: " + value.toString());
      setState(() {});
    });
  }

  Future getAppInboxMessageCount({String? smtAppInboxMessageType}) async {
    await SmartechAppinbox()
        .getAppInboxMessageCount(
            smtAppInboxMessageType: smtAppInboxMessageType ?? "")
        .then(
      (value) {
        print(value.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App inbox",
        ),
      ),
      body: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            child: MultiSelectChip(
                categoryList
                    .where((element) => (element.selected == true))
                    .toList(), onSelectionChanged: (selectedList) {
              getAppInboxCategoryWiseMessageList(categoryList: categoryList);
              setState(() {});
            }),
          ),
          Expanded(
              child: Stack(
            children: [
              if (!isDataLoading && inboxList.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 100).r,
                  child: NoDataWidget(
                      message: "There are no notifications for you."),
                ),
              if (isDataLoading) Center(child: CupertinoActivityIndicator()),
              if (!isDataLoading)
                RefreshIndicator(
                    onRefresh: () async {
                      await pullToRefreshApiCall();
                    },
                    child: _notificationItems())
            ],
          ))
        ],
      ),
    );
  }

  Widget _notificationItems() {
    return ListView.builder(
      itemCount: inboxList.length,
      itemBuilder: (BuildContext context, int index) {
        final payload = inboxList[index].smtPayload!;
        final type = payload.type;

        final Map<SMTNotificationType, Widget Function()> typeBuilders = {
          SMTNotificationType.image: () =>
              SMTImageNotificationView(inbox: payload),
          SMTNotificationType.gif: () => GIFNotificationView(inbox: payload),
          SMTNotificationType.audio: () =>
              SMTAudioNotificationView(inbox: payload),
          SMTNotificationType.carouselLandscape: () =>
              SMTCarouselNotificationView(inbox: payload),
          SMTNotificationType.carouselPortrait: () =>
              SMTCarouselNotificationView(inbox: payload),
          SMTNotificationType.video: () =>
              SMTVideoNotificationView(inbox: payload),
          SMTNotificationType.simple: () =>
              SMTSimpleNotificationView(inbox: payload),
        };

        final notificationChild = typeBuilders[type]?.call() ??
            SMTSimpleNotificationView(inbox: payload);

        return VisibilityDetector(
          key: Key(index.toString()),
          onVisibilityChanged: (VisibilityInfo info) {
            final visiblePercentage = info.visibleFraction * 100;
            if (visiblePercentage == 100 &&
                payload.status.toLowerCase() != "viewed") {
              markMessageAsViewed(payload.trid);
            }
          },
          child: Dismissible(
            key: Key(payload.trid),
            onDismissed: (direction) async {
              await markMessageAsDismissed(payload.trid);
              inboxList.removeAt(index);
              await getCategoryList();
              setState(() {});
            },
            background: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 26).r,
                child: Icon(
                  Icons.delete,
                  color: AppColors.negativeLight,
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                markMessageAsClicked(payload.deeplink, payload.trid);
              },
              child: SMTNotificationItemView(
                inbox: payload,
                child: notificationChild,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<MessageCategory> categoryList;
  final Function(List<MessageCategory>) onSelectionChanged;
  MultiSelectChip(this.categoryList, {required this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  @override
  void initState() {
    super.initState();
    print("selected chip count: " + widget.categoryList.length.toString());
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.categoryList.forEach((item) {
      choices.add(Container(
        padding: EdgeInsets.only(right: 12),
        child: ChoiceChip(
          selectedColor: AppColors.appBarBackground,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 4,
              ),
              InkWell(
                onTap: () {},
                child: Icon(
                  Icons.cancel_outlined,
                  size: 22,
                ),
              )
            ],
          ),
          selected: item.selected,
          onSelected: (selected) {
            setState(() {
              item.selected = selected;
              widget.onSelectionChanged(widget.categoryList);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class CategoryListWidget extends StatefulWidget {
  final List<MessageCategory> categoryList;
  final Function(List<MessageCategory>) onSelected;

  CategoryListWidget(this.categoryList, this.onSelected);

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  List<MessageCategory> categoryList = [];
  @override
  void initState() {
    super.initState();
    categoryList = [...widget.categoryList];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      color: AppColors.appBarBackground,
      child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  categoryList[index].selected = !categoryList[index].selected;
                });
                widget.onSelected(categoryList);
              },
              child: CheckboxListTile(
                title: Text(
                  categoryList[index].name,
                  style: TextStyle(color: AppColors.greys, fontSize: 16),
                ),
                autofocus: false,
                // dense: true,
                activeColor: AppColors.positiveDark,
                checkColor: AppColors.appBarBackground,
                selected: categoryList[index].selected,
                value: categoryList[index].selected,
                onChanged: (bool? value) {
                  setState(() {
                    categoryList[index].selected =
                        !categoryList[index].selected;
                  });
                  widget.onSelected(categoryList);
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
            );
          },
          itemCount: categoryList.length),
    );
  }
}
