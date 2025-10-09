import 'package:flutter/material.dart';
import '../../../models/index.dart';
import '../../widgets/index.dart';
import './../../../ui/pages/index.dart';

class HubScreen extends StatefulWidget {
  static const route = '/hubScreen';
  final int? index;
  final Profile? profileInfo;
  final profileParentAction;
  final GlobalKey<ScaffoldState>? drawerKey;

  HubScreen(
      {Key? key,
      this.index,
      this.profileInfo,
      this.profileParentAction,
      this.drawerKey})
      : super(key: key);

  @override
  _HubScreenState createState() {
    return new _HubScreenState();
  }
}

class _HubScreenState extends State<HubScreen> with WidgetsBindingObserver {
  ScrollController _scrollController = ScrollController();

  bool scrollStatus = true;

  _scrollListener() {
    if (isScroll != scrollStatus) {
      setState(() {
        scrollStatus = isScroll;
      });
    }
  }

  bool get isScroll {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    // if (widget.index == 1) {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.profileInfo != null && widget.index != null
        ? Scaffold(
            body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool isScrolled) {
                return <Widget>[
                  HomeAppBarNew(
                      index: widget.index!,
                      profileParentAction: widget.profileParentAction,
                      navigateCallBack: () {},
                      drawerKey: widget.drawerKey),
                ];
              },
              body: HubPage(
                tabIndex: widget.index,
              )
            ),
          )
        : Center();
  }
}
