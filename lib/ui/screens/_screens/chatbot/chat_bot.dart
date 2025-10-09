import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/chat_assistant_page.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/chatbot/widget/chat_bot_bottom_bar.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_chat_bot/igot_ai_chatbot.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_chat_bot/widgets/ai_app_bar.dart';
import 'package:karmayogi_mobile/ui/widgets/language_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';

import '../../../../constants/index.dart';

class ChatBot extends StatefulWidget {
  final String loggedInStatus;

  const ChatBot({Key? key, required this.loggedInStatus}) : super(key: key);
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with SingleTickerProviderStateMixin {
  String _userName = '';
  late TabController _tabController;
  bool _isLanguageChanged = true;
  int selectedIndex = 0;

  int _start = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this,
        length: AppConfiguration.iGOTAiConfig.iGOTAI &&
                widget.loggedInStatus != EnglishLang.NotLoggedIn
            ? 3
            : 2);
    _tabController.addListener(() {
      if (selectedIndex != _tabController.index && mounted) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });
    _getProfileDetails();
    _triggerStartTelemetryEvent();
  }

  void _triggerStartTelemetryEvent() async {
    startTimer();
    bool isPublic = widget.loggedInStatus == EnglishLang.NotLoggedIn;
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getStartTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home,
        isPublic: isPublic);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: isPublic);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _triggerEndTelemetryEvent() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        duration: _start,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.homePageUri,
        rollup: {},
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  _updateWidget() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getProfileDetails() async {
    try {
      final _storage = FlutterSecureStorage();
      String? firstName = await _storage.read(key: Storage.firstName);
      setState(() {
        _userName = firstName!;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => false,
      child: Scaffold(
          backgroundColor: AppColors.appBarBackground,
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  selectedIndex == 0 &&
                          AppConfiguration.iGOTAiConfig.iGOTAI &&
                          widget.loggedInStatus != EnglishLang.NotLoggedIn
                      ? AiAppBar()
                      : SliverAppBar(
                          pinned: true,
                          backgroundColor: AppColors.darkBlue,
                          elevation: 10,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          title: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0).r,
                                child: Text(
                                  _userName != ''
                                      ? AppLocalizations.of(context)!
                                              .mStaticHi +
                                          ' ${Helper.capitalizeEachWordFirstCharacter(_userName)}!'
                                      : '${AppLocalizations.of(context)!.mStaticHi}!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                              )),
                          actions: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                LanguagePickerWidget(
                                  parentAction: _updateWidget,
                                  loggedInStatus: widget.loggedInStatus,
                                  onChanged: (value) {
                                    _isLanguageChanged = true;
                                    setState(() {});
                                  },
                                ),
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await _triggerEndTelemetryEvent();
                                    } catch (e) {
                                      log('message: $e');
                                    }
                                    await Provider.of<ChatbotRepository>(
                                            context,
                                            listen: false)
                                        .updateChatHistory(isClear: true);
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15).r,
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.appBarBackground,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  if (AppConfiguration.iGOTAiConfig.iGOTAI &&
                      widget.loggedInStatus != EnglishLang.NotLoggedIn)
                    IgotAiChatbot(),
                  Center(
                    child: ChatAssistantPage(
                      widget.loggedInStatus,
                      isLanguageChanged: _isLanguageChanged,
                    ),
                  ),
                  Center(
                    child: ChatAssistantPage(
                      widget.loggedInStatus,
                      isIssues: true,
                      isLanguageChanged: _isLanguageChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ChatBotBottomBar(
            loggedInStatus: widget.loggedInStatus,
            tabController: _tabController,
          )),
    );
  }
}
