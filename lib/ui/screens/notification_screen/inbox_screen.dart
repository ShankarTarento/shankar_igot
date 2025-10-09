import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';
import 'package:smartech_appinbox/smartech_appinbox.dart';

import '../../../constants/index.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<MessageCategory> categoryList = [];
  List<SMTAppInboxMessages> inboxList = [];
  bool isDataLoading = true;

  var appBarHeight = AppBar().preferredSize.height;
  // CustomPopupMenuController _controller = CustomPopupMenuController();
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
    // _controller.hideMenu();
    super.dispose();
  }

  Future initialApiCall() async {
    await getMessageListByApiCall();
    //await getMessagesList();
    await Future.wait([
      getAppInboxCategoryWiseMessageList(),
      getCategoryList(),
      getAppInboxMessageCount(), // This method use to get appinbox messages count based on message type
      //getMessagesList(),// This method use to get all types of notifications
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
      getAppInboxMessageCount(), // This method use to get appinbox messages count based on message type
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
    // var url =
    //     'https://appinbox.netcoresmartech.com/v1/appinbox?appId=83f135604f51c4e1eb268c1d8ff0f1fa&identity=8920616622&limit=10&direction=all&timestamp=-1&guid=D274A9CA-1837-47C4-A290-9496BEDB876B';
    // var response = await Dio().get(
    //   url,
    //   // options: Options(
    //   //   headers: {
    //   //     "Content-Type": "application/json",
    //   //     "Accept": "*/*",
    //   //   },
    //   // ),
    //   // data: formData
    // );
    // if (response.statusCode == 200) {
    //   //print(response.data);
    //   // var model = jsonEncode(response.data);
    //   // Map<String, dynamic> data = jsonDecode(model);
    //   // print(data['inbox'][4]['aps']['payload']);
    // }
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
      // log(inboxList.toString());
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
    // inboxList = [];
    await SmartechAppinbox().getAppInboxMessages().then((value) {
      // log(value.toString());
      // if (value != null) {
      //   inboxList.addAll(value);
      // }
      // setState(() {});
      // log(inboxList.toString());
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
      appBar: AppBar(title: Text('Inbox')),
      body: _itemList(),
    );
  }

  Widget _itemList() {
    return Container(
        child: ListView.builder(
      itemCount: inboxList.length,
      itemBuilder: (context, index) {
        final notification = inboxList[index].smtPayload;
        if (notification == null) {
          return SizedBox.shrink();
        }
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ListTile(
            title: Text(notification.title.isNotEmpty
                ? notification.title
                : "No Title"),
            subtitle: Text(notification.body.isNotEmpty
                ? notification.body
                : "No Message"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {},
            ),
            onTap: () {},
          ),
        );
      },
    ));
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
